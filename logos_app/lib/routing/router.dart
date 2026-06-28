import 'package:go_router/go_router.dart';
import 'package:logos_app/routing/routes.dart';
import 'package:logos_app/ui/auth/login_screen.dart';
import 'package:logos_app/ui/auth/sign_up_screen.dart';
import 'package:logos_app/ui/main/home/home_screen.dart';
import 'package:logos_app/ui/main/journey/journey_screen.dart';
import 'package:logos_app/ui/main/main_screen.dart';
import 'package:logos_app/ui/main/menu/menu_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true,
  routes: [
    // Shell wraps the 3 main tabs — keeps state alive across tab switches.
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainScreen(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: Routes.journey, builder: (context, state) => const JourneyScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: Routes.menu, builder: (context, state) => const MenuScreen())],
        ),
      ],
    ),

    // Auth routes — outside the shell (no bottom nav)
    GoRoute(path: Routes.login, builder: (context, state) => const LoginScreen()),
    GoRoute(path: Routes.signUp, builder: (context, state) => const SignUpScreen()),
  ],
);
