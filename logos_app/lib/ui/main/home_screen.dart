import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logos_app/core/design_tokens/spacing.dart';
import 'package:logos_app/routing/routes.dart';
import 'package:logos_app/ui/widgets/app_button.dart';
import 'package:logos_app/ui/widgets/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Logos',
      body: Padding(
        padding: const EdgeInsets.all(Spacing.screenHorizontal),
        child: AppButton('Login', onPressed: () => context.push(Routes.login)),
      ),
    );
  }
}
