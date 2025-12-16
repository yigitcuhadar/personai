import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';

class PromptCard extends StatelessWidget {
  const PromptCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _PromptField(),
            SizedBox(height: 8),
            _PromptSendButton(),
          ],
        ),
      ),
    );
  }
}

class _PromptField extends StatelessWidget {
  const _PromptField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.prompt.displayError != c.prompt.displayError ||
          p.status != c.status,
      builder: (context, state) {
        final displayError = state.prompt.displayError;
        final isConnected = state.status == HomeStatus.connected;
        return TextFormField(
          autocorrect: false,
          onChanged: (value) =>
              context.read<HomeCubit>().onPromptChanged(value),
          minLines: 2,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: 'Prompt',
            hintText: 'Bugün hava nasıl?',
            errorText: displayError,
          ),
          onFieldSubmitted: isConnected
              ? (_) {
                  context.read<HomeCubit>().sendPrompt();
                  FocusScope.of(context).unfocus();
                }
              : null,
        );
      },
    );
  }
}

class _PromptSendButton extends StatelessWidget {
  const _PromptSendButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (p, c) =>
            p.prompt.isValid != c.prompt.isValid || p.status != c.status,
        builder: (context, state) {
          final isPromptValid = state.prompt.isValid;
          final isConnected = state.status == HomeStatus.connected;
          final isBusy =
              state.status == HomeStatus.connecting ||
              state.status == HomeStatus.disconnecting;
          return ElevatedButton.icon(
            onPressed: isPromptValid && isConnected && !isBusy
                ? () {
                    context.read<HomeCubit>().sendPrompt();
                    FocusScope.of(context).unfocus();
                  }
                : null,
            icon: const Icon(Icons.send),
            label: const Text('Send'),
          );
        },
      ),
    );
  }
}
