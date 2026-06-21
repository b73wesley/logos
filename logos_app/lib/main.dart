import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logos_app/config/di/dependencies.dart';
import 'package:logos_app/config/l10n/arb/app_localizations.dart';
import 'package:logos_app/core/design_tokens/app_colors.dart';
import 'package:logos_app/core/preferences.dart';
import 'package:logos_app/firebase_options.dart';
import 'package:logos_app/routing/router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Preferences.init();

  runApp(MultiProvider(providers: buildProviders(), child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.backgroundLight, elevation: 0),
      ),
      routerConfig: appRouter,
    );
  }
}
