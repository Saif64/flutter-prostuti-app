// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appConfigNotifierHash() => r'825ab2459f3d2a01b1f6786a1907d9f849828a7f';

/// The app configuration, fetched once per app session.
///
/// This provider never fails. `/config` is unauthenticated and global, and the
/// development flavor does not serve it at all, so any failure resolves to
/// [AppConfig.fallback] — trial off, no gating — rather than an error state the
/// UI would have to handle. Locking users out because a config request timed
/// out would be far worse than briefly letting them through.
///
/// Copied from [AppConfigNotifier].
@ProviderFor(AppConfigNotifier)
final appConfigNotifierProvider =
    AsyncNotifierProvider<AppConfigNotifier, AppConfig>.internal(
  AppConfigNotifier.new,
  name: r'appConfigNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appConfigNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppConfigNotifier = AsyncNotifier<AppConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
