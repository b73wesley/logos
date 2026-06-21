import 'package:logos_app/core/design_tokens/button_style_theme.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/ui/widgets/app_button.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';
import 'package:flutter/material.dart';

/// Standard bottom sheet container for the app.
///
/// Features:
/// - Centered title
/// - SafeArea support
/// - Flexible actions (null = hidden, non-null = shown)
/// - Responsive padding with keyboard support
class AppBottomSheet extends StatelessWidget {
  /// The title displayed at the top of the bottom sheet
  final String title;

  /// The main content of the bottom sheet
  final Widget child;

  /// Primary action button (right side)
  /// If null, the button is not displayed
  final AppBottomSheetAction? primaryAction;

  /// Secondary action button (left side)
  /// If null, the button is not displayed
  final AppBottomSheetAction? secondaryAction;

  /// Whether to apply SafeArea
  final bool useSafeArea;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.primaryAction,
    this.secondaryAction,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.only(
        left: Spacing.screenHorizontal,
        right: Spacing.screenHorizontal,
        top: Spacing.xxs8,
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.xxs8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Center(child: AppTypography(title, textStyleTheme: TextStyleTheme.titleMedium)),
          const SizedBox(height: Spacing.xxs3),

          // Content
          child,

          // Actions
          if (primaryAction != null || secondaryAction != null) ...[
            const SizedBox(height: Spacing.actionTop),
            _buildActions(),
          ],
        ],
      ),
    );

    return useSafeArea ? SafeArea(bottom: true, child: content) : content;
  }

  Widget _buildActions() {
    // Both actions present
    if (primaryAction != null && secondaryAction != null) {
      return Row(
        children: [
          Expanded(child: _ActionButton(action: secondaryAction!)),
          const SizedBox(width: Spacing.xs6),
          Expanded(child: _ActionButton(action: primaryAction!)),
        ],
      );
    }

    // Only primary action
    if (primaryAction != null) {
      return _ActionButton(action: primaryAction!);
    }

    // Only secondary action
    if (secondaryAction != null) {
      return _ActionButton(action: secondaryAction!);
    }

    return const SizedBox.shrink();
  }
}

/// Represents an action button in the bottom sheet
class AppBottomSheetAction {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final ButtonStyleTheme buttonStyleTheme;

  const AppBottomSheetAction({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.buttonStyleTheme = ButtonStyleTheme.primary,
  });
}

/// Internal widget to render an action button
class _ActionButton extends StatelessWidget {
  final AppBottomSheetAction action;

  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      action.label,
      onPressed: action.onPressed,
      isLoading: action.isLoading,
      buttonStyleTheme: action.buttonStyleTheme,
    );
  }
}
