//     final questionnaireData = questionnaireDataFromJson(jsonString);

import 'dart:convert';

enum Enum {
  otherDevices
}

List<DataQuestionnaire> dataQuestionnaireFromJson(String str) => List<DataQuestionnaire>.from(json.decode(str).map((x) => DataQuestionnaire.fromJson(x)));

String dataQuestionnaireToJson(List<DataQuestionnaire> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

DataQuestionnaire dataQuestionnaireRecFromJson(String str) => DataQuestionnaire.fromJson(json.decode(str));

String dataQuestionnaireRecToJson(DataQuestionnaire data) => json.encode(data.toJson());


class DataQuestionnaire {
  String? id;
  //String? patientsId;
  DateTime questdate;
  int q1;
  int q2;
  int q3;
  int q4;
  int q5;
  int q6;
  int q7;
  int q8;
  int q9;
  int q10;
  int q11;
  int q12;
  int q13;
  int q14;
  int q15;
  int q16;
  int q17;
  int q18;
  int q19;
  int q20;
  int q21;
  int q22;
  int q23;
  int q24;
  int q25;
  int q26;
  int q27;
  int q28;
  int q29;
  int q30;
  bool rod;
  bool hod;
  bool kos;
  bool inv;
  bool odev;
  bool pencil;
  bool chair;
  bool other;
  String? otherDevices;
  bool hputon;
  bool hgetup;
  bool heat;
  bool hwalk;
  bool sidun;
  bool sidvan;
  bool kons;
  bool per;
  bool longget;
  bool longwash;
  bool gig;
  bool questget;
  bool questopen;
  bool home;
  int? pain;
  int? cond;
  int painAsses;
  int condAsses;
  double? result;
  int? creationDate;

  DataQuestionnaire({
    this.id,
    //this.patientsId,
    required this.questdate,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
    required this.q5,
    required this.q6,
    required this.q7,
    required this.q8,
    required this.q9,
    required this.q10,
    required this.q11,
    required this.q12,
    required this.q13,
    required this.q14,
    required this.q15,
    required this.q16,
    required this.q17,
    required this.q18,
    required this.q19,
    required this.q20,
    required this.q21,
    required this.q22,
    required this.q23,
    required this.q24,
    required this.q25,
    required this.q26,
    required this.q27,
    required this.q28,
    required this.q29,
    required this.q30,
    required this.rod,
    required this.hod,
    required this.kos,
    required this.inv,
    required this.odev,
    required this.pencil,
    required this.chair,
    required this.other,
    this.otherDevices,
    required this.hputon,
    required this.hgetup,
    required this.heat,
    required this.hwalk,
    required this.sidun,
    required this.sidvan,
    required this.kons,
    required this.per,
    required this.longget,
    required this.longwash,
    required this.gig,
    required this.questget,
    required this.questopen,
    required this.home,
    this.pain,
    this.cond,
    required this.painAsses,
    required this.condAsses,
    this.result,
    required this.creationDate,
  });

  factory DataQuestionnaire.fromJson(Map<String, dynamic> json) => DataQuestionnaire(
    id: json["id"],
    //patientsId: json["patients_id"],
    questdate: DateTime.parse(json["questdate"]),
    q1: json["q1"],
    q2: json["q2"],
    q3: json["q3"],
    q4: json["q4"],
    q5: json["q5"],
    q6: json["q6"],
    q7: json["q7"],
    q8: json["q8"],
    q9: json["q9"],
    q10: json["q10"],
    q11: json["q11"],
    q12: json["q12"],
    q13: json["q13"],
    q14: json["q14"],
    q15: json["q15"],
    q16: json["q16"],
    q17: json["q17"],
    q18: json["q18"],
    q19: json["q19"],
    q20: json["q20"],
    q21: json["q21"],
    q22: json["q22"],
    q23: json["q23"],
    q24: json["q24"],
    q25: json["q25"],
    q26: json["q26"],
    q27: json["q27"],
    q28: json["q28"],
    q29: json["q29"],
    q30: json["q30"],
    rod: json["rod"],
    hod: json["hod"],
    kos: json["kos"],
    inv: json["inv"],
    odev: json["odev"],
    pencil: json["pencil"],
    chair: json["chair"],
    other: json["other"],
    otherDevices: json["otherDevices"],
    hputon: json["hputon"],
    hgetup: json["hgetup"],
    heat: json["heat"],
    hwalk: json["hwalk"],
    sidun: json["sidun"],
    sidvan: json["sidvan"],
    kons: json["kons"],
    per: json["per"],
    longget: json["longget"],
    longwash: json["longwash"],
    gig: json["gig"],
    questget: json["questget"],
    questopen: json["questopen"],
    home: json["home"],
    pain: json["pain"],
    cond: json["cond"],
    painAsses: json["pain_asses"],
    condAsses: json["cond_asses"],
    result: json["result"]?.toDouble(),
    creationDate: json["creation_date"],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id, // Добавляем только если не null
    //"id": id,
    //"patients_id": patientsId,
    "questdate": questdate.toIso8601String(),
    "q1": q1,
    "q2": q2,
    "q3": q3,
    "q4": q4,
    "q5": q5,
    "q6": q6,
    "q7": q7,
    "q8": q8,
    "q9": q9,
    "q10": q10,
    "q11": q11,
    "q12": q12,
    "q13": q13,
    "q14": q14,
    "q15": q15,
    "q16": q16,
    "q17": q17,
    "q18": q18,
    "q19": q19,
    "q20": q20,
    "q21": q21,
    "q22": q22,
    "q23": q23,
    "q24": q24,
    "q25": q25,
    "q26": q26,
    "q27": q27,
    "q28": q28,
    "q29": q29,
    "q30": q30,
    "rod": rod,
    "hod": hod,
    "kos": kos,
    "inv": inv,
    "odev": odev,
    "pencil": pencil,
    "chair": chair,
    "other": other,
    "otherDevices": otherDevices,
    "hputon": hputon,
    "hgetup": hgetup,
    "heat": heat,
    "hwalk": hwalk,
    "sidun": sidun,
    "sidvan": sidvan,
    "kons": kons,
    "per": per,
    "longget": longget,
    "longwash": longwash,
    "gig": gig,
    "questget": questget,
    "questopen": questopen,
    "home": home,
    if (pain != null) 'pain': pain, // Добавляем только если не null
    //"pain": pain,
    if (cond != null) 'cond': cond, // Добавляем только если не null
    //"cond": cond,
    "pain_asses": painAsses,
    "cond_asses": condAsses,
    if (result != null) 'result': result, // Добавляем только если не null
    //"result": result,
    "creation_date": creationDate,
  };
}

