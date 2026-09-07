import 'package:prostuti/core/services/api_response.dart';
import 'package:prostuti/core/services/dio_service.dart';
import 'package:prostuti/core/services/error_handler.dart';
import 'package:prostuti/core/services/error_response.dart';
import 'package:prostuti/features/auth/category/model/category_constant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/otp_model.dart';

part 'signup_repo.g.dart';

@riverpod
SignupRepo signupRepo(SignupRepoRef ref) {
  final dioService = ref.watch(dioServiceProvider);
  return SignupRepo(dioService);
}

class SignupRepo {
  final DioService _dioService;

  SignupRepo(this._dioService);

  Future<ApiResponse> sendVerificationCode(
      {required String phoneNo, String type = "ACCOUNT_CREATION"}) async {
    final payload = {
      "phoneNumber": "+88$phoneNo",
      "phoneVerificationType": type
    };

    final response = await _dioService.postRequest(
        "/phone-verification/send-verification-code", payload);

    if (response.statusCode == 200) {
      return ApiResponse.success(response.data['success']);
    } else {
      final errorResponse = ErrorResponse.fromJson(response.data);
      ErrorHandler().setErrorMessage(errorResponse.message);
      return ApiResponse.error(errorResponse);
    }
  }

  Future<ApiResponse> verifyPhoneNumber(
      {required phoneNo, required code, required String type}) async {
    final payload = {
      "phoneNumber": phoneNo.toString(),
      "otpCode": code.toString(),
      "phoneVerificationType": type
    };

    final response = await _dioService.postRequest(
        "/phone-verification/verify-phone-number", payload);

    if (response.statusCode == 200) {
      return ApiResponse.success(OTP.fromJson(response.data));
    } else {
      final errorResponse = ErrorResponse.fromJson(response.data);
      ErrorHandler().setErrorMessage(errorResponse.message);
      return ApiResponse.error(errorResponse);
    }
  }

// Add this to your signup_repo.dart
  Future<ApiResponse> registerStudent(Map<String, dynamic> payload) async {
    try {
      // Ensure categoryType is included and is a valid value
      if (!payload.containsKey('categoryType') ||
          payload['categoryType'] == null ||
          payload['categoryType'].isEmpty) {
        return ApiResponse.error(ErrorResponse(
            message: "Category type is required", success: false));
      }

      // Validate that categoryType is one of the valid options
      if (!MainCategory.values.contains(payload['categoryType'])) {
        return ApiResponse.error(ErrorResponse(
            message:
                "Invalid category type. Must be one of: ${MainCategory.values.join(', ')}",
            success: false));
      }

      // Send the request
      final response =
          await _dioService.postRequest("/auth/register-student", payload);

      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        // Log the error for debugging
        print("Registration error: ${response.data}");

        final errorResponse = ErrorResponse.fromJson(response.data);
        ErrorHandler().setErrorMessage(errorResponse.message);
        return ApiResponse.error(errorResponse);
      }
    } catch (e) {
      // Log the exception
      print("Exception during registration: $e");

      ErrorHandler().setErrorMessage(e.toString());
      return ApiResponse.error(
          ErrorResponse(message: e.toString(), success: false));
    }
  }
}
