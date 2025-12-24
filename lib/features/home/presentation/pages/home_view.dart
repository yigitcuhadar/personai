import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/di/injector.dart';
import '../cubit/home_cubit.dart';
import '../widgets/connection_drawer.dart';
import '../widgets/conversation_card.dart';
import '../widgets/logs_drawer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AppConfig _config;

  @override
  void initState() {
    super.initState();
    _config = getIt<AppConfig>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scaffoldKey.currentState?.openDrawer();
    });
  }

  void _openLogsDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final viewPaddingBottom = MediaQuery.of(context).viewPadding.bottom;
    final bottomPadding = 16 + viewPaddingBottom;
    final isDebug = _config.flavor == Flavor.dev;
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeCubit, HomeState>(
          listenWhen: (p, c) => p.lastError != c.lastError,
          listener: (context, state) {
            final lastError = state.lastError;
            if (lastError != null && lastError.isNotEmpty) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(lastError)));
            }
          },
        ),
        BlocListener<HomeCubit, HomeState>(
          listenWhen: (p, c) => (p.isSaving && c.isConnected) || (p.isConnecting && c.isConnected),
          listener: (context, state) {
            Navigator.of(context).maybePop();
          },
        ),
      ],
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Realtime Playground'),
            actions: [
              if (isDebug)
                IconButton(
                  tooltip: 'Logs',
                  onPressed: _openLogsDrawer,
                  icon: const Icon(Icons.receipt_long_outlined),
                ),
              TextButton(
                onPressed: () => getIt<AuthenticationRepository>().logOut(),
                child: const Text('Logout'),
              ),
            ],
          ),
          drawer: const ConnectionDrawer(),
          endDrawer: isDebug ? const LogsDrawer() : null,
          endDrawerEnableOpenDragGesture: isDebug,
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(child: ConversationCard()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
