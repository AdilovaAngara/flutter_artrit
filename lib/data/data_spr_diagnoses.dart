
//     final diagnosesDataSpr = diagnosesDataSprFromJson(jsonString);

import 'dart:convert';

List<DataSprDiagnoses> dataSprDiagnosesFromJson(String str) => List<DataSprDiagnoses>.from(json.decode(str).map((x) => DataSprDiagnoses.fromJson(x)));

String dataSprDiagnosesToJson(List<DataSprDiagnoses> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprDiagnoses {
    String id;
    String synonym;
    String mkbCode;
    String mkbName;

    DataSprDiagnoses({
        required this.id,
        required this.synonym,
        required this.mkbCode,
        required this.mkbName,
    });

    factory DataSprDiagnoses.fromJson(Map<String, dynamic> json) => DataSprDiagnoses(
        id: json["id"],
        synonym: json["synonym"],
        mkbCode: json["mkb_code"],
        mkbName: json["mkb_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "synonym": synonym,
        "mkb_code": mkbCode,
        "mkb_name": mkbName,
    };
}
