import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prostuti/core/services/nav.dart';

import 'common/helpers/theme_provider.dart';
import 'core/configs/app_themes.dart';
import 'core/services/localization_service.dart';
import 'core/services/size_config.dart';
import 'features/splash_screen.dart';
import 'flutter_config.dart';
import 'l10n/app_localizations.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final currentLocale = ref.watch(localeProvider);
    SizeConfig.init(context);

    return MaterialApp(
      debugShowCheckedModeBanner: kDebugMode,
      title: 'Prostuti - ${FlavorConfig.instance.name}',
      navigatorKey: Nav().navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('bn'),
      ],
      home: const SplashScreen(),
    );
  }
}
