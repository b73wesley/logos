import 'package:flutter/material.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/design_tokens/text_style_theme.dart';
import 'package:logos_app/ui/widgets/app_scaffold.dart';
import 'package:logos_app/ui/widgets/app_typography.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Jornada',
      body: const Center(
        child: AppTypography(
          'Em breve',
          textStyleTheme: TextStyleTheme.titleMedium,
          color: AppColors.darkText50,
        ),
      ),
    );
  }
}
