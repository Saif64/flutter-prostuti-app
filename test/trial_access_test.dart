import 'package:flutter_test/flutter_test.dart';
import 'package:prostuti/features/config/model/app_config.dart';
import 'package:prostuti/features/payment/viewmodel/access_control.dart';

/// The exact body `GET /api/v1/config` returns on staging, captured verbatim.
///
/// Pinned here so a change to the contract — a renamed label, a dropped limit,
/// a new free feature — fails a test instead of silently changing who gets
/// gated. Re-capture it if the backend deliberately changes shape.
const Map<String, dynamic> _stagingConfigResponse = {
  "success": true,
  "message": "App configuration retrieved successfully",
  "data": {
    "supportMobileNumber": "",
    "_id": "6a920975f7277badf8d3d4d6",
    "isTrialEnabled": true,
    "freeTrialDays": 7,
    "freeAccessFeatures": ["Mock Tests", "Live Classes", "Recorded Videos"],
    "createdAt": "2026-08-28T22:19:33.618Z",
    "updatedAt": "2026-08-28T22:19:46.940Z",
    "__v": 0,
    "featureLimits": {"maxMockTests": 56, "maxLiveClasses": 56}
  }
};

TrialStatus _trial(
  AppConfig config, {
  Map<FreeFeature, int> usage = const {},
  Duration remaining = const Duration(days: 3),
}) =>
    TrialStatus(
      tier: AccessTier.trial,
      config: config,
      trialEndsAt: DateTime.now().add(remaining),
      usage: usage,
    );

