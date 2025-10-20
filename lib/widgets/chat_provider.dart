import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_chat.dart';
import '../data/data_chat_contacts.dart';
import '../secure_storage.dart';
import 'audio_provider.dart';

class ChatProvider with ChangeNotifier {
  final ApiChat _api = ApiChat();

  List<ResultContacts> _chatContacts = [];
  int _messageCount = 0;
  String _ssId = '';
  String _userId = '';
  Timer? _refreshTimer;
  bool _isLoading = false;
  final AudioProvider? _audioProvider;
  String? _currentChatId; // ID текущего чата, если пользователь в PageChatMessages
  bool _hasNewMessages = false; // Флаг новых сообщений
  String? get currentChatId => _currentChatId;
  int _seconds = 20;


  List<ResultContacts> get chatContacts => _chatContacts;
  int get messageCount => _messageCount;
  bool get hasNewMessages => _hasNewMessages;

  ChatProvider({AudioProvider? audioProvider}) : _audioProvider = audioProvider {
    _initialize();
  }

  Future<void> _initialize() async {
    debugPrint('ChatProvider: Инициализация...');
    _ssId = await readSecureData(SecureKey.ssId);
    _userId = await readSecureData(SecureKey.userId);
    if (_ssId.isNotEmpty) {
      //await refreshMessageCount();
      _startRefreshTimer();
    } else {
      debugPrint('ChatProvider: ssId пустой, инициализация пропущена');
    }
  }



  void _startRefreshTimer() {
    if (_ssId.isEmpty) {
      debugPrint('ChatProvider: ssId пустой, таймер не запускается');
      return;
    }
    debugPrint('ChatProvider: Запуск таймера обновления...');
    _refreshTimer?.cancel();
    _seconds = _currentChatId == null || _currentChatId!.isEmpty ? 20 : 5;
    _refreshTimer = Timer.periodic(Duration(seconds: _seconds), (timer) async {
      debugPrint('ChatProvider: Таймер сработал, обновление messageCount...');
      await refreshMessageCount();
      if (_currentChatId != null) {
        bool hasNew = await _refreshChatMessages(_currentChatId!);
        if (hasNew && !_hasNewMessages) {
          _hasNewMessages = true;
          notifyListeners(); // Уведомляем о новых сообщениях
        }
      }
    });
  }



  Future<void> refreshMessageCount({BuildContext? context}) async {
    if (_isLoading) {
      debugPrint('ChatProvider: Обновление уже выполняется, пропуск...');
      return;
    }
    _isLoading = true;

    try {
      debugPrint('ChatProvider: Запрос данных с API, ssId: $_ssId');
      if (_ssId.isNotEmpty) {
        final thisDataChatContacts = await _api.getContacts(ssId: _ssId);
        if (thisDataChatContacts != null &&
            thisDataChatContacts.success &&
            thisDataChatContacts.result != null) {
          final newContacts = thisDataChatContacts.result!;
          final newMessageCount = _calculateTotalMessageCount(thisDataChatContacts);
          debugPrint(
              'ChatProvider: Текущее messageCount: $_messageCount, новое: $newMessageCount');

          if (newMessageCount != _messageCount || _chatContacts != newContacts) {
            debugPrint('ChatProvider: messageCount или контакты изменились, обновляем...');
            if (newMessageCount > _messageCount) {
              debugPrint('ChatProvider: Попытка воспроизведения звука...');
              if (_audioProvider != null) {
                await _audioProvider.playNotificationSound();
              } else if (context != null) {
                await Provider.of<AudioProvider>(context, listen: false)
                    .playNotificationSound();
              } else {
                debugPrint('ChatProvider: AudioProvider и контекст недоступны');
              }
            }
            _messageCount = newMessageCount;
            _chatContacts = newContacts;
            notifyListeners();
          } else {
            debugPrint('ChatProvider: messageCount и контакты не изменились');
          }
        } else {
          debugPrint(
              'ChatProvider: Ошибка API или данные пусты: ${thisDataChatContacts?.userMessage}');
        }
      } else {
        debugPrint('ChatProvider: ssId пустой, запрос не выполнен');
      }
    } catch (e) {
      debugPrint('ChatProvider: Ошибка при обновлении: $e');
    } finally {
      _isLoading = false;
    }
  }



