import 'dart:async';
import 'package:artrit/data/data_chat_add_message.dart';
import 'package:artrit/theme.dart';
import 'package:artrit/widget_another/chat_message_widget.dart';
import 'package:artrit/widgets/show_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../api/api_chat.dart';
import '../data/data_chat_contacts.dart';
import '../data/data_chat_file_send.dart';
import '../data/data_chat_info.dart';
import '../data/data_chat_message.dart';
import '../data/data_chat_messages.dart';
import '../data/data_chat_templates.dart';
import '../data/data_result.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/chat_divider_new_message_widget.dart';
import '../widget_another/chat_divider_widget.dart';
import '../widget_another/chat_file_preview_widget.dart';
import '../widget_another/chat_file_upload_progress_widget.dart';
import '../widget_another/chat_message_input_panel.dart';
import '../widget_another/chat_politic.dart';
import '../widget_another/chat_status_banner.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widget_another/chat_options_menu.dart';
import '../widgets/chat_provider.dart';
import '../widgets/download_file_widget.dart';
import '../widgets/file_picker_widget.dart';
import '../widgets/show_dialog_confirm.dart';
import 'menu.dart';
import 'package:grouped_list/grouped_list.dart';


class PageChatMessages extends StatefulWidget {
  final ResultContacts contact;

  const PageChatMessages({
    super.key,
    required this.contact,
  });

  @override
  PageChatMessagesState createState() => PageChatMessagesState();
}

class PageChatMessagesState extends State<PageChatMessages> {
  late Future<void> _future;

  /// API
  final ApiChat _api = ApiChat();

  /// Данные
  DataChatInfo? _chatInfo;
  DataChatTemplates? _chatTemplates;
  List<TemplatesResult> _templates = [];

  /// Параметры
  late int _role;
  late String _ssId;
  late String _chatId;
  late bool _isChatClosed = true;
  late bool _allowByDoctor = false;
  late bool _allowByPatient = false;
  late String _userId;
  bool _isFileSending = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  List<FileElement> _fileElements = [];
  List<FileItems> _fileItems = [];
  int _currentFileIndex = 0;
  double? _progress;
  int _firstMessageId = 0;
  int _lastMessageId = 0;
  late String _acceptMessage = 'Согласен с политикой чата';
  final FocusNode _focusNode = FocusNode();

  /// Таймеры
  /// Таймер для ожидания стабилизации рендеринга
  Timer? _renderStabilizationTimer;


  /// Слушатели
  /// Для сообщений
  late ValueNotifier<List<Message>> _messagesNotifier;
  /// Кнопка отправить
  late ValueNotifier<bool> _sendVisibilityNotifier;
  /// Для состояния загрузки истории сообщений
  late ValueNotifier<bool> _isLoadingHistoryNotifier;
  /// Для состояния загрузки сообщений
  late ValueNotifier<bool> _isLoadingMessagesNotifier;
  /// Для индикатора новых сообщений
  late ValueNotifier<bool> _isNewMessagesNotifier;
  /// Для режима выбора
  late ValueNotifier<bool> _isSelectionModeNotifier;
  /// Для выбранных сообщений
  late ValueNotifier<Set<int>> _selectedMessageIdsNotifier;

  /// Ключи
  /// Карта для хранения GlobalKey для каждого сообщения
  final Map<int, GlobalKey> _messageKeys = {};

  /// Ссылка на ChatProvider
  late ChatProvider _chatProvider;


