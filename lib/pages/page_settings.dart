import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_patient.dart';
import '../api/api_settings.dart';
import '../data/data_patient.dart';
import '../data/data_result.dart';
import '../data/data_settings_notification.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/audio_provider.dart';
import '../widgets/button_widget.dart';
import '../widgets/checkbox_group_widget.dart';
import '../widgets/show_dialog_confirm.dart';
import '../widgets/show_dialog_delete.dart';
import '../widgets/show_message.dart';
import 'menu.dart';


class PageSettings extends StatefulWidget {
  final String title;

  const PageSettings({
    super.key,
    required this.title,
  });

  @override
  State<PageSettings> createState() => _PageSettingsState();
}


class _PageSettingsState extends State<PageSettings> {
  late Future<void> _future;
  /// API
  final ApiPatient _api = ApiPatient();
  final ApiSettings _apiSettings = ApiSettings();

  /// Данные
  late DataPatient _dataPatient;

  /// Параметры
  bool _isLoading = false; // Флаг загрузки
  late int _role;
  late String _userId;
  late String _patientsId;
  String _cacheSize = '';
  bool _agreeEmail = false;
  bool _agreeLk = false;
  late int? _notificationReceiveType;


  /// Ключи
  final _formDialogKey = GlobalKey<FormState>();
  final _checkboxGroupKey = GlobalKey<FormFieldState<List<bool>>>();

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }


  Future<void> _loadData() async {
    _role = await getUserRole();
    _userId = await readSecureData(SecureKey.userId);
    _cacheSize = CacheManager.calculateTotalCacheSize();
    if (Roles.asPatient.contains(_role))
    {
      _patientsId = await readSecureData(SecureKey.patientsId);
      _dataPatient = await _api.get(patientsId: _patientsId);
      _notificationReceiveType = _dataPatient.notificationReceiveType;
      _agreeEmail = [0, 2].contains(_notificationReceiveType);
      _agreeLk = [0, 1].contains(_notificationReceiveType);
    }
    setState(() {});
  }


  Future<bool> _saveData(int notificationReceiveType) async {
    if (!_formDialogKey.currentState!.validate()) {
      ShowMessage.show(context: context);
      return false;
    }

    DataResult3 result = await _request(notificationReceiveType);

    if (result.success) {
      return true;
    } else {
      ShowMessage.show(context: context, message: result.userMessage ?? 'Неизвестная ошибка');
      return false;
    }
  }


  Future<DataResult3> _request(int notificationReceiveType) async {
    DataSettingsNotification thisData = DataSettingsNotification(
        notificationReceiveType: notificationReceiveType
    );
    return await _apiSettings.putNotification(thisData: thisData);
  }



  void _showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ShowDialogDelete(
          text: 'Вы действительно хотите удалить учетную запись без возможности восстановления? Все данные будут стёрты',
          onConfirm: () async {
            setState(() {
              _isLoading = true;
            });
            DataResult4 result = await _api.deleteUser(userId: _userId);
            setState(() {
              _isLoading = false;
            });
            if (result.success)
              {
                ShowMessage.show(context: context,
                    onConfirm: () => navigateToPageMenu(context, EnumMenu.logOut),
                    message: 'Учетная запись успешно удалена');
              }
          },
        );
      },
    );
  }


  // Очистить кеш
  void _clearCache(context) {
    ShowDialogConfirm.show(
      context: context,
      message: 'Вы действительно хотите очистить кеш?',
      onConfirm: () {
        CacheManager.clearCache();
        ShowMessage.show(context: context, message: 'Кеш очищен!\nОбщий объём удалённого кэша: $_cacheSize');
        _cacheSize = CacheManager.calculateTotalCacheSize();
        setState(() {

        });
      }
    );
  }




  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.title,
      ),
      endDrawer: MenuDrawer(),
      body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return errorDataWidget(snapshot.error);
            }
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ButtonWidget(
                        labelText: '${audioProvider.isSoundEnabled ? 'Отключить' : 'Включить'} звуки приложения',
                        icon: audioProvider.isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                        iconColor: Colors.blue.shade300,
                        iconAlignment: IconAlignment.start,
                        onlyText: true,
                        listRoles: Roles.all,
                        onPressed: () {
                          bool value = audioProvider.isSoundEnabled;
                          value = !value;
                          audioProvider.setSoundEnabled(value);
                        },
                      ),
                      if (audioProvider.isSoundEnabled)...[
                      ListTile(
                        title: Text('Громкость'),
                        subtitle: Slider(
                          value: audioProvider.volume,
                          onChanged: (value) {
                            audioProvider.setVolume(value);
                          },
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          label: audioProvider.volume.toStringAsFixed(1),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0,),
                          child: ElevatedButton(
                            onPressed: () {
                              audioProvider.playNotificationSound();
                            },
                            child: Text('Проверить громкость'),
                          ),
                        ),
                      ),
                      ]
                    ],
                  ),
              
                  ButtonWidget(
                    labelText: 'Очистить кэш ($_cacheSize)',
                    icon: Icons.brush,
                    iconColor: Colors.blue.shade300,
                    iconAlignment: IconAlignment.start,
                    onlyText: true,
                    listRoles: Roles.all,
                    onPressed: () {
                      _clearCache(context);
                    },
                  ),
              
                  if (Roles.asPatient.contains(_role)) ...[
                    ButtonWidget(
                      labelText: 'Способ получения уведомлений',
                      icon: Icons.notifications,
                      iconColor: Colors.orange.shade300,
                      iconAlignment: IconAlignment.start,
                      onlyText: true,
                      listRoles: Roles.asPatient,
                      role: _role,
                      onPressed: () {
                        _showEditNotificationsDialog();
                      },
                    ),
                    if (_userId.isNotEmpty)
                      ButtonWidget(
                        labelText: 'Удалить учетную запись',
                        icon: Icons.no_accounts,
                        iconColor: redBtnColor,
                        iconAlignment: IconAlignment.start,
                        onlyText: true,
                        showProgressIndicator: _isLoading,
                        listRoles: Roles.asPatient,
                        role: _role,
                        onPressed: () {
                          String testUserId = '61148CB9-12CA-4548-A750-DCC4AC8A8992'; // Репнина
                          if (_userId.toLowerCase() != testUserId.toLowerCase()) {
                            _showDeleteDialog();
                          }
                          else {
                            ShowMessage.show(context: context, message: 'Этого пациента удалять нельзя. Мы на нем тестируем');
                          }
                        },
                      ),
                  ],
                ],
              ),
            ),
          );
        }
      ),
    );
  }








  void _showEditNotificationsDialog() {
    bool agreeEmail = _agreeEmail;
    bool agreeLk = _agreeLk;

    showDialog(
        context: context,
        barrierDismissible: false, // Диалог не закроется при клике вне его
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext dialogContext, StateSetter setDialogState) {
                return Form(
                  key: _formDialogKey,
                  child: AlertDialog(
                    title: Text('Способ получения уведомлений', style: formHeaderStyle),
                    content: SingleChildScrollView(
                      child: CheckboxGroupWidget(
                        labelText: '',
                        listAnswers: ['E-mail', 'Личный кабинет'],
                        fieldKey: _checkboxGroupKey,
                        selectedIndexes: [agreeEmail, agreeLk],
                        required: true,
                        showDivider: false,
                        listRoles: Roles.asPatient,
                        role: _role,
                        onChanged: (value) {
                          setState(() {
                            agreeEmail = value[0];
                            agreeLk = value[1];
                          });
                        },
                      ),),
                    actions: [
                      ButtonWidget(
                        labelText: 'Отмена',
                        onlyText: true,
                        dialogForm: true,
                        listRoles: Roles.asPatient,
                        role: _role,
                        onPressed: () {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(width: 10),
                      ButtonWidget(
                        labelText: 'Сохранить',
                        onlyText: true,
                        dialogForm: true,
                        showProgressIndicator: _isLoading,
                        listRoles: Roles.asPatient,
                        role: _role,
                        onPressed: () async {
                          setDialogState(() {
                            _isLoading = true; // Обновляем состояние внутри диалога
                          });
                          int notificationReceiveType = getNotificationReceiveType(agreeEmail: agreeEmail, agreeLk: agreeLk);
                          bool success = await _saveData(notificationReceiveType);
                          if (success && context.mounted) {
                            await Future.delayed(Duration(microseconds: 10));
                            Navigator.pop(dialogContext);
                            _agreeLk = agreeLk;
                            _agreeEmail = agreeEmail;
                          }
                          if (context.mounted) {
                            setDialogState(() {
                              _isLoading = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                );
              });
        });
  }









}








class CacheManager {
  static final Map<String, Uint8List> thumbnailCache = {};
  static final Map<String, Uint8List> fullImageCache = {};
  static final Map<String, Uint8List> pdfCache = {};
  static final Map<String, Uint8List> docCache = {};
  static final Map<String, String> txtCache = {};
  static final Map<String, String> videoCache = {};

  static int _calculateCacheSize(Map<String, Uint8List> cache) {
    return cache.values.fold(0, (sum, bytes) => sum + bytes.length);
  }

  static int _calculateTextCacheSize(Map<String, String> cache) {
    return cache.values.fold(0, (sum, text) => sum + utf8.encode(text).length);
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes Б';
    } else if (bytes < 1024 * 1024) {
      double kb = bytes / 1024;
      return '${kb.toStringAsFixed(2)} КБ';
    } else {
      double mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(2)} МБ';
    }
  }

  static String calculateTotalCacheSize() {
    // Вычисляем размер каждого кэша
    int thumbnailSize = _calculateCacheSize(thumbnailCache);
    int fullImageSize = _calculateCacheSize(fullImageCache);
    int pdfSize = _calculateCacheSize(pdfCache);
    int docSize = _calculateCacheSize(docCache);
    int txtSize = _calculateTextCacheSize(txtCache);
    int videoSize = _calculateTextCacheSize(videoCache);
    debugPrint("Объем thumbnailCache: ${_formatSize(thumbnailSize)}");
    debugPrint("Объем fullImageCache: ${_formatSize(fullImageSize)}");
    debugPrint("Объем pdfCache: ${_formatSize(pdfSize)}");
    debugPrint("Объем docCache: ${_formatSize(docSize)}");
    debugPrint("Объем txtCache: ${_formatSize(txtSize)}");
    debugPrint("Объем videoSize: ${_formatSize(videoSize)}");
    return _formatSize(thumbnailSize + fullImageSize + pdfSize + docSize + txtSize + videoSize);
  }


  static void clearCache() {
    String totalCacheSize = calculateTotalCacheSize();

    // Очищаем кэш
    thumbnailCache.clear();
    fullImageCache.clear();
    pdfCache.clear();
    docCache.clear();
    txtCache.clear();
    videoCache.clear();

    // Выводим информацию о размере удалённого кэша
    debugPrint("🧹 Кеш очищен!");
    debugPrint("Общий объём удалённого кэша: $totalCacheSize");
  }
}