  // Метод для обновления сообщений в текущем чате
  Future<bool> _refreshChatMessages(String chatId, {BuildContext? context}) async {
    try {
      debugPrint('ChatProvider: Обновление сообщений для чата: $chatId, currentChatId: $_currentChatId');
      final dataUpdateMessages =
      await _api.getMessages(ssId: _ssId, chatId: chatId, messageId: 0);
      if (dataUpdateMessages != null &&
          dataUpdateMessages.success &&
          dataUpdateMessages.result.messages.isNotEmpty) {
        final newMessages = dataUpdateMessages.result.messages
            .where((msg) => !msg.isRead && msg.artritFromId != _userId)
            .toList();
        if (newMessages.isNotEmpty) {
          debugPrint('ChatProvider: Найдены новые сообщения в чате $chatId: ${newMessages.length}');
          if (_currentChatId != null && _currentChatId == chatId) {
            debugPrint('ChatProvider: Чат открыт, воспроизведение звука...');
            if (_audioProvider != null) {
              await _audioProvider.playNotificationSound();
            } else if (context != null) {
              await Provider.of<AudioProvider>(context, listen: false)
                  .playNotificationSound();
            } else {
              debugPrint('ChatProvider: AudioProvider и контекст недоступны');
            }
          } else {
            debugPrint('ChatProvider: Чат закрыт или неактивен, звук не воспроизводится');
          }
          return true;
        } else {

          debugPrint('ChatProvider: Нет новых непрочитанных сообщений в чате $chatId');
          return true;
        }
      } else {
        debugPrint('ChatProvider: Нет сообщений или ошибка API: ${dataUpdateMessages?.userMessage}');
      }
      return false;
    } catch (e) {
      debugPrint('ChatProvider: Ошибка при обновлении сообщений чата: $e');
      return false;
    }
  }

  int _calculateTotalMessageCount(DataChatContacts data) {
    if (data.result == null || data.result!.isEmpty) {
      debugPrint('ChatProvider: Данные контактов пусты, возвращаем 0');
      return 0;
    }
    final total = data.result!.fold(0, (sum, contact) => sum + contact.messageCount);
    debugPrint('ChatProvider: Рассчитано общее количество сообщений: $total');
    return total;
  }


  Future<void> onMessagesRead({BuildContext? context}) async {
    debugPrint('ChatProvider: Вызван onMessagesRead, обновление messageCount...');
    _hasNewMessages = false; // Сбрасываем флаг новых сообщений
    await refreshMessageCount(context: context);
  }

  void setCurrentChat(String? chatId) {
    debugPrint('ChatProvider: Установка текущего чата: $chatId');
    _currentChatId = chatId;
    _hasNewMessages = false; // Сбрасываем флаг при смене чата
    // Меняем интервал обновления сообщений
    _seconds = _currentChatId == null || _currentChatId!.isEmpty ? 20 : 5;
    // Перезапускаем таймер с новым интервалом
    _startRefreshTimer();
    notifyListeners();
  }



  // Метод для очистки состояния при выходе из учетной записи
  void clear() {
    debugPrint('ChatProvider: Сброс состояния...');
    _chatContacts = [];
    _messageCount = 0;
    _ssId = '';
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isLoading = false;
    _currentChatId = null;
    _hasNewMessages = false;
    notifyListeners();
  }

  // Метод для повторной инициализации после входа нового пользователя
  Future<void> reinitialize() async {
    debugPrint('ChatProvider: Повторная инициализация...');
    clear(); // Сначала очищаем текущее состояние
    await _initialize(); // Затем инициализируем заново
  }

  @override
  void dispose() {
    debugPrint('ChatProvider: Dispose, остановка таймера...');
    _refreshTimer?.cancel();
    super.dispose();
  }
}




