import '../../flutter_config.dart';

/// Every backend address the app talks to, in one table.
///
/// This is the single source of truth for hosts. Nothing else in the app should
/// contain a hard-coded URL — if you find one, move it here.
class AppUrls {
  const AppUrls._();

  /// The API/socket host, per flavor.
  ///
  /// NOTE: production has no host of its own. It points at staging, which is
  /// what the app has always shipped with. Replace the production entry once a
  /// production backend exists — every production build talks to staging until
  /// then.
  static const Map<Flavor, String> _apiHost = {
    Flavor.development: 'https://resilient-heart-dev.up.railway.app',
    Flavor.staging: 'https://resilient-heart-staging.up.railway.app',
    Flavor.production: 'https://resilient-heart-staging.up.railway.app',
  };

  /// The admin dashboard that handles payment redirects, per flavor.
  ///
  /// NOTE: same gap as above — production points at the staging dashboard, so
  /// production payments currently resolve through staging.
  static const Map<Flavor, String> _paymentHost = {
    Flavor.development:
        'https://prostuti-app-teacher-admin-dashb-staging.up.railway.app',
    Flavor.staging:
        'https://prostuti-app-teacher-admin-dashb-staging.up.railway.app',
    Flavor.production:
        'https://prostuti-app-teacher-admin-dashb-staging.up.railway.app',
  };

  static String apiBaseUrl(Flavor flavor) => '${_apiHost[flavor]!}/api/v1';

  static String socketBaseUrl(Flavor flavor) => _apiHost[flavor]!;

  static String _payment(Flavor flavor) => _paymentHost[flavor]!;

  // Payment redirect targets for the flavor the app is currently running as.
  // The checkout webview matches the browser URL against these to decide the
  // outcome of a transaction.
  static String get paymentSuccess =>
      '${_payment(FlavorConfig.instance.flavor)}/payment/success';

  static String get paymentFailed =>
      '${_payment(FlavorConfig.instance.flavor)}/payment/failed';

  static String get paymentCancelled =>
      '${_payment(FlavorConfig.instance.flavor)}/payment/cancelled';
}
