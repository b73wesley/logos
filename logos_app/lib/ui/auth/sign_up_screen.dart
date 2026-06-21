import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logos_app/config/l10n/arb/app_localizations.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/button_style_theme.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/routing/routes.dart';
import 'package:logos_app/ui/auth/view_model/auth_view_model.dart';
import 'package:logos_app/ui/widgets/app_alert_dialog.dart';
import 'package:logos_app/ui/widgets/app_button.dart';
import 'package:logos_app/ui/widgets/app_snack_bar.dart';
import 'package:logos_app/ui/widgets/app_text_field.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onStatusChanged(BuildContext context, AuthViewModel vm, AppLocalizations l10n) {
    if (vm.status == AuthStatus.success) {
      context.go(Routes.home);
    } else if (vm.status == AuthStatus.error) {
      final key = vm.errorMessage;
      final message = _resolveError(l10n, key);
      if (key == 'server_connection_error' || key == 'network_error_retry') {
        AppAlertDialog.show(context, l10n.server_connection_error, message);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppSnackBar.show(message, context, type: AppSnackBarType.secundary));
      }
      vm.resetStatus();
    }
  }

  String _resolveError(AppLocalizations l10n, String? key) {
    switch (key) {
      case 'email_already_in_use_error':
        return l10n.email_already_in_use_error;
      case 'password_too_short_error':
        return l10n.password_too_short_error;
      case 'invalid_email_error':
        return l10n.invalid_email_error;
      case 'network_error_retry':
        return l10n.network_error_retry;
      default:
        return l10n.server_connection_error;
    }
  }

  void _showTermsConfirmation(BuildContext context, AuthViewModel vm, AppLocalizations l10n) {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.show(l10n.passwords_do_not_match_error, context, type: AppSnackBarType.secundary),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs3)),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.screenHorizontal),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Spacing.xs4),
              AppTypography(
                l10n.sign_up_terms_title,
                textStyleTheme: TextStyleTheme.titleMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xs8),
              AppTypography(
                l10n.sign_up_terms_body,
                textStyleTheme: TextStyleTheme.bodyMedium,
                color: AppColors.darkText60,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xxs3),
              AppButton(
                l10n.agree_and_create,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  vm.signUpWithEmailAndPassword(name, email, password);
                },
              ),
              const SizedBox(height: Spacing.xs4),
              AppButton(
                l10n.cancel,
                buttonStyleTheme: ButtonStyleTheme.link,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              const SizedBox(height: Spacing.xs4),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onStatusChanged(context, vm, l10n);
        });

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
                    onPressed: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.screenHorizontal,
                      vertical: Spacing.screenVertical,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: Spacing.xxs3),

                        Center(
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.primary40,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 52,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),

                        const SizedBox(height: Spacing.xxs7),

                        AppTypography(
                          l10n.create_account,
                          textStyleTheme: TextStyleTheme.headlineMedium,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: Spacing.xs4),

                        AppTypography(
                          l10n.login_with_email_password,
                          textStyleTheme: TextStyleTheme.bodyMedium,
                          color: AppColors.darkText60,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: Spacing.xxs7),

                        AppTextField(
                          title: l10n.name_label,
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: Spacing.betweenFormFiledsV),
                        AppTextField(
                          title: l10n.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: Spacing.betweenFormFiledsV),
                        AppTextField(
                          title: l10n.password_label,
                          controller: _passwordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: Spacing.betweenFormFiledsV),
                        AppTextField(
                          title: l10n.confirm_password,
                          controller: _confirmPasswordController,
                          obscureText: true,
                        ),

                        const SizedBox(height: Spacing.actionTop),

                        AppButton(
                          l10n.sign_up,
                          isLoading: vm.isLoading,
                          onPressed: () => _showTermsConfirmation(context, vm, l10n),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.xxs3),
                  child: AppButton(
                    l10n.have_account_sign_in,
                    buttonStyleTheme: ButtonStyleTheme.link,
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