  @override
  void initState() {
    super.initState();
    /// Инициализация ValueNotifier
    _scrollController.addListener(_scrollListener);
    _messagesNotifier = ValueNotifier<List<Message>>([]);
    _isLoadingHistoryNotifier = ValueNotifier<bool>(false);
    _isLoadingMessagesNotifier = ValueNotifier<bool>(false);
    _isNewMessagesNotifier = ValueNotifier<bool>(false);
    _isSelectionModeNotifier = ValueNotifier<bool>(false);
    _selectedMessageIdsNotifier = ValueNotifier<Set<int>>({});
    _sendVisibilityNotifier = ValueNotifier<bool>(
        _textController.text.isNotEmpty || _fileItems.isNotEmpty);

    /// Отключаем автоматический фокус для TextField
    _focusNode.unfocus();

    /// Добавляем слушатель для TextField
    _textController.addListener(() {
      _sendVisibilityNotifier.value =
          _textController.text.isNotEmpty || _fileItems.isNotEmpty;
    });

    _future = _loadData();
    // Подписываемся на изменения ChatProvider
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _chatProvider.addListener(_onChatProviderUpdate);
  }



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
  }


  @override
  void dispose() {
    /// Освобождаем ресурсы
    _renderStabilizationTimer?.cancel();
    _messageKeys.clear();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _textController.dispose();
    _messagesNotifier.dispose();
    _isLoadingHistoryNotifier.dispose();
    _isLoadingMessagesNotifier.dispose();
    _isNewMessagesNotifier.dispose();
    _isSelectionModeNotifier.dispose();
    _selectedMessageIdsNotifier.dispose();
    _sendVisibilityNotifier.dispose();
    _focusNode.dispose();
    // Очищаем текущий чат в ChatProvider
    _chatProvider.removeListener(_onChatProviderUpdate);
    _chatProvider.setCurrentChat(null);
    super.dispose();
  }



  // Реакция на обновления от ChatProvider
  void _onChatProviderUpdate() {
    if (_chatProvider.hasNewMessages && mounted && _chatId == _chatProvider.currentChatId) {
      debugPrint('PageChatMessages: Обнаружены новые сообщения, вызываем _updateMessages');
      _updateMessages(true);
    }
  }


  /// Прокручивает список сообщений вниз, если не внизу
  void _scrollToBottom() {
    Future.delayed(
        const Duration(milliseconds: 500), ()
    {
      if (_scrollController.hasClients && mounted) {
        final position = _scrollController.position;
        // Проверяем, находится ли список уже внизу (допуск 10 пикселей)
        if (position.pixels < position.maxScrollExtent - 10) {
          _scrollController.animateTo(
            position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    }
    );
  }






  Future<void> _loadData() async {
    _role = await getUserRole();
    _ssId = await readSecureData(SecureKey.ssId);
    _userId = await readSecureData(SecureKey.userId);
    _chatInfo = await _api.getInfo(
        ssId: _ssId, clientUserId: widget.contact.clientUserId);
    if (_chatInfo != null && _chatInfo!.success) {
      _chatId = _chatInfo!.result.id;
      _isChatClosed = _chatInfo!.result.isClosed;
      _allowByDoctor = _chatInfo!.result.allowByDoctor;
      _allowByPatient = _chatInfo!.result.allowByPatient;
      // Устанавливаем текущий чат, сбрасывая предыдущий
      _chatProvider.setCurrentChat(_chatId);
    }
    _chatTemplates = await _api.getTemplates(ssId: _ssId);
    if (_chatTemplates != null &&
        _chatTemplates!.success &&
        _chatTemplates!.result != null) {
      _templates = _chatTemplates!.result!
          .where((e) => [1, 2].contains(e.messageType))
          .toList();
      _acceptMessage = _chatTemplates!.result!
          .where((e) => e.messageType == 3)
          .first
          .messages
          .first;
    }

    await _updateMessages(false);
    // Прокручиваем к низу после рендеринга
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }






  /// Обновляет видимость кнопки отправки
  void _updateSendButtonVisibility() {
    _sendVisibilityNotifier.value = _textController.text.isNotEmpty || _fileItems.isNotEmpty;
  }

  /// Вставляет сообщение в отсортированный список
  void _insertSortedMessage00(List<Message> messages, Message newMsg) {
    final insertIndex = messages.indexWhere((msg) => msg.id > newMsg.id);
    if (insertIndex == -1) {
      messages.add(newMsg);
    } else {
      messages.insert(insertIndex, newMsg);
    }
    if (!_messageKeys.containsKey(newMsg.id)) {
      _messageKeys[newMsg.id] = GlobalKey();
    }
  }





  Future<void> _updateMessages(bool showBanner) async {
    bool newMsgExists = false;
    bool hasChanges = false; // Флаг для отслеживания изменений
    if (_isLoadingMessagesNotifier.value) return; // Предотвращаем повторные вызовы
    _isLoadingMessagesNotifier.value = true;
    final currentMessages = List<Message>.from(_messagesNotifier.value);

    // Обновляем информацию о старых сообщениях (только isRead, удаляем только из последних 10)
    final dataUpdateMessages = await _api.getMessages(ssId: _ssId, chatId: _chatId, messageId: 0);
    if (dataUpdateMessages != null && dataUpdateMessages.success == true && dataUpdateMessages.result.messages.isNotEmpty) {
      final updateMessages = dataUpdateMessages.result.messages;

      // Получаем последние 10 сообщений из currentMessages (по возрастанию id)
      final lastTenMessages = currentMessages.length > 10
          ? currentMessages.sublist(currentMessages.length - 10)
          : currentMessages;

      // Удаляем из currentMessages только те из последних 10, которых нет в updateMessages
      final updateMessageIds = updateMessages.map((e) => e.id).toSet();
      final removedMessages = lastTenMessages.where((msg) => !updateMessageIds.contains(msg.id)).toList();
      if (removedMessages.isNotEmpty) {
        currentMessages.removeWhere((msg) => removedMessages.any((e) => e.id == msg.id));
        hasChanges = true; // Устанавливаем флаг, так как были удаления
        debugPrint('Removed messages: ${removedMessages.map((m) => m.id).toList()}');
      }

      // Обновляем статус прочтения и добавляем новые сообщения
      for (final updatedMsg in updateMessages) {
        final existingMsgIndex = currentMessages.indexWhere((msg) => msg.id == updatedMsg.id);
        if (existingMsgIndex != -1) {
          // Обновляем isRead для существующего сообщения
          currentMessages[existingMsgIndex] = currentMessages[existingMsgIndex].copyWith(
            isRead: updatedMsg.isRead,
          );
          hasChanges = true; // Устанавливаем флаг, так как изменился isRead
        } else {
          // Добавляем новое сообщение в список в правильной позиции
          //_insertSortedMessage(currentMessages, updatedMsg);

          // Добавляем новое сообщение в конец, так как GroupedListView сортирует
          currentMessages.add(updatedMsg);

          // Обновляем GlobalKey для нового сообщения
          if (!_messageKeys.containsKey(updatedMsg.id)) {
            _messageKeys[updatedMsg.id] = GlobalKey();
          }
          hasChanges = true; // Устанавливаем флаг, так как добавлено новое сообщение
          if (!updatedMsg.isRead && updatedMsg.artritFromId != _userId) {
            newMsgExists = true;
          }
        }
      }

      // Обновляем идентификаторы
      _firstMessageId = dataUpdateMessages.result.firstMessageId ?? _firstMessageId;
      _lastMessageId = dataUpdateMessages.result.lastMessageId != null &&
          (_lastMessageId == 0 || dataUpdateMessages.result.lastMessageId! < _lastMessageId)
          ? dataUpdateMessages.result.lastMessageId!
          : _lastMessageId;
    }

    // Обновляем список сообщений только если были изменения
    if (mounted && hasChanges) {
      _messagesNotifier.value = List<Message>.from(currentMessages);
    }
    _isLoadingMessagesNotifier.value = false;

    bool isAtBottom = _scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100; // Допуск 100 пикселей

    if (isAtBottom && mounted) {
      // Прокручиваем взниз, если был почти внизу
      _scrollToBottom();
    }

    // Показываем баннер для новых сообщений, если пользователь не внизу
    if (mounted && !isAtBottom && newMsgExists && _firstMessageId != 0 && showBanner) {
      _isNewMessagesNotifier.value = true;
    }

    // Помечаем сообщения как прочитанные
    DataResult3? readMsgResult = await _setAsRead();
    if (readMsgResult?.success == true && mounted) {
      // Обновляем messageCount в ChatProvider после чтения сообщений
      await _chatProvider.onMessagesRead(context: context);
      _readMsg(isAwait: true);
    }
  }






  /// Загрузка истории сообщений
  Future<void> _loadMsgHistory() async {
    if (_isLoadingHistoryNotifier.value) return;
    _isLoadingHistoryNotifier.value = true;

    try {
      // Получаем информацию о верхнем видимом сообщении
      final topMessageInfo = await Future.delayed(
        const Duration(milliseconds: 100),
        _getTopVisibleMessageInfo,
      );

      final dataHistoryMessages = await _api.getMessagesHistory(
        ssId: _ssId,
        lastMessageId: _lastMessageId,
        chatId: _chatId,
      );

      if (dataHistoryMessages != null && dataHistoryMessages.success == true) {
        final historyMessages = dataHistoryMessages.result.messages;
        final currentMessages = List<Message>.from(_messagesNotifier.value);

        // Добавляем новые сообщения
        // for (final historyMsg in historyMessages) {
        //   if (!currentMessages.any((e) => e.id == historyMsg.id)) {
        //     _insertSortedMessage(currentMessages, historyMsg);
        //     // Обновляем GlobalKey для нового сообщения
        //     if (!_messageKeys.containsKey(historyMsg.id)) {
        //       _messageKeys[historyMsg.id] = GlobalKey();
        //     }
        //   }
        // }

        // Обновляем список сообщений
        if (mounted) {
          _messagesNotifier.value = List<Message>.from([...historyMessages, ...currentMessages]);
        }
        _lastMessageId = dataHistoryMessages.result.lastMessageId ?? _lastMessageId;

        // Восстанавливаем позицию прокрутки
        if (topMessageInfo != null && _scrollController.hasClients && mounted) {
          _renderStabilizationTimer?.cancel();
          _renderStabilizationTimer = Timer(const Duration(milliseconds: 300), () {
            if (!mounted || !_scrollController.hasClients) {
              debugPrint('Scroll restoration aborted: not mounted or no clients');
              return;
            }

            final messages = _messagesNotifier.value;
            final topMessageIndex = messages.indexWhere((msg) => msg.id == topMessageInfo.messageId);

            debugPrint('Restoring history scroll: topMessageId=${topMessageInfo.messageId}, index=$topMessageIndex');

            if (topMessageIndex != -1) {
              final key = _messageKeys[topMessageInfo.messageId];
              if (key != null && key.currentContext != null) {
                final renderBox = key.currentContext!.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final newPosition = renderBox.localToGlobal(Offset.zero).dy;
                  final newOffset = (newPosition - topMessageInfo.offsetFromViewportTop).clamp(
                    _scrollController.position.minScrollExtent,
                    _scrollController.position.maxScrollExtent,
                  );
                  Future.delayed(Duration(milliseconds: 200));
                  _scrollController.jumpTo(newOffset);
                  debugPrint('Scrolled to message ID: ${topMessageInfo.messageId} at offset: $newOffset');
                  return;
                }
              }
            } else {
              // Если сообщение не найдено, сохраняем текущую позицию
              debugPrint('Top message ID ${topMessageInfo.messageId} not found, maintaining position');
              _scrollController.jumpTo(_scrollController.offset);
            }
          });
        }
      } else {
        debugPrint('Failed to load message history: ${dataHistoryMessages?.userMessage}');
      }
    } catch (e) {
      debugPrint('Ошибка загрузки истории сообщений: $e');
    } finally {
      _isLoadingHistoryNotifier.value = false;
    }

    // Помечаем сообщения как прочитанные
    DataResult3? readMsgResult = await _setAsRead();
    if (readMsgResult?.success == true && mounted) {
      // Обновляем messageCount в ChatProvider после чтения сообщений
      await _chatProvider.onMessagesRead(context: context);
      _readMsg(isAwait: true);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.minScrollExtent &&
        !_isLoadingHistoryNotifier.value) {
      final messages = _messagesNotifier.value;
      if (messages.isNotEmpty) {
        debugPrint('Scroll reached top, loading history for: $_lastMessageId');
        _loadMsgHistory();
      }
    }
  }








  /// Запрос, чтобы пометить сообщения как прочитанные
  Future<DataResult3?> _setAsRead() async {
    final messages = List<Message>.from(_messagesNotifier.value);
    if (messages.isEmpty) {
      debugPrint('Список сообщений пуст');
      return null;
    }
    List<int> unreadMessageIds = messages
        .where((e) => !e.isRead && e.artritFromId != _userId)
        .map((e) => e.id)
        .toList();
    if (unreadMessageIds.isNotEmpty) {
      DataResult3? result = await _api.setAsRead(
          ssId: _ssId, chatId: _chatId, thisData: unreadMessageIds);
      return result;
    }
    return null;
  }


  /// Через 10 секунд после прочтения сообщения обновить его статус
  /// 10 секунд нужны, чтобы надпись "Непрочитанные сообщения" не исчезала сразу
  Future<void> _readMsg({required bool isAwait}) async {
    await Future.delayed(Duration(seconds: isAwait ? 10 : 0));
    final messages = List<Message>.from(_messagesNotifier.value);
    if (messages.isNotEmpty) {
      final updatedMessages = messages.map((e) {
        if (!e.isRead && e.artritFromId != _userId) {
          return Message(
            id: e.id,
            artritFromId: e.artritFromId,
            artritToId: e.artritToId,
            fromId: e.fromId,
            toId: e.toId,
            message: e.message,
            files: e.files,
            created: e.created,
            isRead: true,
          );
        }
        return e;
      }).toList();
      if (mounted) {
        _messagesNotifier.value = List<Message>.from(updatedMessages);
      }
    }
  }




  /// Метод для получения информации о верхнем видимом сообщении
  TopMessageInfo? _getTopVisibleMessageInfo() {
    if (!_scrollController.hasClients || _messagesNotifier.value.isEmpty) {
      return null;
    }

    final messages = _messagesNotifier.value;
    double minDistance = double.infinity;
    TopMessageInfo? topMessageInfo;

    for (final message in messages) {
      final key = _messageKeys[message.id];
      if (key == null || key.currentContext == null) continue;

      final renderBox = key.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      final position = renderBox.localToGlobal(Offset.zero).dy;
      final messageHeight = renderBox.size.height;
      final viewportTop = _scrollController.position.pixels;
      final viewportBottom = viewportTop + _scrollController.position.viewportDimension;

      // Проверяем, находится ли сообщение в видимой области
      if (position + messageHeight >= viewportTop && position <= viewportBottom) {
        final distance = (position - viewportTop).abs();
        if (distance < minDistance) {
          minDistance = distance;
          topMessageInfo = TopMessageInfo(
            messageId: message.id,
            offsetFromViewportTop: position - viewportTop,
            messageHeight: messageHeight,
          );
        }
      }
    }

    return topMessageInfo;
  }

















  /// Отправка сообщения
  Future<void> _sendMsg() async {
    if (_isLoadingMessagesNotifier.value) return;
    _isLoadingMessagesNotifier.value = true;
    _currentFileIndex = 0;
    if (_fileItems.isNotEmpty) _isFileSending = true;

    await _sendFile();

    /// Если все файлы отправлены успешно
    if (!_fileItems.any((e) => !(e.isSendSuccess ?? true))) {
      DataChatAddMessage thisData = DataChatAddMessage(
        toId: Roles.asPatient.contains(_role)
            ? _chatInfo!.result.doctorId
            : _chatInfo!.result.patientId,
        message: _textController.text,
        files: _fileElements,
      );

      DataChatMessage? newMessage = await _api.addMessage(
        ssId: _ssId,
        chatId: _chatId,
        thisData: thisData,
      );

      final currentMessages = List<Message>.from(_messagesNotifier.value);

      if (newMessage != null && newMessage.success) {
        //_insertSortedMessage(currentMessages, newMessage.result);

        // Добавляем новое сообщение в конец, так как GroupedListView сортирует
        currentMessages.add(newMessage.result);

        await _updateMessages(false);

        if (mounted) {
          _messagesNotifier.value = List<Message>.from(currentMessages);
        }
        // Прокручиваем к низу после рендеринга
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        setState(() {
          _textController.clear();
          _fileItems = [];
          _fileElements = [];
        });
      } else {
        ShowMessage.show(
            context: context,
            message: 'Не удалось отправить сообщение. Проверьте соединение и повторите попытку');
      }
    } else {
      if (mounted) {
        ShowMessage.show(
            context: context,
            message: 'Не удалось отправить '
                '${_fileItems.where((e) => !(e.isSendSuccess ?? true)).length > 1
                ? 'файлы: \n-' : 'файл'} ${(_fileItems.where((e) => !(e.isSendSuccess ?? true))
                .map((e) => e.fileName)).join(',\n- ')}\n______________________\nПовторите попытку');
      }
    }

    await _setAsRead();
    setState(() {
      _isFileSending = false;
      _isLoadingMessagesNotifier.value = false;
    });
  }


  /// Отправка файлов на сервер
  Future<void> _sendFile() async {
    if (_fileItems.isNotEmpty) {
      //int jj = 0;
      for (FileItems items in _fileItems) {
        if (!(items.isSendSuccess ?? false)) {
          DataChatFileSend? thisFileData = await _api.addFile(
              ssId: _ssId, chatId: _chatId, filePath: items.file.path);

          if (thisFileData != null && thisFileData.success) {
            _fileElements.add(FileElement(
                name: thisFileData.result.filename,
                url: thisFileData.result.idStr));

            /// Временный код для отладки
            // if(jj == 0 || jj == 1) {
            //   items.isSendSuccess = false;
            // } else {
            //   items.isSendSuccess = true;
            // }
            // jj++;

            /// Помечаем, что файл отправден успешно
            items.isSendSuccess = true;
            setState(() {
              _currentFileIndex++;
              _progress = _currentFileIndex / _fileItems.length;
            });
          } else {
            /// Помечаем, что файл не удалось отправить
            items.isSendSuccess = false;
          }
        }
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Снимаем фокус
        _focusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBarWidget(
          title: widget.contact.userFio,
        ),
        endDrawer: const MenuDrawer(),
        resizeToAvoidBottomInset: true, // Адаптация к клавиатуре
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return errorDataWidget(snapshot.error);
            }

            return ValueListenableBuilder<List<Message>?>(
                valueListenable: _messagesNotifier,
                builder: (context, messages, child) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: false, // Полоса прокрутки видна только во время прокрутки
                                child: Stack(
                                  children: [
                                    _buildChatContent(messages),
                                    /// Индикатор новых сообщений
                                    Positioned(
                                      top: 3,
                                      left: 5,
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: _isNewMessagesNotifier,
                                        builder: (context, isLoading, child) {
                                          return isLoading
                                              ? Center(child: Card(color: Colors.white, child: Padding(
                                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 4.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text('У вас новое сообщение', style: chatTimeStyle,),
                                                TextButton(onPressed: () {
                                                  _scrollController.animateTo(
                                                    _scrollController.position.maxScrollExtent,
                                                    duration: const Duration(milliseconds: 300),
                                                    curve: Curves.easeOut,
                                                  );
                                                  _isNewMessagesNotifier.value = false;
                                                }, child: Text('Перейти', style: TextStyle(fontSize: 13),))
                                              ],
                                            ),
                                          ))) : const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                    /// Индикатор загрузки
                                    Positioned(
                                      top: 3,
                                      left: 5,
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: _isLoadingHistoryNotifier,
                                        builder: (context, isLoading, child) {
                                          return isLoading
                                              ? const Center(child: Card(color: Colors.white, child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            child: Text('Загрузка...', style: chatTimeStyle,),
                                          ))) : const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            _buildBottomPanel(context, messages),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),

                      /// Вызов опций чата
                      GestureDetector(
                        onTap: () => ChatOptionsMenu.show(
                            context: context,
                            chatId: _chatId,
                            role: _role,
                            isChatClose: _isChatClosed,
                            onShowPolicy: _onShowPolicy,
                            onCloseChat: _onCloseChat,
                            onOpenChat: _onOpenChat),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Icon(Icons.more_vert),
                          ),
                        ),
                      ),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }






  /// Создаёт содержимое чата
  Widget _buildChatContent(List<Message>? messages) {
    /// Если еще не приняты условия чата
    if (((Roles.asDoctor.contains(_role) && !_allowByDoctor) || (Roles.asPatient.contains(_role) && !_allowByPatient)) &&
        !_isChatClosed) {
      return ChatPolitic(onConfirm: _onShowPolicy, showAgreeBtn: true);
    } else if (messages == null || messages.isEmpty) {
      return const Center(child: Text('Сообщений нет'));
    } else {
      return GroupedListView<Message, DateTime>(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        cacheExtent: 10000,
        useStickyGroupSeparators: true,
        stickyHeaderBackgroundColor: Colors.white,
        floatingHeader: true,
        elements: messages,
        // Группируем по дате (без времени)
        groupBy: (message) => DateTime(message.created.year, message.created.month, message.created.day),
        groupHeaderBuilder: (message) => ChatDividerWidget(messageDate: message.created),
        itemBuilder: (context, message) {
          if (!_messageKeys.containsKey(message.id)) {
            _messageKeys[message.id] = GlobalKey();
          }
          return Column(
            key: _messageKeys[message.id],
            children: [
              ChatDividerNewMessageWidget(
                messages: messages,
                messageIndex: messages.indexOf(message),
                isRead: message.isRead,
                userId: _userId,
              ),
              _messageWidget(message: message),
            ],
          );
        },
        // Сортировка элементов внутри групп
        // Включаем автоматическую сортировку
        sort: true,
        //sort: false,
        // Сортировка элементов внутри групп по id
        itemComparator: (item1, item2) => item1.id.compareTo(item2.id),
        // Группы сортируются по возрастанию даты (уже задано в groupBy и order)
        order: GroupedListOrder.ASC,
      );
    }
  }









  /// Создаёт нижнюю панель с превью файлов, прогресс-баром и вводом
  Widget _buildBottomPanel(BuildContext context, List<Message>? messages) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).orientation == Orientation.portrait
            ? double.infinity : 100.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Лента для предпросмотра отправляемых файлов
            ChatFilePreviewWidget(
              fileItems: _fileItems,
              isFileSendLoading: _isFileSending,
              sendVisibilityNotifier: _sendVisibilityNotifier,
              controllerText: _textController.text,
              onRemoveFile: _removeFile,
            ),
            /// Прогресс-бар отправки файлов
            if (_isFileSending)
              ChatFileUploadProgressWidget(
                progress: _progress,
                currentFileIndex: _currentFileIndex,
                totalFiles: _fileItems.length,
              ),
            /// Панель для подтверждения удаления
            _deleteMsgPanel(),
            /// Виджет баннера статуса чата
            ChatStatusBanner(
              isChatClosed: _isChatClosed,
              allowByDoctor: _allowByDoctor,
              allowByPatient: _allowByPatient,
              role: _role,
            ),
            /// Виджет панели ввода сообщения
            // Если чат не закрыт и все участники приняли условия
            if (!_isChatClosed && ((Roles.asDoctor.contains(_role) && _allowByDoctor) || (Roles.asPatient.contains(_role) && _allowByPatient)))
              ChatMessageInputPanel(
                textController: _textController,
                focusNode: _focusNode,
                onAddFile: _onAddFile,
                onShowTemplates: _showTemplatesDialog,
                onSend: _sendMsg,
                sendVisibility: _sendVisibilityNotifier,
                scrollToBottom: _scrollToBottom,
              ),
          ],
        ),
      ),
    );
  }






  /// Удаляет файл с ленты предпросмотра файлов
  void _removeFile(int index) {
    if (mounted) {
      setState(() {
        _fileItems.removeAt(index);
        _updateSendButtonVisibility();
      });
    }
  }



  /// Виджет для отображения сообщений
  Widget _messageWidget({
    required Message message,
  }) {
    return ValueListenableBuilder<Set<int>>(
        valueListenable: _selectedMessageIdsNotifier,
        builder: (context, selectedMessageIds, child) {
          return ValueListenableBuilder<bool>(
              valueListenable: _isSelectionModeNotifier,
              builder: (context, isSelectionMode, child) {
                return ChatMessageWidget(
                  message: message,
                  userId: _userId,
                  thisDataChatInfo: _chatInfo,
                  showContextMenu: _showContextMenuMessage,
                  isSelectionMode: isSelectionMode,
                  isSelected: selectedMessageIds.contains(message.id),
                  acceptMsg: _acceptMessage,
                  onToggleSelection: (messageId) {
                    // Скрываем клавиатуру
                    FocusScope.of(context).unfocus();
                    final updatedIds = Set<int>.from(selectedMessageIds);
                    if (updatedIds.contains(messageId)) {
                      updatedIds.remove(messageId);
                    } else {
                      updatedIds.add(messageId);
                    }
                    _selectedMessageIdsNotifier.value = updatedIds;
                  },
                );
              });
        });
  }




  /// Добавляет файлы через FilePicker
  Future<void> _onAddFile() async {
    FilePickerWidget(
      isVideo: true,
      onlyOneFile: false,
      onFileUploaded: (files) {
        if (mounted) {
          setState(() {
            _fileItems.addAll(files);
            _updateSendButtonVisibility();
          });
        }
      },
      onLoadingChanged: (value) {
        if (mounted) setState(() {});
      },
    ).showPicker(context);
  }



  /// Панель подтверждения удаления сообщений
  Widget _deleteMsgPanel() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isSelectionModeNotifier,
      builder: (context, isSelectionMode, child) {
        if (!isSelectionMode) return const SizedBox.shrink();
        return ValueListenableBuilder<Set<int>>(
          valueListenable: _selectedMessageIdsNotifier,
          builder: (context, selectedMessageIds, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Выбрано: ${selectedMessageIds.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          _isSelectionModeNotifier.value = false;
                          _selectedMessageIdsNotifier.value = {};
                          _focusNode.unfocus();
                        },
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: selectedMessageIds.isNotEmpty ? () => _deleteMsg(selectedMessageIds.toList()) : null,
                        child: const Text('Удалить'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }




  /// Метод удаления сообщений
  Future<void> _deleteMsg(List<int> msgIds) async {
    ShowDialogConfirm.show(
      context: context,
      message: 'Вы действительно хотите удалить ${msgIds.length} сообщений?',
      onConfirm: () async {
        final result = await _api.deleteMessage(ssId: _ssId, chatId: _chatId, msgId: msgIds);
        final userMessage = result.success
            ? (msgIds.length > 1 ? 'Сообщения удалены' : 'Сообщение удалено')
            : result.userMessage ?? 'Неизвестная ошибка';
        if (result.success) {
          _isSelectionModeNotifier.value = false;
          _selectedMessageIdsNotifier.value = {};
          final currentMessages = List<Message>.from(_messagesNotifier.value);
          currentMessages.removeWhere((msg) => msgIds.any((e) => e == msg.id));
          if (mounted) {
            _messagesNotifier.value = List<Message>.from(currentMessages);
          }
          await _updateMessages(true);
        }
        showBottomBanner(context: context, message: userMessage, seconds: 1);
      },
    );
  }


  /// Удалить сообщение
  Future<void> _onDelete({required Message message}) async {
    _focusNode.unfocus();
    if (_acceptMessage == message.message) {
      showBottomBanner(
          context: context, message: 'Нельзя удалять системные сообщения');
    } else {
      _isSelectionModeNotifier.value = true;
      _selectedMessageIdsNotifier.value = {message.id};
    }
  }

  /// Копировать сообщение
  Future<void> _onCopy({required Message message}) async {
    _focusNode.unfocus();
    Clipboard.setData(ClipboardData(text: message.message));
    if (mounted) {
      showBottomBanner(
          context: context, message: 'Сообщение скопировано', seconds: 1);
    }
  }

  /// Скачать все файлы в сообщении
  Future<void> _onDownload({
    required Message message,
  }) async {
    // Снимаем фокус с TextField
    _focusNode.unfocus();
    for (FileElement file in message.files) {
      await downloadFile(
          fileName: file.name,
          fileId: file.url,
          context: context,
          isChatFiles: true,
          chatId: _chatId);
      debugPrint('Скачивание файла ${file.name}');
    }
  }

  /// Согласие с политикой чата
  Future<void> _onShowPolicy() async {
    DataChatInfo? result = await _api.allowChat(ssId: _ssId, chatId: _chatId);
    if (result != null && result.success) {
      showBottomBanner(context: context, message: 'Вы приняли политику чата');
      _textController.text = _acceptMessage;
      _sendMsg();
      setState(() {
        if (Roles.asDoctor.contains(_role)) {
          _allowByDoctor = result.result.allowByDoctor;
        } else if (Roles.asPatient.contains(_role)) {
          _allowByPatient = result.result.allowByPatient;
        }
      });
    } else {
      showBottomBanner(context: context,
          message: result?.userMessage ?? 'Неизвестная ошибка');
    }
  }

  /// Закрыть чат
  Future<void> _onCloseChat() async {
    ShowDialogConfirm.show(
      context: context,
      title: 'Закрыть чат',
      message:
      'Вы уверены, что хотите закрыть этот чат? Пользователь не сможет писать Вам.',
      onConfirm: () async {
        DataChatInfo? result =
        await _api.closeChat(ssId: _ssId, chatId: _chatId);
        if (result != null && result.success) {
          showBottomBanner(context: context, message: 'Чат закрыт');
          setState(() {
            _isChatClosed = result.result.isClosed;
          });
        } else {
          showBottomBanner(
              context: context,
              message: result?.userMessage ?? 'Ошибка закрытия чата');
        }
      },
    );
  }

  /// Открыть чат
  Future<void> _onOpenChat() async {
    ShowDialogConfirm.show(
      context: context,
      title: 'Открыть чат',
      message: 'Вы уверены, что хотите открыть этот чат?',
      onConfirm: () async {
        DataChatInfo? result =
        await _api.openChat(ssId: _ssId, chatId: _chatId);
        if (result != null && result.success) {
          showBottomBanner(context: context, message: 'Чат открыт');
          setState(() {
            _isChatClosed = result.result.isClosed;
          });
        } else {
          showBottomBanner(
              context: context,
              message: result?.userMessage ?? 'Ошибка закрытия чата');
        }
      },
    );
  }



  /// Показывает контекстное меню для сообщения
  Future<void> _showContextMenuMessage(
      BuildContext context, Message message, GlobalKey messageKey) async {
    // Снимаем фокус с TextField
    _focusNode.unfocus();
    final messageContext = messageKey.currentContext;
    if (messageContext == null) {
      debugPrint('Ошибка: messageContext не найден');
      return;
    }

    final RenderBox? messageBox =
    messageContext.findRenderObject() as RenderBox?;
    if (messageBox == null) {
      debugPrint('Ошибка: messageBox не найден');
      return;
    }

    final position = messageBox.localToGlobal(Offset.zero);
    final messageHeight = messageBox.size.height;
    final screenHeight = MediaQuery.of(context).size.height;

    const menuHeightEstimate = 100.0;
    bool showAbove =
        (position.dy + messageHeight + menuHeightEstimate) > screenHeight;

    final result = await showMenu(
      context: context,
      color: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      position: RelativeRect.fromLTRB(
        position.dx,
        showAbove
            ? position.dy - menuHeightEstimate
            : position.dy + messageHeight,
        position.dx + messageBox.size.width,
        showAbove ? position.dy : screenHeight,
      ),
      items: [
        if (message.message.isNotEmpty)
          PopupMenuItem<String>(
            value: 'copy',
            child: Row(
              children: [
                Icon(Icons.copy, size: 20, color: btnColor),
                const SizedBox(width: 8),
                const Text('Копировать текст'),
              ],
            ),
          ),
        if (message.files.isNotEmpty)
          PopupMenuItem<String>(
            value: 'download',
            child: Row(
              children: [
                Icon(Icons.download, size: 20, color: btnColor),
                const SizedBox(width: 8),
                Text(message.files.length == 1
                    ? 'Скачать файл'
                    : 'Скачать файлы'),
              ],
            ),
          ),
        if (message.artritFromId == _userId)
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: redBtnColor),
                const SizedBox(width: 8),
                const Text('Удалить'),
              ],
            ),
          ),
      ],
    );

    if (result != null) {
      switch (result) {
        case 'copy':
          await _onCopy(message: message);
          break;
        case 'download':
          await _onDownload(message: message);
          break;
        case 'delete':
          await _onDelete(message: message);
          break;
      }
    }
  }

  /// Диалог для выбора шаблонов
  void _showTemplatesDialog() {
    // Множество для отслеживания выбранных сообщений
    final selectedMessages = <String>{};

    // Инициализируем выбранные сообщения на основе текущего текста в TextField
    final currentTextLines = _textController.text
        .split('\n')
        .where((line) => line.isNotEmpty)
        .map((line) => line.trim()) // Убираем пробелы в начале и конце
        .toList();
    for (var template in _templates) {
      for (var message in template.messages) {
        // Проверяем, содержит ли какая-либо строка шаблон
        if (currentTextLines.any((line) => line.contains(message))) {
          selectedMessages.add(message);
        }
      }
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выберите шаблоны'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: double.maxFinite,
                child: _templates.isEmpty
                    ? const Text('Шаблоны отсутствуют')
                    : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _templates.expand((template) {
                      return [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Text(
                            template.messageTypeStr ?? 'Нет категории',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ...template.messages.map((message) {
                          final isSelected =
                          selectedMessages.contains(message);
                          return CheckboxListTile(
                            title: Text(message),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedMessages.add(message);
                                } else {
                                  selectedMessages.remove(message);
                                }
                              });

                              // Обновляем TextField
                              final currentLines = _textController.text
                                  .split('\n')
                                  .where((line) => line.isNotEmpty)
                                  .toList();
                              if (value == true) {
                                // Добавляем шаблон, если его нет
                                if (!currentLines.any(
                                        (line) => line.contains(message))) {
                                  currentLines.add(message);
                                }
                              } else {
                                // Удаляем только фрагмент, соответствующий шаблону
                                for (int i = 0;
                                i < currentLines.length;
                                i++) {
                                  if (currentLines[i].contains(message)) {
                                    currentLines[i] = currentLines[i]
                                        .replaceFirst(message, '');
                                  }
                                }

                                // Удаляем пустые строки
                                currentLines.removeWhere(
                                        (line) => line.trim().isEmpty);
                              }
                              _textController.text =
                                  currentLines.join('\n');
                              _textController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                        offset: _textController.text.length),
                                  );
                            },
                          );
                        }),
                      ];
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Готово'),
            ),
          ],
        );
      },
    );
  }
}






/// Структура для хранения информации о верхнем видимом сообщении
class TopMessageInfo {
  final int messageId;
  final double offsetFromViewportTop; // Смещение относительно верхней границы области просмотра
  final double messageHeight; // Высота сообщения

  TopMessageInfo({
    required this.messageId,
    required this.offsetFromViewportTop,
    required this.messageHeight,
  });
}


