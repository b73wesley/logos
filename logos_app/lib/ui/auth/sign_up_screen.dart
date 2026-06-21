import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logos_app/config/l10n/arb/app_localizations.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/button_style_theme.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/ui/widgets/app_button.dart';
import 'package:logos_app/ui/widgets/app_text_field.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';

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

  void _showTermsConfirmation(BuildContext context, AppLocalizations l10n) {
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
                  // TODO: chamar o sign up
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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Arrow back
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

                    // Logo
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.primary40,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.menu_book_rounded, size: 52, color: AppColors.primaryText),
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

                    AppButton(l10n.sign_up, onPressed: () => _showTermsConfirmation(context, l10n)),
                  ],
                ),
              ),
            ),

            // Login fixo no bottom
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
  }
}
