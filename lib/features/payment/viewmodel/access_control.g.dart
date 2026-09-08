// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_control.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accessControlHash() => r'ed6190caf7d3448a2934e8deaca9ee07cadfc71d';

/// Decides what a user may reach before they subscribe.
///
/// This is a client-side stand-in for state the backend does not yet expose.
/// Two compromises are baked in, both documented where they are relied on:
///
/// * **The trial clock is anchored to the student's `createdAt`** from
///   `/user/profile`, because the backend has no per-user trial record. Being
///   server-side, it survives reinstalls and holds across devices. Accounts
///   older than the config document predate the feature and fall back to a
///   device-local first-seen timestamp instead.
/// * **Usage against `featureLimits` is counted on the device**
///   ([TrialStorage]), because nothing reports consumption. It survives logout
///   but not a data wipe, and a second device starts fresh.
///
/// Nothing here is enforced by the API, so treat it as a product gate, not a
/// security boundary.
///
/// Copied from [AccessControl].
@ProviderFor(AccessControl)
final accessControlProvider =
    AutoDisposeAsyncNotifierProvider<AccessControl, TrialStatus>.internal(
  AccessControl.new,
  name: r'accessControlProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accessControlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccessControl = AutoDisposeAsyncNotifier<TrialStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
