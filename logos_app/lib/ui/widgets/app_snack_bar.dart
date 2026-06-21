import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/app_radius.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';
import 'package:flutter/material.dart';

enum AppSnackBarType { primary, secundary, success }

class AppSnackBar {
  static SnackBar show(
    String label,
    BuildContext context, {
    AppSnackBarType type = AppSnackBarType.success,
    String? actionText,
    void Function()? onTap,
  }) {
    return SnackBar(
      content: Row(
        children: [
          AppTypography(label, color: _getTextColor(type)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs2),
            child: GestureDetector(
              child: AppTypography(
                actionText ?? 'Dismiss',
                fontWeight: FontWeight.w600,
                color: _getTextColor(type),
              ),
              onTap: () {
                if (onTap != null) onTap();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: _getBackgroundColor(type),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs2)),
      duration: const Duration(seconds: 2),
    );
  }

  static Color _getTextColor(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.secundary:
        return AppColors.warning;
      case AppSnackBarType.success:
        return AppColors.successText;
      default:
        return AppColors.primaryTextButton;
    }
  }

  static Color _getBackgroundColor(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.secundary:
        return AppColors.alertSnackBarBackground;
      case AppSnackBarType.success:
        return AppColors.successSnackBarBackground;
      default:
        return AppColors.primarySnackBarBackground;
    }
  }
}
