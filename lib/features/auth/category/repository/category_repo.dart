import 'package:prostuti/core/services/api_response.dart';
import 'package:prostuti/core/services/dio_service.dart';
import 'package:prostuti/core/services/error_handler.dart';
import 'package:prostuti/core/services/error_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_repo.g.dart';

@riverpod
CategoryRepo categoryRepo(CategoryRepoRef ref) {
  final dioService = ref.watch(dioServiceProvider);
  return CategoryRepo(dioService);
}

class CategoryRepo {
  final DioService _dioService;

  CategoryRepo(this._dioService);

  /// Updates the signed-in student's category.
  ///
  /// Note the payload key is `mainCategory`, not `categoryType` — the two
  /// endpoints disagree on the name for the same value, and this is the shape
  /// this one accepts.
  Future<ApiResponse> updateStudentCategory(String categoryType) async {
    final response = await _dioService.patchRequest(
      "/student/update-category",
      data: {"mainCategory": categoryType},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(response.data);
    }

    final errorResponse = ErrorResponse.fromJson(response.data);
    ErrorHandler().setErrorMessage(errorResponse.message);
    return ApiResponse.error(errorResponse);
  }
}
