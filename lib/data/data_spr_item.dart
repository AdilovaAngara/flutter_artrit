import 'dart:convert';
import 'package:flutter/cupertino.dart';

DataSprItem dataSprItemFromJson(String str) => DataSprItem.fromJson(json.decode(str));

String dataSprItemToJson(DataSprItem data) => json.encode(data.toJson());

// Функция для преобразования JSON в List<SprItem>
List<SprItem> sprItemsFromJson(String? jsonString) {
  if (jsonString == null) return [];
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((item) => SprItem.fromJson(item as Map<String, dynamic>)).toList();
}

// Функция для преобразования JSON в SprItem
SprItem? sprItemFromJson(String? jsonString) {
  if (jsonString == null) return null;
  try {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return SprItem.fromJson(json);
  } catch (e) {
    debugPrint('Ошибка десериализации: $e');
    return null;
  }
}


// Универсальная функция parseSprItemOrList, которая автоматически определяет, является ли jsonString JSON-объектом (Map) или массивом (List)
List<SprItem> parseSprItemOrList(String? jsonString) {
  if (jsonString == null) return [];

  try {
    final dynamic json = jsonDecode(jsonString);

    if (json is List) {
      return json.map((item) => SprItem.fromJson(item as Map<String, dynamic>)).toList();
    } else if (json is Map<String, dynamic>) {
      return [SprItem.fromJson(json)];
    } else {
      debugPrint('Неизвестный тип данных JSON: ${json.runtimeType}');
      return [];
    }
  } catch (e) {
    debugPrint('Ошибка при парсинге SprItem/SprItemList: $e');
    return [];
  }
}



class DataSprItem {
  bool success;
  String errorMessage;
  ResultSprItem result;

  DataSprItem({
    required this.success,
    required this.errorMessage,
    required this.result,
  });

  factory DataSprItem.fromJson(Map<String, dynamic> json) => DataSprItem(
    success: json["success"],
    errorMessage: json["errorMessage"],
    result: ResultSprItem.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "errorMessage": errorMessage,
    "result": result.toJson(),
  };
}

class ResultSprItem {
  String id;
  String name;
  List<SprItem> items;

  ResultSprItem({
    required this.id,
    required this.name,
    required this.items,
  });

  factory ResultSprItem.fromJson(Map<String, dynamic> json) => ResultSprItem(
    id: json["id"],
    name: json["name"],
    items: List<SprItem>.from(json["items"].map((x) => SprItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class SprItem {
  String id;
  String name;

  SprItem({
    required this.id,
    required this.name,
  });

  factory SprItem.fromJson(Map<String, dynamic> json) => SprItem(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SprItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
