import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../models/log_entry.dart';
import '../models/message_entry.dart';
import 'home_card_styles.dart';
import 'realtime_audio_output.dart';
import 'status_badge.dart';

class ConversationCard extends StatelessWidget {
  const ConversationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(kHomeCardRadius),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDF6EF), Color(0xFFEFF5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const RealtimeAudioOutput(),
            Positioned(
              top: -70,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Color(0x33A7C7FF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Color(0x33BEEBD2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0x22F6D8A8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(kHomeCardPadding),
              child: Column(
                children: const [
                  _ConversationHeader(),
                  SizedBox(height: 10),
                  _MessagePanelSlot(),
                  _PromptComposer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final info = _statusInfo(state.status);
        return Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conversation',
                    style: kHomeCardTitleTextStyle,
                  ),
                  Text(
                    'Live feed',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
            StatusBadge(label: info.label, color: info.color),
          ],
        );
      },
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(180)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: const _MessageList(),
      ),
    );
  }
}

class _MessagePanelSlot extends StatelessWidget {
  const _MessagePanelSlot();

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (p, c) => p.status != c.status,
        builder: (context, state) {
          final isConnected = state.status == HomeStatus.connected;
          return AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: isConnected
                ? Column(
                    children: const [
                      Expanded(child: _MessagePanel()),
                      SizedBox(height: 10),
                    ],
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.messages != c.messages,
      builder: (context, state) {
        final messages = state.messages;
        if (messages.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet.',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: messages.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _MessageBubble(entry: messages[index]);
          },
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.entry});

  final MessageEntry entry;

  @override
  Widget build(BuildContext context) {
    final isServer = entry.direction == LogDirection.server;
    final alignment = isServer ? Alignment.centerLeft : Alignment.centerRight;
    final bubbleColor = isServer ? const Color(0xFFEAF2FF) : const Color(0xFFE9F9EF);
    final accentColor = isServer ? const Color(0xFF3D7BFF) : const Color(0xFF2E9E65);
    final label = isServer ? 'Server' : 'You';
    final labelColor = isServer ? const Color(0xFF3D7BFF) : const Color(0xFF2E9E65);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isServer ? 6 : 16),
              bottomRight: Radius.circular(isServer ? 16 : 6),
            ),
            border: Border.all(color: accentColor.withAlpha(90)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: isServer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SelectableText(
                  entry.text,
                  style: const TextStyle(fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptComposer extends StatefulWidget {
  const _PromptComposer();

  @override
  State<_PromptComposer> createState() => _PromptComposerState();
}

class _PromptComposerState extends State<_PromptComposer> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(HomeState state) {
    final isConnected = state.status == HomeStatus.connected;
    final isBusy = state.status == HomeStatus.connecting || state.status == HomeStatus.disconnecting;
    if (!isConnected || isBusy || !state.prompt.isValid) return;
    context.read<HomeCubit>().sendPrompt();
    _controller.clear();
    context.read<HomeCubit>().onPromptChanged('');
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.status != c.status || p.prompt.value != c.prompt.value,
      builder: (context, state) {
        final isConnected = state.status == HomeStatus.connected;
        final isBusy = state.status == HomeStatus.connecting || state.status == HomeStatus.disconnecting;
        final isPromptValid = state.prompt.isValid;
        final isPromptEnabled = isConnected && !isBusy;
        if (state.prompt.value.isEmpty && _controller.text.isNotEmpty) {
          _controller.clear();
        }
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                autocorrect: false,
                minLines: 1,
                maxLines: 1,
                textInputAction: TextInputAction.send,
                enabled: isPromptEnabled,
                onChanged: (value) => context.read<HomeCubit>().onPromptChanged(value),
                onFieldSubmitted: isConnected && isPromptValid && !isBusy ? (_) => _submit(state) : null,
                decoration: InputDecoration(
                  hintText: 'Type a question...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const _MicButton(),
            const SizedBox(width: 8),
            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: isPromptValid && isConnected && !isBusy ? () => _submit(state) : null,
                icon: const Icon(Icons.send),
                label: const Text(
                  'Send',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusInfo {
  const _StatusInfo(this.label, this.color);

  final String label;
  final Color color;
}

_StatusInfo _statusInfo(HomeStatus status) {
  switch (status) {
    case HomeStatus.connected:
      return _StatusInfo('Connected', Colors.green);
    case HomeStatus.connecting:
      return _StatusInfo('Connecting', Colors.orange);
    case HomeStatus.disconnecting:
      return _StatusInfo('Disconnecting', Colors.orange);
    case HomeStatus.error:
      return _StatusInfo('Error', Colors.red);
    case HomeStatus.initial:
      return _StatusInfo('Ready', Colors.blueGrey);
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.status != c.status || p.micStatus != c.micStatus || p.isUserSpeaking != c.isUserSpeaking,
      builder: (context, state) {
        final isConnected = state.status == HomeStatus.connected;
        final isBusy = state.status == HomeStatus.connecting || state.status == HomeStatus.disconnecting;
        final isMicBusy = state.micStatus == MicStatus.starting || state.micStatus == MicStatus.stopping;
        final isActive = state.micStatus == MicStatus.on;
        final isSpeaking = state.isUserSpeaking;
        final isEnabled = isConnected && !isBusy && !isMicBusy;

        Color backgroundColor;
        Color iconColor;
        if (!isConnected || isBusy) {
          backgroundColor = Colors.grey.shade200;
          iconColor = Colors.grey.shade500;
        } else if (isActive) {
          backgroundColor = const Color(0xFF2E9E65);
          iconColor = Colors.white;
        } else {
          backgroundColor = Colors.white.withAlpha(230);
          iconColor = Colors.black54;
        }

        final tooltip = !isConnected
            ? 'Connect to use microphone'
            : isActive
            ? 'Disable microphone'
            : 'Enable microphone';

        return Tooltip(
          message: tooltip,
          child: SizedBox.square(
            dimension: 40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: isSpeaking && isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2E9E65).withAlpha(80),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Material(
                color: backgroundColor,
                shape: const CircleBorder(),
                elevation: isActive ? 2 : 0,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isEnabled ? () => context.read<HomeCubit>().toggleMicrophone() : null,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: isMicBusy
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                              ),
                            )
                          : Icon(
                              isActive ? Icons.mic : Icons.mic_none,
                              color: iconColor,
                              size: 18,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
