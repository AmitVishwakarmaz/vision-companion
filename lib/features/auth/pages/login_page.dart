import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/features/auth/widgets/auth_button.dart';
import 'package:vision_companion/features/auth/widgets/auth_text_field.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignInPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signInWithEmail(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  void _onGoogleSignInPressed() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppConstants.routeHome);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.getLocalizedMessage(l10n)),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is Loading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        size: 72,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.loginTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(180),
                        ),
                      ),
                      const SizedBox(height: 32),
                      AuthTextField(
                        controller: _emailController,
                        label: l10n.emailLabel,
                        hint: l10n.emailHint,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.emailRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passwordController,
                        label: l10n.passwordLabel,
                        hint: l10n.passwordHint,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.passwordRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      AuthButton(
                        text: l10n.signInButton,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _onSignInPressed,
                      ),
                      const SizedBox(height: 12),
                      AuthButton(
                        text: l10n.signInWithGoogle,
                        isOutlined: true,
                        icon: Icons.g_mobiledata_rounded,
                        onPressed: isLoading ? null : _onGoogleSignInPressed,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
