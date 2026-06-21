import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/core/design_tokens/widget_size.dart';
import 'package:logos_app/ui/widgets/app_button.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:logos_app/core/design_tokens/icon_size.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppScaffold extends StatelessWidget {
  final Widget? bottomNavigationBar;
  final Widget? body;
  final String? title;
  // Floating Action Button label and action
  final String fABLabel;
  // Floating Action Button action
  final void Function()? onFABPressed;
  final bool showNotificationsBadge;
  final bool showMessagesBadge;
  final bool nestedScrollable;
  final ScrollController? scrollController;

  const AppScaffold({
    super.key,
    this.title,
    this.body,
    this.bottomNavigationBar,
    this.showNotificationsBadge = false,
    this.showMessagesBadge = false,
    this.nestedScrollable = false,
    this.scrollController,
    this.fABLabel = '',
    this.onFABPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !nestedScrollable
          ? AppBar(
              titleSpacing: Spacing.xs0,
              title: _AppBar(
                title: title,
                showNotificationsBadge: showNotificationsBadge,
                showMessagesBadge: showMessagesBadge,
              ),
            )
          : null,
      bottomNavigationBar: bottomNavigationBar,
      body: nestedScrollable
          ? SafeArea(
              child: NestedScrollView(
                controller: scrollController,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      titleSpacing: Spacing.xs0,
                      title: _AppBar(
                        title: title,
                        showNotificationsBadge: showNotificationsBadge,
                        showMessagesBadge: showMessagesBadge,
                      ),
                    ),
                  ];
                },
                body: body ?? const SizedBox.shrink(),
              ),
            )
          : body,
      floatingActionButton: (onFABPressed != null && MediaQuery.of(context).viewInsets.bottom == 0)
          ? Padding(
              padding: const EdgeInsets.all(Spacing.xxs8),
              child: SizedBox(
                height: WidgetSize.fixButton,
                child: AppButton(fABLabel, onPressed: () => onFABPressed!()),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _AppBar extends StatelessWidget {
  final String? title;
  final bool showNotificationsBadge;
  final bool showMessagesBadge;

  const _AppBar({this.title, required this.showNotificationsBadge, required this.showMessagesBadge});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Spacing.xs6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (title != null)
                AppTypography(
                  title!,
                  fontWeight: FontWeight.w600,
                  textStyleTheme: TextStyleTheme.titleMedium,
                ),
              if (showNotificationsBadge) showMessagesBadge ? Badge(child: buildIcon()) : buildIcon(),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xs6),
      ],
    );
  }

  Icon buildIcon() {
    return Icon(FontAwesomeIcons.solidBell, size: IconSize.normal);
  }
}
