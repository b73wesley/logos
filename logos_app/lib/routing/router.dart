import 'package:go_router/go_router.dart';
import 'package:logos_app/routing/routes.dart';
import 'package:logos_app/ui/auth/login_screen.dart';
import 'package:logos_app/ui/auth/sign_up_screen.dart';
import 'package:logos_app/ui/main/home_screen.dart';
import 'package:logos_app/ui/main/main_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.root,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: Routes.root, builder: (_, _) => const MainScreen()),
    GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
    GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
    GoRoute(path: Routes.signUp, builder: (_, _) => const SignUpScreen()),
  ],
);
