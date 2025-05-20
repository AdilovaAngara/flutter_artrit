import 'package:artrit/data/data_notifications_for_doctor.dart';
import 'package:artrit/theme.dart';
import 'package:flutter/material.dart';
import '../api/api_notifications.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../routes.dart';
import '../secure_storage.dart';

class PageNotificationsForDoctor extends StatefulWidget {
  final List<DataNotificationsForDoctor> thisData;
  final VoidCallback? onDataUpdated;

  const PageNotificationsForDoctor({
    super.key,
    required this.thisData,
    required this.onDataUpdated,
  });

  @override
  State<PageNotificationsForDoctor> createState() =>
      _PageNotificationsForPatientState();
}

class _PageNotificationsForPatientState
    extends State<PageNotificationsForDoctor> {
  late Future<void> _future;

  /// API
  final ApiNotifications _api = ApiNotifications();

  /// Данные
  late List<DataNotificationsForDoctor> _thisDataUnread = [];
  late List<DataNotificationsForDoctor> _thisDataRead = [];
  late List<DataNotificationsForDoctor> _thisDataFiltered = [];

  /// Параметры
  late int _role;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    if (Roles.asDoctor.contains(_role)) {
      _thisDataFiltered = List.from(widget.thisData); // Создаём копию
      _updateNotificationLists();
    }
    setState(() {});
  }

  /// Разделяем уведомления на непрочитанные и прочитанные
  void _updateNotificationLists() {
    _thisDataUnread =
        _thisDataFiltered.where((n) => !(n.seen ?? false)).toList();
    _thisDataRead = _thisDataFiltered.where((n) => n.seen ?? false).toList();
  }

  // Future<void> _setNotificationsAsRead(String recordId, int index) async {
  //   await _api.setAsRead(recordId: recordId);
  //   _thisDataFiltered = await _api.getNotificationsForDoctor(); // Предполагаемый метод API
  //   _updateNotificationLists();
  // widget.onDataUpdated?.call(); // ✅ Вызываем колбэк
  //   setState(() {});
  // }

  Future<void> _setNotificationsAsRead(String recordId, int index) async {
    await _api.setAsRead(recordId: recordId);

    /// Обновляем локальный список
    if (index >= 0 && index < _thisDataFiltered.length) {
      _thisDataFiltered[index] = DataNotificationsForDoctor(
        id: _thisDataFiltered[index].id,
        testId: _thisDataFiltered[index].testId,
        patientId: _thisDataFiltered[index].patientId,
        patientFio: _thisDataFiltered[index].patientFio,
        parameter: _thisDataFiltered[index].parameter,
        value: _thisDataFiltered[index].value,
        unit: _thisDataFiltered[index].unit,
        limits: _thisDataFiltered[index].limits,
        created: _thisDataFiltered[index].created,
        seen: true, // Помечаем как прочитанное
      );
    }
    _updateNotificationLists();
    widget.onDataUpdated?.call(); // ✅ Вызываем колбэк
    setState(() {});
  }

  void _filter(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _thisDataFiltered = widget.thisData.where((item) {
        return (item.patientFio?.toLowerCase().contains(_searchQuery) ??
                false) ||
            (item.parameter?.toLowerCase().contains(_searchQuery) ?? false) ||
            item.value.toString().contains(_searchQuery) ||
            (dateFormat(item.created)?.toLowerCase().contains(_searchQuery) ??
                false);
      }).toList();
      _updateNotificationLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return errorDataWidget(snapshot.error);
          }

          return AlertDialog(
            title: const Text(
              'Уведомления',
              style: formHeaderStyle,
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  /// Поле поиска
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Поиск...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onChanged: _filter,
                    ),
                  ),
                  _thisDataFiltered.isEmpty
                      ? const Center(child: Text('Нет уведомлений'))
                      : Expanded(
                          child: ListView(
                            children: [
                              /// Непрочитанные уведомления
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Новые', style: captionTextStyle),
                              ),
                              if (_thisDataUnread.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Text('Новых уведомлений нет',
                                      style: subtitleTextStyle),
                                )
                              else
                                ..._thisDataUnread.asMap().entries.map((entry) {
                                  final index =
                                      _thisDataFiltered.indexOf(entry.value);
                                  final notification = entry.value;
                                  return _buildNotificationTile(
                                    notification: notification,
                                    index: index,
                                    showMarkAsRead: true,
                                  );
                                }),

                              /// Прочитанные уведомления
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Архив', style: captionTextStyle),
                              ),
                              if (_thisDataFiltered.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Text('Нет уведомлений',
                                      style: subtitleTextStyle),
                                )
                              else
                                ..._thisDataRead.asMap().entries.map((entry) {
                                  final index =
                                      _thisDataFiltered.indexOf(entry.value);
                                  final notification = entry.value;
                                  return _buildNotificationTile(
                                    notification: notification,
                                    index: index,
                                    showMarkAsRead: false,
                                  );
                                }),
                            ],
                          ),
                        ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          );
        });
  }

  Widget _buildNotificationTile({
    required DataNotificationsForDoctor notification,
    required int index,
    required bool showMarkAsRead,
  }) {
    return ListTile(
      title: GestureDetector(
        onTap: () async {
          if (notification.patientId != null) {
            await deleteSecureData(SecureKey.patientsId);
            await saveSecureData(SecureKey.patientsId, notification.patientId!);
            if (mounted) {
              Navigator.pushNamed(context, AppRoutes.patientMain);
            }
          }
        },
        child: Text(
          (notification.patientFio ?? 'ФИО не указано').trim().isNotEmpty
              ? (notification.patientFio ?? 'ФИО не указано').trim()
              : 'ФИО не указано',
          style: hyperTextStyle,
        ),
      ),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          RichText(
            maxLines: 5,
            softWrap: true,
            text: TextSpan(
              children: [
                const TextSpan(text: 'Дата:  ', style: subtitleTextStyle),
                TextSpan(
                  text: dateFormat(notification.created) ?? 'Дата не указана',
                  style: subtitleTextStyle,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),
          RichText(
            maxLines: 5,
            softWrap: true,
            text: TextSpan(
              children: [
                const TextSpan(text: 'Показатель:  ', style: subtitleTextStyle),
                TextSpan(
                  text: notification.parameter ?? '',
                  style: subtitleBoldTextStyle,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),
          RichText(
            maxLines: 5,
            softWrap: true,
            text: TextSpan(
              children: [
                const TextSpan(text: 'Событие:  ', style: subtitleTextStyle),
                TextSpan(
                  text: 'Отклонение от нормы',
                  style: subtitleTextStyle,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),
          RichText(
            maxLines: 5,
            softWrap: true,
            text: TextSpan(
              children: [
                const TextSpan(
                    text: 'Текущее значение:  ', style: subtitleTextStyle),
                TextSpan(
                  text: notification.value.toString(),
                  style: subtitleBoldTextStyle,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),
          RichText(
            maxLines: 5,
            softWrap: true,
            text: TextSpan(
              children: [
                const TextSpan(text: 'Норма:  ', style: subtitleTextStyle),
                TextSpan(
                  text: notification.limits,
                  style: subtitleTextStyle,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),
          const Divider(
            height: 20, // Высота с учётом отступов
            thickness: 0.5, // Толщина линии
            color: Colors.black45, // Цвет линии
          ),
        ],
      ),
      trailing: showMarkAsRead
          ? IconButton(
              tooltip: 'Сделать прочитанным',
              onPressed: () async {
                await _setNotificationsAsRead(notification.id, index);
                setState(() {}); // Обновляем диалог
              },
              icon: const Icon(
                Icons.playlist_add_check_outlined,
                color: Colors.green,
                size: 30,
              ),
            )
          : null,
    );
  }
}
