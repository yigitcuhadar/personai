import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../cubit/login_cubit.dart';
import '../sign_up/sign_up_page.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (p, c) => c.status != p.status,
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Authentication Failure'),
              ),
            );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          appBar: AppBar(title: Text('Login')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: const Column(
                children: [
                  _EmailInput(),
                  SizedBox(height: 8),
                  _PasswordInput(),
                  SizedBox(height: 8),
                  _LoginButton(),
                  SizedBox(height: 4),
                  _SignUpButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (p, c) => p.email.displayError != c.email.displayError || p.status.isInProgress != c.status.isInProgress,
      builder: (context, state) {
        final displayError = state.email.displayError;
        final isInProgress = state.status.isInProgress;
        return TextField(
          key: const Key('loginForm_emailInput_textField'),
          autocorrect: false,
          enabled: !isInProgress,
          onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'email',
            errorText: displayError != null ? 'invalid email' : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (p, c) => p.password.displayError != c.password.displayError || p.status.isInProgress != c.status.isInProgress,
      builder: (context, state) {
        final displayError = state.password.displayError;
        final isInProgress = state.status.isInProgress;
        return TextField(
          key: const Key('loginForm_passwordInput_textField'),
          autocorrect: false,
          enabled: !isInProgress,
          onChanged: (password) => context.read<LoginCubit>().passwordChanged(password),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'password',
            errorText: displayError != null ? 'invalid password' : null,
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (p, c) => p.status.isInProgress != c.status.isInProgress || p.isValid != c.isValid,
      builder: (context, state) {
        final isInProgress = state.status.isInProgress;
        final isValid = state.isValid;
        return ElevatedButton(
          key: const Key('loginForm_continue_raisedButton'),
          onPressed: isValid && !isInProgress ? () => context.read<LoginCubit>().submitted() : null,
          child: !isInProgress ? const Text('Login') : const CircularProgressIndicator.adaptive(),
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (p, c) => p.status.isInProgress != c.status.isInProgress,
      builder: (context, state) {
        final isInProgress = state.status.isInProgress;
        return TextButton(
          key: const Key('loginForm_createAccount_flatButton'),
          onPressed: !isInProgress ? () => Navigator.of(context).push<void>(SignUpPage.route()) : null,
          child: Text(
            'Create Account',
          ),
        );
      },
    );
  }
}
