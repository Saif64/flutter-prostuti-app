import 'package:flutter_test/flutter_test.dart';
import 'package:prostuti/core/configs/app_urls.dart';
import 'package:prostuti/flutter_config.dart';

void main() {
  group('AppUrls', () {
    test('every flavor resolves an API base URL ending in /api/v1', () {
      for (final flavor in Flavor.values) {
        expect(AppUrls.apiBaseUrl(flavor), endsWith('/api/v1'));
        expect(AppUrls.socketBaseUrl(flavor), startsWith('https://'));
      }
    });

    test('development and staging point at their own hosts', () {
      expect(AppUrls.apiBaseUrl(Flavor.development), contains('-dev.'));
      expect(AppUrls.apiBaseUrl(Flavor.staging), contains('-staging.'));
    });

    // Production has no backend of its own yet, so it deliberately points at
    // staging. This test documents that gap: when a production host is
    // deployed, update AppUrls and this expectation together.
    test('production still points at staging (known gap)', () {
      expect(
        AppUrls.apiBaseUrl(Flavor.production),
        AppUrls.apiBaseUrl(Flavor.staging),
      );
    });
  });

  group('FlavorConfig', () {
    test('reports the flavor it was built with', () {
      FlavorConfig(
        flavor: Flavor.staging,
        name: Flavor.staging.label,
        baseUrl: AppUrls.apiBaseUrl(Flavor.staging),
        socketBaseUrl: AppUrls.socketBaseUrl(Flavor.staging),
      );

      expect(FlavorConfig.isStaging(), isTrue);
      expect(FlavorConfig.isProduction(), isFalse);
      expect(FlavorConfig.instance.name, 'Staging');
    });
  });
}
