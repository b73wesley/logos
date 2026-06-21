/// Centralized app configuration.
/// Change [_env] to switch between environments.
class AppConfig {
  AppConfig._();

  static const _Env _env = _Env.local;

  static String get baseUrl => switch (_env) {
    _Env.local => 'http://10.0.2.2:8080',
    _Env.production => 'https://your-app.railway.app', // substitua pela URL real
  };
}

enum _Env { local, production }
