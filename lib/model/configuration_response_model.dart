class ConfigurationResponseModel {
  ConfigurationResponseModel({
    this.id,
    this.companyCode,
    this.key,
    this.value,
    this.usedFor,
  });

  final int? id;
  final String? companyCode;
  final String? key;
  final String? value;
  final String? usedFor;

  factory ConfigurationResponseModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationResponseModel(
      id: json["id"],
      companyCode: json["companyCode"],
      key: json["key"],
      value: json["value"],
      usedFor: json["usedFor"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "companyCode": companyCode,
      "key": key,
      "value": value,
      "usedFor": usedFor,
    };
  }

  static List<ConfigurationResponseModel> parseConfigurationFromJson(
      Map<String, dynamic> json) {
    return [ConfigurationResponseModel.fromJson(json)];
  }
}
