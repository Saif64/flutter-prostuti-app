enum Flavor {
  development,
  staging,
  production;

  /// Human-readable name, shown in the app title.
  String get label => switch (this) {
        Flavor.development => 'Development',
        Flavor.staging => 'Staging',
        Flavor.production => 'Production',
      };
}

/// Flavor-scoped configuration, set once during [bootstrap] before the app runs.
class FlavorConfig {
  final Flavor flavor;
  final String name;
  final String baseUrl;
  final String socketBaseUrl;

  static FlavorConfig? _instance;

  factory FlavorConfig({
    required Flavor flavor,
    required String name,
    required String baseUrl,
    required String socketBaseUrl,
  }) {
    _instance = FlavorConfig._internal(
      flavor: flavor,
      name: name,
      baseUrl: baseUrl,
      socketBaseUrl: socketBaseUrl,
    );
    return _instance!;
  }

  FlavorConfig._internal({
    required this.flavor,
    required this.name,
    required this.baseUrl,
    required this.socketBaseUrl,
  });

  static FlavorConfig get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError(
        'FlavorConfig was read before it was set. The app must be started from '
        'a flavor entrypoint, e.g. '
        '`flutter run --flavor development -t lib/main_development.dart`.',
      );
    }
    return instance;
  }

  static bool isProduction() => instance.flavor == Flavor.production;

  static bool isStaging() => instance.flavor == Flavor.staging;

  static bool isDevelopment() => instance.flavor == Flavor.development;
}
