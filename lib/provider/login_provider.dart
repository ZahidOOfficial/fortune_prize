// import 'package:wheel_app/model/configuration_response_model.dart';
// import 'package:wheel_app/provider/base_provider.dart';
// import 'package:wheel_app/support/network/response.dart';

// class LoginService extends BaseProvider {
//   Future<Response<List<ConfigurationResponseModel>>> getConfiguration(
//     String xApiKey,
//     String url,
//   ) {
//     return execute(
//       header: {'X-API-KEY': xApiKey},
//       baseUrlOverride: url,
//       parser: (json) {
//         if (json is List) {
//           // Agar API response ek list hai, toh uske har item ko parse karein
//           return json
//               .map((item) => ConfigurationResponseModel.fromJson(item))
//               .toList();
//         } else if (json is Map<String, dynamic>) {
//           // Agar ek single object hai, toh use bhi list me convert karein
//           return [ConfigurationResponseModel.fromJson(json)];
//         }
//         throw Exception("Unexpected JSON format");
//       },
//     );
//   }
// }