void main() {
  group('AppConfig.fromJson against the live staging payload', () {
    final config = AppConfig.fromJson(_stagingConfigResponse);

    test('reads the trial switch and window', () {
      expect(config.isTrialEnabled, isTrue);
      expect(config.freeTrialDays, 7);
    });

    test('normalises the display labels onto stable keys', () {
      expect(
        config.freeAccessFeatures,
        {FreeFeature.mockTest, FreeFeature.liveClass, FreeFeature.recordedVideo},
      );
    });

    test('reads featureLimits', () {
      expect(config.maxMockTests, 56);
      expect(config.maxLiveClasses, 56);
    });

    test('treats a free feature with no limit as uncapped', () {
      // The backend lists "Recorded Videos" as free but sets no cap for it.
      expect(config.isFree(FreeFeature.recordedVideo), isTrue);
      expect(config.limitFor(FreeFeature.recordedVideo), isNull);
    });

    test('captures the config creation date used as the trial epoch', () {
      expect(config.configCreatedAt, DateTime.parse('2026-08-28T22:19:33.618Z'));
    });
  });

  group('FreeFeature.fromLabel', () {
    test('is tolerant of case, spacing and singular/plural', () {
      for (final label in ['Mock Tests', 'mock test', 'MOCKTESTS', ' Mock-Tests ']) {
        expect(FreeFeature.fromLabel(label), FreeFeature.mockTest, reason: label);
      }
      expect(FreeFeature.fromLabel('Recorded Classes'), FreeFeature.recordedVideo);
    });

    test('drops labels it does not recognise rather than guessing', () {
      expect(FreeFeature.fromLabel('Podcasts'), isNull);
      expect(FreeFeature.fromLabel(''), isNull);
    });
  });

  group('malformed or partial config', () {
    test('missing fields degrade to a closed-but-harmless config', () {
      final config = AppConfig.fromJson({'data': <String, dynamic>{}});
      expect(config.isTrialEnabled, isFalse);
      expect(config.freeTrialDays, 0);
      expect(config.freeAccessFeatures, isEmpty);
      expect(config.maxMockTests, isNull);
    });

    test('an unparseable body does not throw', () {
      expect(() => AppConfig.fromJson(const {}), returnsNormally);
    });

    test('the fallback grants access, so an outage never locks users out', () {
      const status =
          TrialStatus(tier: AccessTier.unrestricted, config: AppConfig.fallback);
      expect(status.accessTo(FreeFeature.mockTest).allowed, isTrue);
      expect(status.shouldPromptSubscription, isFalse);
    });
  });

  group('supportMobileNumber', () {
    test('the live payload currently ships it empty', () {
      // Staging serves "" until an admin fills it in. There is deliberately no
      // hardcoded fallback, so the contact buttons stay hidden until then.
      final config = AppConfig.fromJson(_stagingConfigResponse);
      expect(config.supportMobileNumber, '');
      expect(config.hasSupportNumber, isFalse);
    });

    test('a missing field is treated as empty, never null', () {
      expect(AppConfig.fromJson(const {}).supportMobileNumber, '');
      expect(AppConfig.fallback.supportMobileNumber, '');
      expect(AppConfig.fallback.hasSupportNumber, isFalse);
    });

    test('whitespace alone does not count as a number', () {
      final config = AppConfig.fromJson({
        'data': {'supportMobileNumber': '   '}
      });
      expect(config.hasSupportNumber, isFalse);
    });

    test('a configured number is reported as present', () {
      final config = AppConfig.fromJson({
        'data': {'supportMobileNumber': '01640521788'}
      });
      expect(config.hasSupportNumber, isTrue);
      expect(config.dialableSupportNumber, '01640521788');
    });

    test('however an admin formats it, it reduces to something dialable', () {
      const entries = {
        '+880 1640-521788': '+8801640521788',
        '01640-521788': '01640521788',
        '(017) 1234 5678': '01712345678',
      };
      entries.forEach((typed, dialable) {
        final config = AppConfig.fromJson({
          'data': {'supportMobileNumber': typed}
        });
        expect(config.dialableSupportNumber, dialable, reason: typed);
        // The raw entry survives for display.
        expect(config.supportMobileNumber, typed);
      });
    });
  });

  group('access decisions', () {
    final config = AppConfig.fromJson(_stagingConfigResponse);

    test('a subscriber is never gated', () {
      final status = TrialStatus(tier: AccessTier.subscribed, config: config);
      for (final feature in FreeFeature.values) {
        expect(status.accessTo(feature).allowed, isTrue, reason: feature.name);
      }
      expect(status.shouldPromptSubscription, isFalse);
    });

    test('a trial user under the cap is allowed, and sees what is left', () {
      final access = _trial(config, usage: {FreeFeature.mockTest: 10})
          .accessTo(FreeFeature.mockTest);

      expect(access.allowed, isTrue);
      expect(access.reason, AccessReason.withinTrial);
      expect(access.used, 10);
      expect(access.limit, 56);
      expect(access.remaining, 46);
    });

    test('a trial user at the cap is blocked', () {
      final access = _trial(config, usage: {FreeFeature.mockTest: 56})
          .accessTo(FreeFeature.mockTest);

      expect(access.allowed, isFalse);
      expect(access.reason, AccessReason.limitReached);
      expect(access.remaining, 0);
    });

    test('remaining never goes negative past the cap', () {
      final access = _trial(config, usage: {FreeFeature.mockTest: 99})
          .accessTo(FreeFeature.mockTest);
      expect(access.remaining, 0);
      expect(access.allowed, isFalse);
    });

    test('an uncapped free feature stays open however much it is used', () {
      final access = _trial(config, usage: {FreeFeature.recordedVideo: 9999})
          .accessTo(FreeFeature.recordedVideo);
      expect(access.allowed, isTrue);
      expect(access.reason, AccessReason.withinTrial);
    });

    test('a feature absent from freeAccessFeatures is closed during a trial', () {
      const bare = AppConfig(
        isTrialEnabled: true,
        freeTrialDays: 7,
        freeAccessFeatures: {FreeFeature.recordedVideo},
      );
      final access = _trial(bare).accessTo(FreeFeature.mockTest);
      expect(access.allowed, isFalse);
      expect(access.reason, AccessReason.notIncluded);
    });

    test('an expired trial closes everything and prompts to subscribe', () {
      final status = TrialStatus(
        tier: AccessTier.expired,
        config: config,
        trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      for (final feature in FreeFeature.values) {
        final access = status.accessTo(feature);
        expect(access.allowed, isFalse, reason: feature.name);
        expect(access.reason, AccessReason.trialExpired);
      }
      expect(status.shouldPromptSubscription, isTrue);
      expect(status.daysRemaining, 0);
    });
  });

  group('daysRemaining', () {
    final config = AppConfig.fromJson(_stagingConfigResponse);

    test('rounds a part-day up, so the last day still reads as 1', () {
      expect(_trial(config, remaining: const Duration(hours: 5)).daysRemaining, 1);
      expect(
          _trial(config, remaining: const Duration(hours: 30)).daysRemaining, 2);
    });

    test('is zero once the window has closed', () {
      final status = TrialStatus(
        tier: AccessTier.trial,
        config: config,
        trialEndsAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(status.daysRemaining, 0);
    });
  });
}
