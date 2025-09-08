import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:wheel_app/support/enums/e_error_code.dart';
import 'package:wheel_app/support/enums/e_http_method.dart';
import 'package:wheel_app/support/network/response.dart';

abstract class BaseProvider {
  /// default base url
  final String defaultBaseUrl = 'https://config.ted-solutions.com';
  final Duration requestTimeout = Duration(minutes: 20);

  Future<Response<T>> execute<T>({
    String endpoint = "",
    HttpMethod method = HttpMethod.get,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? header,
    String? pathParameter,
    String? baseUrlOverride,
    Function(dynamic)? toCache,
    T Function(dynamic)? parser,
    Future<T> Function()? fromCache,
    String? contentType,
    String? token,
    bool snapShot = false,
  }) async {
    String url = '${baseUrlOverride ?? defaultBaseUrl}$endpoint';
    if (pathParameter != null) {
      url += '/$pathParameter';
    }
    var uri = Uri.parse(url).replace(queryParameters: queryParameters);
    debugPrint('Executing request:  $uri');
    Map<String, String> headers =
        header ?? {'Content-Type': contentType ?? 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      http.Response response;

      String? bodyString = body != null ? jsonEncode(body) : null;

      /// Execute the HTTP request
      switch (method) {
        case HttpMethod.get:
          response = await http
              .get(uri, headers: headers)
              .timeout(requestTimeout);
          break;

        case HttpMethod.delete:
          response = await http
              .delete(uri, headers: headers)
              .timeout(requestTimeout);
          break;

        case HttpMethod.post:
          response = await http.post(
            uri,
            headers: headers,
            body: contentType != 'application/json' ? body : bodyString,
          );

          break;

        case HttpMethod.put:
          response = await http.put(
            uri,
            headers: headers,
            body: contentType != 'application/json' ? body : bodyString,
          );

          break;
      }

      // Process the response
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        if (response.body.isEmpty) {
          return Response.success(null, response.statusCode);
        }
        dynamic responseBody = jsonDecode(response.body);

        if (toCache != null) {
          toCache(responseBody);
        }

        T result = parser != null ? parser(responseBody) : responseBody as T;

        return Response.success(result, response.statusCode);
      } else {
        ErrorCode errorCode =
            response.statusCode >= 400
                ? ErrorCode.serverError
                : ErrorCode.clientError;
        return Response.failure(
          response.statusCode,
          errorCode,
          errorMessage:
              jsonDecode(response.body)["error_description"] ??
              jsonDecode(response.body)["Message"] ??
              "",
        );
      }
    } on SocketException {
      /// Handle no internet connection
      ErrorCode errorCode = ErrorCode.networkError;

      /// Attempt to retrieve data from cache if the request fails and fromCache is provided
      if (fromCache != null) {
        try {
          T? cachedData = await fromCache();
          if (cachedData != null) {
            return Response.success(cachedData, 200);
          }
        } catch (cacheError) {
          debugPrint('Cache retrieval error: $cacheError');
        }
      }

      /// Save request snapshot if snapShot is true and return success response
      if (snapShot) {
        await saveRequestSnapshot(
          url: url,
          method: method.name,
          headers: headers,
          body: jsonDecode(body),
          queryParams: queryParameters,
          pathParam: pathParameter,
          timestamp: DateTime.now(),
        );
        return Response.success(null, 200);
      }

      return Response.failure(400, errorCode);
    } catch (e) {
      /// Handle other exceptions
      debugPrint('Request exception: $e');
      ErrorCode errorCode = ErrorCode.unknownError;

      /// Attempt to retrieve data from cache if the request fails and fromCache is provided
      if (fromCache != null) {
        try {
          T? cachedData = await fromCache();
          if (cachedData != null) {
            return Response.success(cachedData, 200);
          }
        } catch (cacheError) {
          debugPrint('Cache retrieval error: $cacheError');
        }
      }

      return Response.failure(400, errorCode);
    }
  }

  Future<void> toCache(String key, dynamic data) async {
    var box = await Hive.openBox('newsbox');
    try {
      String jsonData = json.encode(data);
      await box.put(key, jsonData);
      debugPrint('Data cached successfully for key $key');
    } catch (e) {
      debugPrint('Failed to cache data: $e');
    }
  }

  Future<T> fromCache<T>(String key, T Function(dynamic) fromJson) async {
    var box = await Hive.openBox('newsbox');
    try {
      String? jsonData = box.get(key);
      if (jsonData != null) {
        return fromJson(json.decode(jsonData));
      } else {
        throw Exception('No data found in cache for key: $key');
      }
    } catch (e) {
      debugPrint('Failed to retrieve data from cache: $e');
      throw Exception('Error retrieving data from cache: $e');
    }
  }

  Future<void> saveRequestSnapshot({
    required String url,
    required String method,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    String? pathParam,
    required DateTime timestamp,
  }) async {
    var box = await Hive.openBox('requestBox');

    var requestSnapshot = {
      'url': url,
      'method': method,
      'headers': headers,
      'body': body,
      'queryParams': queryParams,
      'pathParam': pathParam,
      'timestamp': timestamp.toString(),
    };
    await box.add(requestSnapshot);
  }

  Future<void> syncRequests() async {
    var box = await Hive.openBox('requestBox');
    List<dynamic> requests = box.values.toList();

    // Collect the keys to avoid index shifting while deleting
    var keys = box.keys.toList();

    for (int i = 0; i < requests.length; i++) {
      var request = requests[i];
      try {
        await execute(
          baseUrlOverride: request['url'],
          method:
              request['method'] == 'HttpMethod.get'
                  ? HttpMethod.get
                  : HttpMethod.post,
          header:
              request['headers'] != null
                  ? (request['headers'] as Map).map(
                    (key, value) => MapEntry(key.toString(), value.toString()),
                  )
                  : null,
          body: jsonEncode(request['body']),
          queryParameters: request['queryParams'],
          pathParameter: request['pathParam'],
        );

        // Use the key instead of index
        await box.delete(keys[i]);
      } catch (e) {
        debugPrint('Failed to sync request: $e');
      }
    }
  }
}
