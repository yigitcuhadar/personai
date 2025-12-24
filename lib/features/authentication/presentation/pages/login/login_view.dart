import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../cubit/login_cubit.dart';
import '../sign_up/sign_up_page.dart';
import '../../widgets/auth_shared.dart';

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
      child: AuthPageShell(
        title: 'Welcome back',
        subtitle: 'Log in to continue with PersonAI.',
        helperText: 'Don\'t have an account?',
        helperActionLabel: 'Create account',
        helperActionKey: const Key('loginForm_createAccount_flatButton'),
        onHelperActionTap: () => Navigator.of(context).push<void>(SignUpPage.route()),
        onTapOutside: () => FocusScope.of(context).unfocus(),
        children: const [
          _EmailInput(),
          _PasswordInput(),
          _LoginButton(),
        ],
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
        return AuthInputField(
          fieldKey: const Key('loginForm_emailInput_textField'),
          label: 'Email',
          hint: 'name@email.com',
          icon: Icons.email_outlined,
          enabled: !isInProgress,
          errorText: displayError != null ? 'Enter a valid email' : null,
          onChanged: (email) => context.read<LoginCubit>().emailChanged(email),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
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
        return AuthInputField(
          fieldKey: const Key('loginForm_passwordInput_textField'),
          label: 'Password',
          hint: '••••••••',
          icon: Icons.lock_outline,
          enabled: !isInProgress,
          obscureText: true,
          enableToggle: true,
          errorText: displayError != null ? 'Password is too short' : null,
          onChanged: (password) => context.read<LoginCubit>().passwordChanged(password),
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
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
        return AuthPrimaryButton(
          key: const Key('loginForm_continue_raisedButton'),
          label: 'Log in',
          enabled: isValid && !isInProgress,
          loading: isInProgress,
          onPressed: () => context.read<LoginCubit>().submitted(),
        );
      },
    );
  }
}
