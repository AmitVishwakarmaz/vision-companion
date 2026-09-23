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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPrimaryActionPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isSignUp) {
        context.read<AuthCubit>().signUpWithEmail(
              _emailController.text,
              _passwordController.text,
              displayName: _nameController.text.trim(),
            );
      } else {
        context.read<AuthCubit>().signInWithEmail(
              _emailController.text,
              _passwordController.text,
            );
      }
    }
  }

  void _onGoogleSignInPressed() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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

          final title = _isSignUp ? l10n.signUpTitle : l10n.loginTitle;
          final subtitle = _isSignUp ? l10n.signUpSubtitle : l10n.loginSubtitle;
          final primaryButtonText = _isSignUp ? l10n.signUpButton : l10n.signInButton;
          final toggleModeText = _isSignUp ? l10n.alreadyHaveAccount : l10n.dontHaveAccount;
          final toggleModeSemantic =
              _isSignUp ? l10n.switchToSignInSemantic : l10n.switchToSignUpSemantic;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Logo
                      Center(
                        child: Semantics(
                          label: l10n.loginHeaderSemantic,
                          image: true,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(
                              Icons.visibility_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Screen Title
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Screen Subtitle
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Full Name Field (Sign Up mode only)
                      if (_isSignUp) ...[
                        AuthTextField(
                          controller: _nameController,
                          label: l10n.nameLabel,
                          hint: l10n.nameHint,
                          prefixIcon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.nameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email Field
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

                      // Password Field
                      AuthTextField(
                        controller: _passwordController,
                        label: l10n.passwordLabel,
                        hint: l10n.passwordHint,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: Semantics(
                          label: l10n.passwordVisibilityToggleSemantic,
                          button: true,
                          child: IconButton(
                            iconSize: 24,
                            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.passwordRequired;
                          }
                          if (_isSignUp && value.trim().length < 6) {
                            return l10n.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field (Sign Up mode only)
                      if (_isSignUp) ...[
                        AuthTextField(
                          controller: _confirmPasswordController,
                          label: l10n.confirmPasswordLabel,
                          hint: l10n.confirmPasswordHint,
                          prefixIcon: Icons.lock_reset_rounded,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: Semantics(
                            label: l10n.passwordVisibilityToggleSemantic,
                            button: true,
                            child: IconButton(
                              iconSize: 24,
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.confirmPasswordRequired;
                            }
                            if (value != _passwordController.text) {
                              return l10n.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 8),

                      // Primary Action Button (Sign In or Sign Up)
                      AuthButton(
                        text: primaryButtonText,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _onPrimaryActionPressed,
                      ),
                      const SizedBox(height: 12),

                      // Google Sign In Button
                      AuthButton(
                        text: l10n.signInWithGoogle,
                        isOutlined: true,
                        icon: Icons.g_mobiledata_rounded,
                        onPressed: isLoading ? null : _onGoogleSignInPressed,
                      ),
                      const SizedBox(height: 20),

                      // Toggle between Sign In and Sign Up Mode
                      Semantics(
                        button: true,
                        label: toggleModeSemantic,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isLoading ? null : _toggleAuthMode,
                            child: Text(
                              toggleModeText,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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
