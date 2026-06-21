import 'package:logos_app/routing/routes.dart';
import 'package:logos_app/ui/main/main_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.root,
  debugLogDiagnostics: true,
  routes: [GoRoute(path: Routes.root, builder: (_, _) => const MainScreen(), routes: [
      ],
    )],
);
