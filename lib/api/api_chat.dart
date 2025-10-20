import 'dart:convert';
import 'package:artrit/data/data_chat_file_send.dart';
import 'package:artrit/data/data_chat_info.dart';
import 'package:artrit/data/data_chat_messages.dart';
import 'package:artrit/data/data_chat_templates.dart';
import 'package:flutter/cupertino.dart';
import '../data/data_chat_add_message.dart';
import '../data/data_chat_contacts.dart';
import '../data/data_chat_message.dart';
import '../data/data_result.dart';
import 'base_client.dart';


var baseClient = BaseClient();

class ApiChat {

  /// Список контактов
  Future<DataChatContacts>? getContacts({
    required String ssId,
  }) async {
    var response =
    await baseClient.get('/api/chat/contacts?ssid=$ssId');
    DataChatContacts thisData = dataChatContactsFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  /// Информация о чате
  Future<DataChatInfo> getInfo({
    required String ssId,
    required String clientUserId
  }) async {
    var response =
    await baseClient.get('/api/chat/$clientUserId/chat?ssid=$ssId');
    DataChatInfo thisData = dataChatInfoFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  /// Список сообщений
  Future<DataChatMessages>? getMessages({
    required String ssId,
    required String chatId,
    required int messageId,
  }) async {
    var response =
    await baseClient.get('/api/chat/$chatId/newmessages/$messageId?ssid=$ssId');
    DataChatMessages thisData = dataChatMessagesFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  /// История сообщений
  Future<DataChatMessages>? getMessagesHistory({
    required String ssId,
    required int lastMessageId,
    required String chatId,
  }) async {
    var response =
    await baseClient.get('/api/chat/$chatId/historymessages/$lastMessageId?ssid=$ssId');
    DataChatMessages thisData = dataChatMessagesFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  /// Шаблоны сообщений
  Future<DataChatTemplates> getTemplates({
    required String ssId
  }) async {
    var response =
    await baseClient.get('/api/chat/message/templates?ssid=$ssId');
    DataChatTemplates thisData = dataChatTemplatesFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  /// Отправить сообщение
  Future<DataChatMessage?> addMessage({
    required String ssId,
    required String chatId,
    required DataChatAddMessage thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/chat/$chatId/addmessage?ssid=$ssId', thisData.toJson(), isChat: true);
    DataChatMessage? thisDataRecord = dataChatMessageFromJson(response.body);
    debugPrint(jsonEncode(thisDataRecord));
    return thisDataRecord;
  }

  /// Удалить сообщение
  Future<DataResult3> deleteMessage({
    required String ssId,
    required String chatId,
    required List<int> msgId,
  }) async {
    debugPrint('Удалить сообщения: ${msgId.join(', ')}');
    var response = await baseClient
        .delete('/api/chat/$chatId/delete?ssid=$ssId', object: msgId, isChat: true);
    DataResult3? result = dataResult3FromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }

  /// Отправить файл на сервер
  Future<DataChatFileSend?> addFile({
    required String ssId,
    required String chatId,
    required String filePath,
  }) async {
    var response = await baseClient.uploadFileToServer(filePath: filePath, api: '/api/chat/$chatId/upload?ssid=$ssId');
    String responseBody = await response.stream.bytesToString();
    debugPrint(responseBody);
    // Преобразуем JSON-строку в объект DataChatFileSend
    DataChatFileSend? thisDataRecord  = dataChatFileSendFromJson(responseBody);
    debugPrint(jsonEncode(thisDataRecord));
    return thisDataRecord;
  }

  /// Сделать сообщение прочитанным
  Future<DataResult3?> setAsRead({
    required String ssId,
    required String chatId,
    required List<int> thisData,
  }) async {
    debugPrint('Сделать прочитанными: ${thisData.join(', ')}');
    if (thisData.isEmpty) return null;
    var response = await baseClient.put(
        '/api/chat/$chatId/setread?ssid=$ssId', thisData, isChat: true);
    DataResult3? result = dataResult3FromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }





  /// Согласие на чат
  Future<DataChatInfo?> allowChat({
    required String ssId,
    required String chatId,
  }) async {
    var response = await baseClient.put(
        '/api/chat/$chatId/allow?ssid=$ssId', {}, isChat: true);
    DataChatInfo? result = dataChatInfoFromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }







  /// Закрыть/заблокировать чат
  Future<DataChatInfo?> closeChat({
    required String ssId,
    required String chatId,
  }) async {
    var response = await baseClient.put(
        '/api/chat/$chatId/close?ssid=$ssId', {}, isChat: true);
    DataChatInfo? result = dataChatInfoFromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }




  /// Открыть чат
  Future<DataChatInfo?> openChat({
    required String ssId,
    required String chatId,
  }) async {
    var response = await baseClient.put(
        '/api/chat/$chatId/open?ssid=$ssId', {}, isChat: true);
    DataChatInfo? result = dataChatInfoFromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }




}
