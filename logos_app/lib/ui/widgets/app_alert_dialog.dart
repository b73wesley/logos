import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/button_style_theme.dart';
import 'package:logos_app/core/design_tokens/icon_size.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/routing/routes.dart';
import 'package:logos_app/ui/widgets/app_button.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

enum AppAlertDialogType { primary, secundary, success }

class AppAlertDialog {
  static void show(
    BuildContext context,
    String label,
    String description, {
    AppAlertDialogType type = AppAlertDialogType.secundary,
    bool isNotAuth = true,
  }) {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.triangleExclamation, size: IconSize.large, color: AppColors.warning),
              const SizedBox(height: Spacing.xs8),
              AppTypography(
                label,
                color: AppColors.primaryTextButton,
                textStyleTheme: TextStyleTheme.headlineSmall,
              ),
              const SizedBox(height: Spacing.xs8),
              AppTypography(description, color: AppColors.primaryTextButton, textAlign: TextAlign.center),
              const SizedBox(height: Spacing.xs4),
              Padding(
                padding: const EdgeInsets.all(Spacing.screenHorizontal),
                child: AppButton(
                  'Ok',
                  buttonStyleTheme: ButtonStyleTheme.secondary,
                  onPressed: () {
                    //if (Session().jwt.isNullOrEmpty && isNotAuth) {
                    //  context.push(Routes.login);
                    //}
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
