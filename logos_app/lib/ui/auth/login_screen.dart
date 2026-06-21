import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logos_app/config/l10n/arb/app_localizations.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/button_style_theme.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/routing/routes.dart';
import 'package:logos_app/ui/widgets/app_button.dart';
import 'package:logos_app/ui/widgets/app_text_field.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      l10n.welcome_title(l10n.appName),
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

                    const SizedBox(height: Spacing.xs4),

                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        l10n.forgot_email_password,
                        buttonStyleTheme: ButtonStyleTheme.link,
                        onPressed: () {},
                      ),
                    ),

                    const SizedBox(height: Spacing.actionTop),

                    AppButton(l10n.login, onPressed: () {}),

                    const SizedBox(height: Spacing.betweenFormFiledsV),

                    Center(
                      child: AppTypography(
                        l10n.or_continue_with,
                        textStyleTheme: TextStyleTheme.bodySmall,
                        color: AppColors.darkText60,
                      ),
                    ),

                    const SizedBox(height: Spacing.betweenFormFiledsV),

                    AppButton(
                      l10n.continue_with_google,
                      buttonStyleTheme: ButtonStyleTheme.secondary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Sign up fixo no bottom
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xxs3),
              child: AppButton(
                l10n.no_account_sign_up,
                buttonStyleTheme: ButtonStyleTheme.link,
                onPressed: () => context.push(Routes.signUp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
