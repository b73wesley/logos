import 'package:logos_app/data/repositories/annotationImpl/annotation_repository_impl.dart';
import 'package:logos_app/data/repositories/authImpl/auth_repository_impl.dart';
import 'package:logos_app/data/repositories/bibleImpl/bible_repository_impl.dart';
import 'package:logos_app/data/services/annotationImpl/annotation_service_impl.dart';
import 'package:logos_app/data/services/authImpl/auth_service_impl.dart';
import 'package:logos_app/data/services/bibleImpl/bible_service_impl.dart';
import 'package:logos_app/domain/annotation/annotation_repository.dart';
import 'package:logos_app/domain/auth/auth_repository.dart';
import 'package:logos_app/domain/bible/bible_repository.dart';
import 'package:logos_app/core/preferences.dart';
import 'package:logos_app/ui/auth/view_model/auth_view_model.dart';
import 'package:logos_app/ui/main/home/annotation_view_model.dart';
import 'package:logos_app/ui/main/home/home_view_model.dart';
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
      update: (_, repository, vm) => vm ?? AuthViewModel(repository),
    ),

    // Bible
    Provider(create: (_) => BibleServiceImpl()),
    ProxyProvider<BibleServiceImpl, BibleRepository>(
      update: (_, service, __) => BibleRepositoryImpl(service),
    ),
    ChangeNotifierProxyProvider<BibleRepository, HomeViewModel>(
      create: (ctx) => HomeViewModel(ctx.read<BibleRepository>(), Preferences()),
      update: (_, repository, vm) => vm ?? HomeViewModel(repository, Preferences()),
    ),

    // Annotations
    Provider(create: (_) => AnnotationServiceImpl()),
    ProxyProvider<AnnotationServiceImpl, AnnotationRepository>(
      update: (_, service, __) => AnnotationRepositoryImpl(service),
    ),
    ChangeNotifierProxyProvider<AnnotationRepository, AnnotationViewModel>(
      create: (ctx) => AnnotationViewModel(ctx.read<AnnotationRepository>()),
      update: (_, repository, vm) => vm ?? AnnotationViewModel(repository),
    ),
  ];
}
