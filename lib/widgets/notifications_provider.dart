import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_notifications.dart';
import '../data/data_notifications.dart';
import '../data/data_notifications_for_doctor.dart';
import '../my_functions.dart';
import '../roles.dart';

class NotificationsProvider with ChangeNotifier {
  final ApiNotifications _apiNotifications = ApiNotifications();
  List<DataNotificationsForPatient>? _dataPatientNotifications = [];
  List<DataNotificationsForDoctor>? _dataDoctorNotifications = [];
  int _notificationsCount = 0;
  int? _role;
  Timer? _timer;
  bool _isInitialized = false;

  int get notificationsCount => _notificationsCount;
  List<DataNotificationsForPatient>? get patientNotifications => _dataPatientNotifications;
  List<DataNotificationsForDoctor>? get doctorNotifications => _dataDoctorNotifications;

  NotificationsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    _role = await getUserRole();
    await _updateNotificationsCount();
    // Запускаем таймер для периодического обновления
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      await _updateNotificationsCount();
    });
  }

  Future<void> _updateNotificationsCount() async {
    if (_role == null) return;
    if (Roles.asPatient.contains(_role!)) {
      await _updatePatientNotificationsCount();
    } else if (Roles.asDoctor.contains(_role!)) {
      await _updateDoctorNotificationsCount();
    }
    notifyListeners();
  }

  Future<void> _updatePatientNotificationsCount() async {
    _dataPatientNotifications = await _apiNotifications.getForPatient();
    _notificationsCount =
        _dataPatientNotifications?.where((n) => !(n.isRead ?? false)).length ?? 0;
  }

  Future<void> _updateDoctorNotificationsCount() async {
    _dataDoctorNotifications = await _apiNotifications.getForDoctor();
    _notificationsCount =
        _dataDoctorNotifications?.where((n) => !(n.seen ?? false)).length ?? 0;
  }

  // Метод для вызова из диалогов после обновления данных
  Future<void> onNotificationsUpdated() async {
    await _updateNotificationsCount();
  }

  // Метод для очистки состояния при выходе из учетной записи
  void clear() {
    _timer?.cancel();
    _notificationsCount = 0;
    _dataPatientNotifications = [];
    _dataDoctorNotifications = [];
    _role = null;
    _isInitialized = false; // Разрешаем повторную инициализацию
    notifyListeners();
  }

  // Метод для повторной инициализации после входа нового пользователя
  Future<void> reinitialize() async {
    debugPrint('NotificationsProvider: Повторная инициализация...');
    clear(); // Сначала очищаем текущее состояние
    await _initialize(); // Затем инициализируем заново
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}