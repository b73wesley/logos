import 'package:provider/single_child_widget.dart';

/// Registra todos os providers da aplicação.
/// Adicione novos providers aqui conforme as features forem implementadas.
///
/// Padrão:
/// - Services: Provider(create: (_) => ServiceImpl())
/// - Repositories: ProxyProvider (depende de um service)
/// - ViewModels: ChangeNotifierProxyProvider (depende de um repository)
List<SingleChildWidget> buildProviders() {
  return [
    // Auth — descomentar ao implementar a feature
    // Provider<AuthService>(create: (_) => AuthServiceImpl()),
    // ProxyProvider<AuthService, AuthRepository>(
    //   update: (_, service, __) => AuthRepositoryImpl(service),
    // ),
  ];
}
