import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/font_size.dart';
import 'package:logos_app/core/design_tokens/icon_size.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/ui/main/bars_visibility_notifier.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.book_outlined, activeIcon: Icons.book_rounded, label: 'Bíblia'),
    _NavItem(icon: Icons.route_outlined, activeIcon: Icons.route_rounded, label: 'Jornada'),
    _NavItem(icon: Icons.menu_outlined, activeIcon: Icons.menu_rounded, label: 'Menu'),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BarsVisibilityNotifier>(
      builder: (context, barsNotifier, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          // Column keeps the nav bar in the layout flow — when it collapses
          // to zero height the content expands to fill the freed space,
          // which means the reader's _NavigationBar (prev/book/next) sits
          // correctly at the true bottom of the screen.
          body: Column(
            children: [
              Expanded(child: navigationShell),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: SizedBox(
                  height: barsNotifier.visible ? null : 0,
                  child: _BottomNav(
                    currentIndex: navigationShell.currentIndex,
                    items: _items,
                    onTap: (index) {
                      // Restores bars whenever the user switches tabs.
                      context.read<BarsVisibilityNotifier>().show();
                      navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Bottom nav bar ─────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.darkText10, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashColor: AppColors.primary40,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: IconSize.medium,
                        color: isActive ? AppColors.primary : AppColors.darkText40,
                      ),
                      const SizedBox(height: Spacing.xs1),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: FontSize.labelSmall,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? AppColors.primary : AppColors.darkText40,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
