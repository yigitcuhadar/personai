import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../cubit/sign_up_cubit.dart';

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
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          appBar: AppBar(title: Text('Sign Up')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EmailInput(),
                  const SizedBox(height: 8),
                  _PasswordInput(),
                  const SizedBox(height: 8),
                  _ConfirmPasswordInput(),
                  const SizedBox(height: 8),
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.email.displayError != c.email.displayError || p.status.isInProgress != c.status.isInProgress,
      builder: (context, state) {
        final displayError = state.email.displayError;
        final isInProgress = state.status.isInProgress;
        return TextField(
          key: const Key('signUpForm_emailInput_textField'),
          enabled: !isInProgress,
          onChanged: (email) => context.read<SignUpCubit>().emailChanged(email),
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.password.displayError != c.password.displayError || p.status.isInProgress != c.status.isInProgress,
      builder: (context, state) {
        final displayError = state.password.displayError;
        final isInProgress = state.status.isInProgress;
        return TextField(
          key: const Key('signUpForm_passwordInput_textField'),
          enabled: !isInProgress,
          onChanged: (password) => context.read<SignUpCubit>().passwordChanged(password),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'password',
            errorText: displayError != null ? 'invalid password' : null,
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) =>
          p.confirmPassword.displayError != c.confirmPassword.displayError || p.status.isInProgress != c.status.isInProgress,
      builder: (context, state) {
        final displayError = state.confirmPassword.displayError;
        final isInProgress = state.status.isInProgress;
        return TextField(
          key: const Key('signUpForm_confirmPasswordInput_textField'),
          enabled: !isInProgress,
          onChanged: (confirmPassword) => context.read<SignUpCubit>().confirmPasswordChanged(confirmPassword),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'confirm password',
            errorText: displayError != null ? 'passwords do not match' : null,
          ),
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (p, c) => p.status.isInProgress != c.status.isInProgress || p.isValid != c.isValid,
      builder: (context, state) {
        final isInProgress = state.status.isInProgress;
        final isValid = state.isValid;
        return ElevatedButton(
          key: const Key('signUpForm_continue_raisedButton'),
          onPressed: isValid && !isInProgress ? () => context.read<SignUpCubit>().submitted() : null,
          child: !isInProgress ? const Text('Sign Up') : const CircularProgressIndicator.adaptive(),
        );
      },
    );
  }
}
