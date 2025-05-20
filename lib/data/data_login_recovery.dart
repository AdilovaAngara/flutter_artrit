// To parse this JSON data, do
//
//     final dataLoginRecovery = dataLoginRecoveryFromJson(jsonString);

import 'dart:convert';

enum Enum {
  login,
  code,
  password,
  repeatPassword,
}

DataLoginRecovery dataLoginRecoveryFromJson(String str) => DataLoginRecovery.fromJson(json.decode(str));

String dataLoginRecoveryToJson(DataLoginRecovery data) => json.encode(data.toJson());

class DataLoginRecovery {
  String email;

  DataLoginRecovery({
    required this.email,
  });

  factory DataLoginRecovery.fromJson(Map<String, dynamic> json) => DataLoginRecovery(
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
  };
}





DataLoginCode dataLoginCodeFromJson(String str) => DataLoginCode.fromJson(json.decode(str));

String dataLoginCodeToJson(DataLoginCode data) => json.encode(data.toJson());

class DataLoginCode {
  String token;

  DataLoginCode({
    required this.token,
  });

  factory DataLoginCode.fromJson(Map<String, dynamic> json) => DataLoginCode(
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
  };
}




DataLoginNewPassword dataLoginNewPasswordFromJson(String str) => DataLoginNewPassword.fromJson(json.decode(str));

String dataLoginNewPasswordToJson(DataLoginNewPassword data) => json.encode(data.toJson());

class DataLoginNewPassword {
  String token;
  String pswd;
  String pswdRepeat;

  DataLoginNewPassword({
    required this.token,
    required this.pswd,
    required this.pswdRepeat,
  });

  factory DataLoginNewPassword.fromJson(Map<String, dynamic> json) => DataLoginNewPassword(
    token: json["token"],
    pswd: json["pswd"],
    pswdRepeat: json["pswd_repeat"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "pswd": pswd,
    "pswd_repeat": pswdRepeat,
  };
}

