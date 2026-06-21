import 'package:logos_app/data/repositories/authImpl/auth_repository_impl.dart';
import 'package:logos_app/data/services/authImpl/auth_service_impl.dart';
import 'package:logos_app/domain/auth/auth_repository.dart';
import 'package:logos_app/ui/auth/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Registra todos os providers da aplicação.
/// Padrão:
/// - Services: Provider (stateless, sem notifyListeners)
/// - Repositories: ProxyProvider (depende de um service)
/// - ViewModels: ChangeNotifierProxyProvider (depende de um repository)
List<SingleChildWidget> buildProviders() {
  return [
    // Auth
    Provider(create: (_) => AuthServiceImpl()),
    ProxyProvider<AuthServiceImpl, AuthRepository>(update: (_, service, __) => AuthRepositoryImpl(service)),
    ChangeNotifierProxyProvider<AuthRepository, AuthViewModel>(
      create: (ctx) => AuthViewModel(ctx.read<AuthRepository>()),
      update: (_, repository, previous) => previous ?? AuthViewModel(repository),
    ),
  ];
}
