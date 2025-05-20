
//     final inspectionsData = inspectionsDataFromJson(jsonString);

import 'dart:convert';

enum Enum {
  date,
  tem,
  chss,
  utscov,
  sis,
  dia,
}

enum EnumJoints {
  isPainful,
  isSwollen,
  isMovementLimited,
}

enum EnumRash {
  isActive
}

enum EnumUveit{
  uveitExists,
  consultationDate,
  diseaseCourse,
  complications,
  complicationsComment,
  localTherapy,
}


DataInspections dataInspectionsRecFromJson(String str) => DataInspections.fromJson(json.decode(str));

String dataInspectionsRecToJson(DataInspections data) => json.encode(data.toJson());


List<DataInspections> dataInspectionsFromJson(String str) => List<DataInspections>.from(json.decode(str).map((x) => DataInspections.fromJson(x)));

String dataInspectionsToJson(List<DataInspections> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataInspections {
  String? id;
  String? patientsId;
  int? date;
  double? tem;
  Ardav ardav;
  int? chss;
  int? utscov;
  int ocbol;
  Uveit? uveit;
  List<Joint> joints;
  int? painfulJoints;
  int? swollenJoints;
  int? movementLimitedJoints;
  int? activeArthritisJoints;
  int? sip;
  List<Syssind> syssind1;
  String? siplist;
  int? uvellim;
  List<Syssind> syssind2;
  int? creationDate;

  DataInspections({
    this.id,
    this.patientsId,
    required this.date,
    this.tem,
    required this.ardav,
    this.chss,
    this.utscov,
    required this.ocbol,
    this.uveit,
    required this.joints,
    this.painfulJoints,
    this.swollenJoints,
    this.movementLimitedJoints,
    this.activeArthritisJoints,
    this.sip,
    required this.syssind1,
    this.siplist,
    this.uvellim,
    required this.syssind2,
    required this.creationDate,
  });

  factory DataInspections.fromJson(Map<String, dynamic> json) => DataInspections(
    id: json["id"],
    patientsId: json["patients_id"],
    date: json["date"],
    tem: json["tem"]?.toDouble(),
    ardav: Ardav.fromJson(json["ardav"]),
    chss: json["chss"],
    utscov: json["utscov"],
    ocbol: json["ocbol"],
    uveit: json["Uveit"] == null ? null : Uveit.fromJson(json["Uveit"]),
    joints: List<Joint>.from(json["Joints"].map((x) => Joint.fromJson(x))),
    painfulJoints: json["PainfulJoints"],
    swollenJoints: json["SwollenJoints"],
    movementLimitedJoints: json["MovementLimitedJoints"],
    activeArthritisJoints: json["ActiveArthritisJoints"],
    sip: json["sip"],
    syssind1: List<Syssind>.from(json["syssind1"].map((x) => Syssind.fromJson(x))),
    siplist: json["siplist"],
    uvellim: json["uvellim"],
    syssind2: List<Syssind>.from(json["syssind2"].map((x) => Syssind.fromJson(x))),
    creationDate: json["creation_date"],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id, // Добавляем только если не null
    //"id": id,
    "patients_id": patientsId,
    "date": date,
    "tem": tem,
    "ardav": ardav.toJson(),
    "chss": chss,
    "utscov": utscov,
    "ocbol": ocbol,
    "Uveit": uveit?.toJson(),
    "Joints": List<dynamic>.from(joints.map((x) => x.toJson())),
    "PainfulJoints": painfulJoints,
    "SwollenJoints": swollenJoints,
    "MovementLimitedJoints": movementLimitedJoints,
    "ActiveArthritisJoints": activeArthritisJoints,
    "sip": sip,
    "syssind1": List<dynamic>.from(syssind1.map((x) => x.toJson())),
    "siplist": siplist,
    "uvellim": uvellim,
    "syssind2": List<dynamic>.from(syssind2.map((x) => x.toJson())),
    "creation_date": creationDate,
  };
}

class Ardav {
  int sis;
  int dia;

  Ardav({
    required this.sis,
    required this.dia,
  });

  factory Ardav.fromJson(Map<String, dynamic> json) => Ardav(
    sis: json["sis"],
    dia: json["dia"],
  );

  Map<String, dynamic> toJson() => {
    "sis": sis,
    "dia": dia,
  };
}

class Joint {
  String? inspectionId;
  int jointId;
  bool isPainful;
  bool isSwollen;
  bool isMovementLimited;

  Joint({
    this.inspectionId,
    required this.jointId,
    required this.isPainful,
    required this.isSwollen,
    required this.isMovementLimited,
  });

  factory Joint.fromJson(Map<String, dynamic> json) => Joint(
    inspectionId: json["InspectionId"],
    jointId: json["JointId"],
    isPainful: json["IsPainful"],
    isSwollen: json["IsSwollen"],
    isMovementLimited: json["IsMovementLimited"],
  );

  Map<String, dynamic> toJson() => {
    "InspectionId": inspectionId,
    "JointId": jointId,
    "IsPainful": isPainful,
    "IsSwollen": isSwollen,
    "IsMovementLimited": isMovementLimited,
  };
}

class Syssind {
  bool isActive;
  String? name;

  Syssind({
    required this.isActive,
    this.name,
  });

  factory Syssind.fromJson(Map<String, dynamic> json) => Syssind(
    isActive: json["isActive"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "isActive": isActive,
    "name": name,
  };
}

class Uveit {
  String? inspectionId;
  DateTime? consultationDate;
  int sideType;
  int diseaseCourse;
  bool complications;
  String? complicationsComment;
  bool localTherapy;

  Uveit({
    this.inspectionId,
    required this.consultationDate,
    required this.sideType,
    required this.diseaseCourse,
    required this.complications,
    required this.complicationsComment,
    required this.localTherapy,
  });

  factory Uveit.fromJson(Map<String, dynamic> json) => Uveit(
    inspectionId: json["InspectionId"],
    consultationDate: DateTime.parse(json["ConsultationDate"]),
    sideType: json["SideType"],
    diseaseCourse: json["DiseaseCourse"],
    complications: json["Complications"],
    complicationsComment: json["ComplicationsComment"],
    localTherapy: json["LocalTherapy"],
  );

  Map<String, dynamic> toJson() => {
    "InspectionId": inspectionId,
    "ConsultationDate": consultationDate?.toIso8601String(),
    "SideType": sideType,
    "DiseaseCourse": diseaseCourse,
    "Complications": complications,
    "ComplicationsComment": complicationsComment,
    "LocalTherapy": localTherapy,
  };
}
