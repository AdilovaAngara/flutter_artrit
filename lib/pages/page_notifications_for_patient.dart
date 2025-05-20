import 'package:artrit/data/data_notifications.dart';
import 'package:artrit/theme.dart';
import 'package:flutter/material.dart';
import '../api/api_notifications.dart';
import '../my_functions.dart';
import '../roles.dart';

class PageNotificationsForPatient extends StatefulWidget {
  final List<DataNotificationsForPatient> thisData;
  final VoidCallback? onDataUpdated;
  const PageNotificationsForPatient({
    super.key,
    required this.thisData,
    required this.onDataUpdated,
  });

  @override
  State<PageNotificationsForPatient> createState() => _PageNotificationsForPatientState();
}

class _PageNotificationsForPatientState extends State<PageNotificationsForPatient> {
  late Future<void> _future;

  /// API
  final ApiNotifications _api = ApiNotifications();

  /// Данные
  List<DataNotificationsForPatient> _thisData = [];
  List<DataNotificationsForPatient> _thisDataUnread = [];
  List<DataNotificationsForPatient> _thisDataRead = [];

  /// Параметры
  late int _role;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    if (Roles.asPatient.contains(_role)) {
      _thisData = List.from(widget.thisData); // Создаём копию;
      _updateNotificationLists();
    }
    setState(() {});
  }

  /// Разделяем уведомления на непрочитанные и прочитанные
  void _updateNotificationLists() {
    _thisDataUnread =
        _thisData.where((n) => !(n.isRead ?? false)).toList();
    _thisDataRead =
        _thisData.where((n) => n.isRead ?? false).toList();
  }


  Future<void> _setNotificationsAsRead(String recordId, int index) async {
    await _api.setAsRead(recordId: recordId);
    //_thisData = await _api.getForPatient();
    /// Обновляем локальный список
    if (index >= 0 && index < _thisData.length) {
      _thisData[index] = DataNotificationsForPatient(
        id: _thisData[index].id,
        userId: _thisData[index].userId,
        typeId: _thisData[index].typeId,
        data: _thisData[index].data,
        createdOn: _thisData[index].createdOn,
        isRead: true,  // Помечаем как прочитанное
      );
    }
    _updateNotificationLists();
    widget.onDataUpdated?.call(); // ✅ Вызываем колбэк
    setState(() {});
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
          title: const Text('Уведомления',
            style: formHeaderStyle,
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: _thisData.isEmpty
                ? const Center(child: Text('Нет уведомлений'))
                : ListView(
              children: [
                /// Непрочитанные уведомления
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Новые', style: captionTextStyle),
                ),
                if (_thisDataUnread.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text('Новых уведомлений нет', style: subtitleTextStyle),
                  )
                else
                  ..._thisDataUnread.asMap().entries.map((entry) {
                    final index = _thisData.indexOf(entry.value);
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
                if (_thisDataRead.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text('Нет уведомлений', style: subtitleTextStyle),
                  )
                else
                  ..._thisDataRead.asMap().entries.map((entry) {
                    final index = _thisData.indexOf(entry.value);
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        );
      }
    );
  }

  Widget _buildNotificationTile({
    required DataNotificationsForPatient notification,
    required int index,
    required bool showMarkAsRead,
  }) {
    return ListTile(
      title: Text(
        dateFormat(notification.createdOn) ?? 'Дата не указана',
        style: subtitleTextStyle,
      ),
      subtitle: Text(
        _getNotificationsMessage(notification),
        style: textStyleMini,
      ),
      trailing: showMarkAsRead
          ? IconButton(
        onPressed: () async {
          await _setNotificationsAsRead(notification.id, index);
          setState(() {});
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

  String _getNotificationsMessage(DataNotificationsForPatient notification) {
    if (notification.typeId == 7) {
      return 'Пожалуйста, актуализируйте данные о приеме лекарственных средств в Системе';
    } else if (notification.typeId == 5) {
      return 'Обновите информацию в следующих разделах: ${notification.data != null && notification.data!.sections != null ? notification.data!.sections!.join(', ') : ''}';
    } else {
      return 'Текст уведомления отсутствует';
    }
  }
}