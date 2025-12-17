import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../cubit/home_cubit.dart';
import '../widgets/connection_card.dart';
import '../widgets/conversation_card.dart';
import '../widgets/logs_sheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const double _logMinSize = 0.12;
  static const double _logInitialSize = 0.22;
  static const double _logMaxSize = 0.7;

  final DraggableScrollableController _logSheetController = DraggableScrollableController();
  final GlobalKey _logSheetKey = GlobalKey();

  @override
  void dispose() {
    _logSheetController.dispose();
    super.dispose();
  }

  bool _isPointerInsideLogSheet(Offset position) {
    final context = _logSheetKey.currentContext;
    if (context == null) return true;
    final renderBox = context.findRenderObject();
    if (renderBox is! RenderBox) return true;
    final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    return rect.contains(position);
  }

  void _collapseLogsSheet() {
    if (!_logSheetController.isAttached) return;
    final target = _logMinSize;
    if (_logSheetController.size <= target + 0.01) return;
    _logSheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (p, c) => p.status != c.status || p.lastError != c.lastError,
      listener: (context, state) {
        final status = state.status;
        final lastError = state.lastError;
        if (status == HomeStatus.error) {
          if (lastError != null && lastError.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(lastError)));
          }
        }
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (!_isPointerInsideLogSheet(event.position)) {
            _collapseLogsSheet();
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Realtime Playground'),
              actions: [
                TextButton(
                  onPressed: () => getIt<AuthenticationRepository>().logOut(),
                  child: const Text('Logout'),
                ),
              ],
            ),
            body: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
                  final basePadding = constraints.maxHeight * _logMinSize + 16;
                  final bottomPadding = keyboardInset > 0 ? 16.0 : basePadding;
                  return Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: const [
                            ConnectionCard(),
                            SizedBox(height: 12),
                            Expanded(child: ConversationCard()),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: LogsSheet(
                          controller: _logSheetController,
                          sheetKey: _logSheetKey,
                          minChildSize: _logMinSize,
                          initialChildSize: _logInitialSize,
                          maxChildSize: _logMaxSize,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
