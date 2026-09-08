import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/app_config.dart';
import '../repository/app_config_repo.dart';

part 'app_config_viewmodel.g.dart';

/// The app configuration, fetched once per app session.
///
/// This provider never fails. `/config` is unauthenticated and global, and the
/// development flavor does not serve it at all, so any failure resolves to
/// [AppConfig.fallback] — trial off, no gating — rather than an error state the
/// UI would have to handle. Locking users out because a config request timed
/// out would be far worse than briefly letting them through.
@Riverpod(keepAlive: true)
class AppConfigNotifier extends _$AppConfigNotifier {
  @override
  Future<AppConfig> build() async {
    final result = await ref.read(appConfigRepoProvider).getAppConfig();
    return result.fold((_) => AppConfig.fallback, (config) => config);
  }

  /// Re-fetches the configuration, e.g. after a subscription completes.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(appConfigRepoProvider).getAppConfig();
      return result.fold((_) => AppConfig.fallback, (config) => config);
    });
  }
}
