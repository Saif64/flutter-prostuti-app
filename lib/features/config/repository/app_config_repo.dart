import 'package:dartz/dartz.dart';
import 'package:prostuti/core/services/dio_service.dart';
import 'package:prostuti/core/services/error_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/app_config.dart';

part 'app_config_repo.g.dart';

@riverpod
AppConfigRepo appConfigRepo(AppConfigRepoRef ref) {
  final dioService = ref.watch(dioServiceProvider);
  return AppConfigRepo(dioService);
}

class AppConfigRepo {
  final DioService _dioService;

  AppConfigRepo(this._dioService);

  /// `GET /config` — the global app configuration.
  ///
  /// Unlike the other repos this one does NOT push the failure into
  /// [ErrorHandler]: a missing config is not something the user can act on, and
  /// the caller falls back to [AppConfig.fallback] rather than surfacing an
  /// error. The development flavor has no `/config` route at all and answers
  /// 400, so the failure path is the normal path there.
  Future<Either<ErrorResponse, AppConfig>> getAppConfig() async {
    final response = await _dioService.getRequest("/config");

    if (response.statusCode == 200) {
      try {
        return Right(AppConfig.fromJson(response.data));
      } catch (e) {
        return Left(ErrorResponse(
          success: false,
          message: "Could not parse app configuration: $e",
        ));
      }
    }

    return Left(ErrorResponse(
      success: false,
      message: response.data is Map
          ? ErrorResponse.fromJson(response.data).message
          : "Could not load app configuration",
    ));
  }
}
