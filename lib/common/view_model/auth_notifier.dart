import 'package:dio/dio.dart';
import 'package:prostuti/features/auth/login/model/login_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../flutter_config.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  final baseUrl = FlavorConfig.instance.baseUrl;
  @override
  Future<String?> build() async {
    return await _loadAccessToken();
  }

  Future<void> setTokens({
    required String accessToken,
    required int accessExpiryTime,
    String? refreshToken,
    int? refreshExpiryTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setInt('accessExpiryTime', accessExpiryTime);
    if (refreshToken != null && refreshExpiryTime != null) {
      await prefs.setString('refreshToken', refreshToken);
      await prefs.setInt('refreshExpiryTime', refreshExpiryTime);
    }
    state = AsyncValue.data(accessToken);
  }

  /// The only keys a logout is allowed to destroy.
  ///
  /// This used to be `prefs.clear()`, which also wiped the user's chosen
  /// language, their recent searches, and (once the trial landed) their
  /// device-local trial progress — so signing out silently reset the UI to
  /// Bangla and handed out a fresh free trial. Removing the session keys by
  /// name keeps logout to what logout actually means.
  static const List<String> _sessionKeys = [
    'accessToken',
    'accessExpiryTime',
    'refreshToken',
    'refreshExpiryTime',
  ];

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _sessionKeys) {
      await prefs.remove(key);
    }
    state = const AsyncValue.data(null);
  }

  Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    final refreshExpiryTime = prefs.getInt('refreshExpiryTime');

    if (refreshToken != null && refreshExpiryTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (refreshExpiryTime > now) {
        try {
          final response = await Dio().post(
            '$baseUrl/auth/student/refresh-token',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final loginResponse = Login.fromJson(response.data);
            final accessToken = loginResponse.data!.accessToken!;
            final accessExpiryTime = DateTime.now()
                .add(Duration(
                    seconds: loginResponse.data!.accessTokenExpiresIn!))
                .millisecondsSinceEpoch;

            await setTokens(
              accessToken: accessToken,
              accessExpiryTime: accessExpiryTime,
              refreshToken: loginResponse.data!.refreshToken,
              refreshExpiryTime: loginResponse.data!.refreshTokenExpiresIn !=
                      null
                  ? DateTime.now()
                      .add(Duration(
                          seconds: loginResponse.data!.refreshTokenExpiresIn!))
                      .millisecondsSinceEpoch
                  : null,
            );

            return accessToken;
          }
        } catch (e) {
          await clearTokens();
        }
      } else {
        await clearTokens();
      }
    }
    return null;
  }

  Future<String?> _loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}
