import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/config/model/app_config.dart';

part 'trial_storage.g.dart';

@riverpod
TrialStorage trialStorage(TrialStorageRef ref) => TrialStorage();

/// Device-local, per-user bookkeeping for the free-trial journey.
///
/// The backend has no per-user trial or usage state: `GET /config` is a single
/// global document, and `/user/profile` carries only subscription dates. So the
/// two things the trial gate needs — when a user's clock started, and how much
/// of a capped feature they have spent — are tracked here instead.
///
/// **Every key is scoped to a user id**, so two accounts sharing a phone keep
/// separate counters and logging back in restores your own.
///
/// **These keys deliberately survive logout.** `AuthNotifier.clearTokens()`
/// removes only the four token keys, so signing out no longer resets a trial
/// (it also no longer resets the user's chosen language). They do not survive
/// "Clear data", and on iOS they do not survive reinstall; on Android they may
/// or may not, depending on Google auto-backup. Those are known, accepted holes
/// — this is a client-side stand-in until the backend can report usage itself.
class TrialStorage {
  /// Namespace for every key this class owns. Versioned so the shape can change
  /// later without colliding with data already on a device.
  static const String keyPrefix = 'prostuti.trial.v1';

  static String _firstSeenKey(String userId) =>
      '$keyPrefix.$userId.firstSeenAt';

  static String _usageKey(String userId, FreeFeature feature) =>
      '$keyPrefix.$userId.used.${feature.name}';

  /// The first moment this device saw [userId], recording it if this is the
  /// first call.
  ///
  /// Only used as a trial anchor for legacy accounts whose server-side
  /// `createdAt` predates the trial feature — see [AccessControl]. For everyone
  /// else the server's `createdAt` wins, because it survives reinstalls and
  /// works across devices.
  Future<DateTime> firstSeenAt(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_firstSeenKey(userId));
    if (stored != null) {
      return DateTime.fromMillisecondsSinceEpoch(stored);
    }

    final now = DateTime.now();
    await prefs.setInt(_firstSeenKey(userId), now.millisecondsSinceEpoch);
    return now;
  }

  /// How many times [userId] has consumed [feature] on this device.
  Future<int> usage(String userId, FreeFeature feature) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_usageKey(userId, feature)) ?? 0;
  }

  /// Records one more use of [feature] and returns the new total.
  ///
  /// Call this only once the action actually succeeded, so a failed request
  /// does not burn an allowance.
  Future<int> recordUsage(String userId, FreeFeature feature) async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_usageKey(userId, feature)) ?? 0) + 1;
    await prefs.setInt(_usageKey(userId, feature), next);
    return next;
  }

  /// Wipes this device's trial bookkeeping for [userId].
  ///
  /// Intended for the moment a user actually subscribes, so that a later lapse
  /// starts from a clean slate rather than an exhausted one.
  Future<void> clearFor(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstSeenKey(userId));
    for (final feature in FreeFeature.values) {
      await prefs.remove(_usageKey(userId, feature));
    }
  }
}
