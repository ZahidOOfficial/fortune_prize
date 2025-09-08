// ignore_for_file: unreachable_switch_default

import 'package:wheel_app/support/enums/e_error_code.dart';

/// Generic response container for handling data, success status, and HTTP status code.
class Response<T> {
  final T? data;
  final bool isSuccess;
  final int statusCode;
  final ErrorCode? errorCode;
  final String? errorMessage;

  Response(
    this.data,
    this.isSuccess,
    this.statusCode, {
    this.errorCode,
    this.errorMessage,
  });

  // Factory constructor for success responses
  factory Response.success(T? data, int statusCode) {
    return Response(data, true, statusCode);
  }

  // Factory constructor for failure responses
  factory Response.failure(
    int statusCode,
    ErrorCode errorCode, {
    String? errorMessage,
  }) {
    return Response(
      null,
      false,
      statusCode,
      errorCode: errorCode,
      errorMessage:
          errorMessage?.isEmpty ?? true
              ? _getErrorMessage(errorCode)
              : errorMessage,
    );
  }

  // Private method to map ErrorCode to error messages
  static String _getErrorMessage(ErrorCode errorCode) {
    switch (errorCode) {
      case ErrorCode.unsupportedMethod:
        return 'The requested method is not supported.';
      case ErrorCode.networkTimeout:
        return 'The network request timed out.';
      case ErrorCode.networkError:
        return 'A network error occurred. Please check your connection.';
      case ErrorCode.clientError:
        return 'A client-side error occurred.';
      case ErrorCode.serverError:
        return 'A server-side error occurred. Please try again later.';
      case ErrorCode.cacheError:
        return 'An error occurred while accessing cached data.';
      case ErrorCode.unknownError:
        return 'An unknown error occurred. Please try again.';
      case ErrorCode.internetError:
        return 'Please check your Internet connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
