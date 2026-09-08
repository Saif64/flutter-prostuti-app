/// The app-wide configuration served by `GET /api/v1/config`.
///
/// This is a single global document — it is NOT user-scoped (the same payload
/// comes back with or without an `Authorization` header), so nothing here says
/// anything about a *particular* user's trial. Per-user state is resolved in
/// [AccessControl] instead.
class AppConfig {
  final bool isTrialEnabled;
  final int freeTrialDays;

  /// Features the backend advertises as free during the trial.
  ///
  /// The API sends human-readable display labels ("Mock Tests", "Live
  /// Classes"), not stable keys, so these are normalised into [FreeFeature]
  /// rather than compared as raw strings.
  final Set<FreeFeature> freeAccessFeatures;

  /// Per-feature usage caps, keyed by the API's own field names.
  ///
  /// Only [maxMockTests] is actually enforceable today — see [FreeFeature].
  final int? maxMockTests;
  final int? maxLiveClasses;

  final String supportMobileNumber;

  /// When the config document itself was created.
  ///
  /// Used as the trial epoch: an account created before the trial feature
  /// existed cannot fairly have its clock started at signup, so those fall back
  /// to a device-local anchor instead. See [AccessControl].
  final DateTime? configCreatedAt;

  const AppConfig({
    required this.isTrialEnabled,
    required this.freeTrialDays,
    required this.freeAccessFeatures,
    this.maxMockTests,
    this.maxLiveClasses,
    this.supportMobileNumber = '',
    this.configCreatedAt,
  });

  /// What the app assumes when `/config` cannot be reached.
  ///
  /// Deliberately permissive: a backend outage (or the development flavor,
  /// which has no `/config` route at all) must never lock a paying user out of
  /// the app. Trial off + everything free = the pre-trial behaviour the app
  /// shipped with.
  static const AppConfig fallback = AppConfig(
    isTrialEnabled: false,
    freeTrialDays: 0,
    freeAccessFeatures: <FreeFeature>{},
  );

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final limits = data['featureLimits'] as Map<String, dynamic>? ?? const {};

    final features = <FreeFeature>{};
    for (final raw in (data['freeAccessFeatures'] as List<dynamic>? ?? const [])) {
      final feature = FreeFeature.fromLabel(raw?.toString() ?? '');
      if (feature != null) features.add(feature);
    }

    return AppConfig(
      isTrialEnabled: data['isTrialEnabled'] as bool? ?? false,
      freeTrialDays: (data['freeTrialDays'] as num?)?.toInt() ?? 0,
      freeAccessFeatures: features,
      maxMockTests: (limits['maxMockTests'] as num?)?.toInt(),
      maxLiveClasses: (limits['maxLiveClasses'] as num?)?.toInt(),
      supportMobileNumber: data['supportMobileNumber'] as String? ?? '',
      configCreatedAt: DateTime.tryParse(data['createdAt']?.toString() ?? ''),
    );
  }

  /// The cap for [feature], or `null` when the backend sets none (which means
  /// unlimited — "Recorded Videos" is advertised as free but has no limit).
  int? limitFor(FreeFeature feature) => switch (feature) {
        FreeFeature.mockTest => maxMockTests,
        FreeFeature.liveClass => maxLiveClasses,
        FreeFeature.recordedVideo => null,
      };

  bool isFree(FreeFeature feature) => freeAccessFeatures.contains(feature);
}

/// The features `freeAccessFeatures` can name, normalised away from the API's
/// display labels.
///
/// NOTE: [liveClass] has no implementation in this app and no route on the
/// backend — it is parsed so the config round-trips faithfully, but nothing
/// gates on it. Remove it once the backend drops it from the payload.
enum FreeFeature {
  mockTest,
  liveClass,
  recordedVideo;

  /// Matches the backend's display label case- and whitespace-insensitively.
  ///
  /// This is deliberately tolerant because the label is admin-editable: it will
  /// still break if someone renames "Mock Tests" to something unrelated, which
  /// is why the backend should be sending stable keys instead.
  static FreeFeature? fromLabel(String label) {
    final key = label.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return switch (key) {
      'mocktest' || 'mocktests' => FreeFeature.mockTest,
      'liveclass' || 'liveclasses' => FreeFeature.liveClass,
      'recordedvideo' ||
      'recordedvideos' ||
      'recordedclass' ||
      'recordedclasses' =>
        FreeFeature.recordedVideo,
      _ => null,
    };
  }
}
