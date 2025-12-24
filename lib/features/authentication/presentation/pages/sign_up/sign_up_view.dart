import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../cubit/sign_up_cubit.dart';
import '../../widgets/auth_shared.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
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
        } else if (state.status.isSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: AuthPageShell(
        title: 'Create an account',
        subtitle: 'Sign up to start taking your conversations further.',
        helperText: 'Already have an account?',
        helperActionLabel: 'Log in',
        onHelperActionTap: () => Navigator.of(context).pop(),
        onTapOutside: () => FocusScope.of(context).unfocus(),
        children: const [
          _EmailInput(),
          _PasswordInput(),
          _ConfirmPasswordInput(),
          _SignUpButton(),
        ],
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.email.displayError != c.email.displayError || p.status.isInProgress != c.status.isInProgress,
      builder: (context, state) {
        final displayError = state.email.displayError;
        final isInProgress = state.status.isInProgress;
        return AuthInputField(
          fieldKey: const Key('signUpForm_emailInput_textField'),
          label: 'Email',
          hint: 'name@email.com',
          icon: Icons.email_outlined,
          enabled: !isInProgress,
          errorText: displayError != null ? 'Enter a valid email' : null,
          onChanged: (email) => context.read<SignUpCubit>().emailChanged(email),
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
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.password.displayError != c.password.displayError || p.status.isInProgress != c.status.isInProgress,
      builder: (context, state) {
        final displayError = state.password.displayError;
        final isInProgress = state.status.isInProgress;
        return AuthInputField(
          fieldKey: const Key('signUpForm_passwordInput_textField'),
          label: 'Password',
          hint: 'At least 8 characters',
          icon: Icons.lock_outline,
          enabled: !isInProgress,
          obscureText: true,
          enableToggle: true,
          errorText: displayError != null ? 'Password is too short' : null,
          onChanged: (password) => context.read<SignUpCubit>().passwordChanged(password),
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  const _ConfirmPasswordInput();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) =>
          p.confirmPassword.displayError != c.confirmPassword.displayError || p.status.isInProgress != c.status.isInProgress,
      builder: (context, state) {
        final displayError = state.confirmPassword.displayError;
        final isInProgress = state.status.isInProgress;
        return AuthInputField(
          fieldKey: const Key('signUpForm_confirmPasswordInput_textField'),
          label: 'Confirm password',
          hint: 'Re-enter your password',
          icon: Icons.verified_user_outlined,
          enabled: !isInProgress,
          obscureText: true,
          enableToggle: true,
          errorText: displayError != null ? 'Passwords do not match' : null,
          onChanged: (confirmPassword) => context.read<SignUpCubit>().confirmPasswordChanged(confirmPassword),
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.status.isInProgress != c.status.isInProgress || p.isValid != c.isValid,
      builder: (context, state) {
        final isInProgress = state.status.isInProgress;
        final isValid = state.isValid;
        return AuthPrimaryButton(
          key: const Key('signUpForm_continue_raisedButton'),
          label: 'Sign up',
          enabled: isValid && !isInProgress,
          loading: isInProgress,
          onPressed: () => context.read<SignUpCubit>().submitted(),
        );
      },
    );
  }
}
