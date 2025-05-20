//     final dataResult = dataResultFromJson(jsonString);

import 'dart:convert';

DataResult1 dataResult1FromJson(String str) => DataResult1.fromJson(json.decode(str));

String dataResult1ToJson(DataResult1 data) => json.encode(data.toJson());

class DataResult1 {
  String? message;

  DataResult1({
    required this.message,
  });

  factory DataResult1.fromJson(Map<String, dynamic> json) => DataResult1(
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "Message": message,
  };
}






DataResult2 dataResult2FromJson(String str) => DataResult2.fromJson(json.decode(str));

String dataResult2ToJson(DataResult2 data) => json.encode(data.toJson());

class DataResult2 {
  bool success;
  String? message;

  DataResult2({
    required this.success,
    required this.message,
  });

  factory DataResult2.fromJson(Map<String, dynamic> json) => DataResult2(
    success: json["Success"],
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "Success": success,
    "Message": message,
  };
}



DataResult3 dataResult3FromJson(String str) => DataResult3.fromJson(json.decode(str));

String dataResult3ToJson(DataResult3 data) => json.encode(data.toJson());

class DataResult3 {
  bool success;
  String? userMessage;
  dynamic result;

  DataResult3({
    required this.success,
    required this.userMessage,
    required this.result,
  });

  factory DataResult3.fromJson(Map<String, dynamic> json) => DataResult3(
    success: json["Success"],
    userMessage: json["UserMessage"],
    result: json["Result"],
  );

  Map<String, dynamic> toJson() => {
    "Success": success,
    "UserMessage": userMessage,
    "Result": result,
  };
}




DataResult4 dataResult4FromJson(String str) => DataResult4.fromJson(json.decode(str));

String dataResult4ToJson(DataResult4 data) => json.encode(data.toJson());

class DataResult4 {
  bool success;
  dynamic userMessage;
  dynamic result;

  DataResult4({
    required this.success,
    required this.userMessage,
    required this.result,
  });

  factory DataResult4.fromJson(Map<String, dynamic> json) => DataResult4(
    success: json["Success"],
    userMessage: json["UserMessage"],
    result: json["Result"],
  );

  Map<String, dynamic> toJson() => {
    "Success": success,
    "UserMessage": userMessage,
    "Result": result,
  };
}
