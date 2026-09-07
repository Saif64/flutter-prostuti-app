import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/configs/app_urls.dart';
import 'flutter_config.dart';

/// Shared startup path for every flavor entrypoint.
///
/// Sets [FlavorConfig] from the URL table in [AppUrls] before the first widget
/// is built, so anything reading `FlavorConfig.instance` at construction time
/// finds it ready.
void bootstrap(Flavor flavor) {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig(
    flavor: flavor,
    name: flavor.label,
    baseUrl: AppUrls.apiBaseUrl(flavor),
    socketBaseUrl: AppUrls.socketBaseUrl(flavor),
  );

  runApp(const ProviderScope(child: MyApp()));
}
