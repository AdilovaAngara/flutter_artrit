import 'dart:io';
import 'package:artrit/data/data_anamnesis_concomitants.dart';
import 'package:artrit/data/data_anamnesis_family_history.dart';
import 'package:artrit/data/data_treatment_rehabilitations.dart';
import 'package:artrit/data/data_treatment_side_effects.dart';
import 'package:artrit/pages/menu.dart';
import 'package:artrit/pages/page_dynamic.dart';
import 'package:artrit/routes.dart';
import 'package:artrit/secure_storage.dart';
import 'package:artrit/theme.dart';
import 'package:artrit/widgets/show_dialog_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data/data_anamnesis_disease_anamnesis.dart';
import 'data/data_dynamic.dart';
import 'data/data_inspections.dart';
import 'data/data_treatment_medicaments.dart';


Center notDataWidget = Center(
    child: Text(
  'Нет данных',
  style: subtitleTextStyle,
));

Padding errorDataWidget(dynamic errorText) {
  debugPrint('Ошибка: $errorText');
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Center(
        child: Text(
      'Похоже, что-то пошло не так... Проверьте соединение и повторите попытку',
      style: labelStyle,
      textAlign: TextAlign.center, // <- выравнивание по центру
    )),
  );
}

Future<int> getUserRole() async {
  String roleStr = await readSecureData(SecureKey.role);
  return (roleStr.isEmpty) ? -1 : int.parse(roleStr);
}


/// Настройки получения уведомлений
int getNotificationReceiveType({required bool agreeEmail, required bool agreeLk}) {
  int notificationReceiveType;
  if (agreeEmail && agreeLk) {
    notificationReceiveType = 0; // личный кабинет и e-mail
  } else if (!agreeEmail && agreeLk) {
    notificationReceiveType = 1; // личный кабинет
  } else if (agreeEmail && !agreeLk) {
    notificationReceiveType = 2; // e-mail
  } else {
    notificationReceiveType = -1;
  }
  return notificationReceiveType;
}


void onBack(context, bool areDifferent) {
  if (areDifferent) {
    ShowDialogBack.show(context: context);
  } else {
    Navigator.pop(context);
  }
}

String getFormTitle(bool? isEditForm) {
  return isEditForm == null ? 'Просмотр записи' : isEditForm ? 'Изменить запись' : 'Добавить запись';
}

// Извлечение номера из положения сустава. Используется в "Измерение углов"
String extractImageNumber(String path) {
  final RegExp regex = RegExp(r'img_(\d+)\.jpg');
  final RegExpMatch? match = regex.firstMatch(path);
  return match?.group(1) ?? '-1';
}

String getSubtitleTreatmentMedicaments(DataTreatmentMedicaments? thisData) {
  String subtitle = '';
  if (thisData == null) {
    return subtitle = 'Нет данных';
  } else {
    //subtitle += '${thisData.srd ?? ''} ${thisData.ei ?? ''} ${thisData.krat ?? ''}\n';
    if (thisData.dnp != null) {
      subtitle += 'с ${convertTimestampToDate(thisData.dnp!)}';
    } else {
      subtitle += 'с неизвестно';
    }
    if (thisData.dop != null) {
      if (thisData.dop!.date != null &&
          thisData.dop!.date.toString().isNotEmpty) {
        subtitle += ' по ${convertTimestampToDate(thisData.dop!.date!)}';
      } else if (thisData.dop!.checkbox != null && thisData.dop!.checkbox!) {
        subtitle += ' по настоящее время';
      }
    } else {
      subtitle += 'неизвестно';
    }
  }
  return subtitle;
}

String getSubtitleTreatmentSideEffects(DataTreatmentSideEffects? thisData) {
  String subtitle = '';
  if (thisData == null) {
    return subtitle = 'Нет данных';
  } else {
    if (thisData.date != null) {
      subtitle += 'с ${convertTimestampToDate(thisData.date!)}';
    } else {
      subtitle += 'с неизвестно';
    }
    if (thisData.dateEnd != null) {
      if (thisData.dateEnd!.date != null &&
          thisData.dateEnd!.date.toString().isNotEmpty) {
        subtitle += ' по ${convertTimestampToDate(thisData.dateEnd!.date!)}';
      } else if (thisData.dateEnd!.checkbox != null &&
          thisData.dateEnd!.checkbox!) {
        subtitle += ' по настоящее время';
      }
    } else {
      subtitle += 'неизвестно';
    }
  }
  return subtitle;
}

String getSubtitleTreatmentRehabilitations(
    DataTreatmentRehabilitations? thisData) {
  String subtitle = '';
  if (thisData == null) {
    return subtitle = 'Нет данных';
  } else {
    if (thisData.dateStart != null) {
      subtitle += 'с ${convertTimestampToDate(thisData.dateStart!)}';
    } else {
      subtitle += 'с неизвестно';
    }
    if (thisData.dateEnd != null) {
      if (thisData.dateEnd!.date != null &&
          thisData.dateEnd!.date.toString().isNotEmpty) {
        subtitle += ' по ${convertTimestampToDate(thisData.dateEnd!.date!)}';
      } else if (thisData.dateEnd!.checkbox != null &&
          thisData.dateEnd!.checkbox!) {
        subtitle += ' по настоящее время';
      }
    } else {
      subtitle += 'неизвестно';
    }
  }
  return subtitle;
}

String getSubtitleAnamnesisConcomitants(DataAnamnesisConcomitants? thisData) {
  String subtitle = '';
  if (thisData == null) {
    return subtitle = 'Нет данных';
  } else {
    if (thisData.dateStart != null) {
      subtitle += 'с ${convertTimestampToDate(thisData.dateStart!)}';
    } else {
      subtitle += 'с неизвестно';
    }
    if (thisData.endDate != null) {
      if (thisData.endDate!.date != null &&
          thisData.endDate!.date.toString().isNotEmpty) {
        subtitle += ' по ${convertTimestampToDate(thisData.endDate!.date!)}';
      } else if (thisData.endDate!.checkbox != null &&
          thisData.endDate!.checkbox!) {
        subtitle += ' по настоящее время';
      }
    } else {
      subtitle += 'неизвестно';
    }
  }
  return subtitle;
}

String getSubtitleFamilyHistory(DataAnamnesisFamilyHistory? thisData) {
  String subtitle = '';
  List<String> list = [];
  if (thisData == null) {
    return subtitle = 'Нет заболеваний';
  } else {
    if (getBoolValue(thisData.radioart)) list.add('Артрит');
    if (getBoolValue(thisData.radiopsor)) list.add('Псориаз');
    if (getBoolValue(thisData.radiokron)) list.add('Болезнь Крона');
    if (getBoolValue(thisData.radioyazkol)) list.add('Язвенный колит');
    if (getBoolValue(thisData.radiobolbeh)) list.add('Болезнь Бехтерева');
    if (getBoolValue(thisData.radiobouveit)) list.add('Увеит');
    if (getBoolValue(thisData.radiobobolrey)) list.add('Болезнь Рейтера');

    subtitle = list.join(', ');
  }
  return subtitle;
}

String getSubtitleDiseaseAnamnesis(DataAnamnesisDiseaseAnamnesis? thisData) {
  String subtitle = '';
  if (thisData == null ||
      (thisData.dateDisease == null && thisData.dateDiagnosis == null)) {
    return subtitle = 'Нет данных';
  } else {
    subtitle +=
        '${convertTimestampToDate(thisData.dateDisease) ?? ''} - дата появления первых симптомов, жалоб\n';
    subtitle +=
        '${convertTimestampToDate(thisData.dateDiagnosis) ?? ''} - дата постановки диагноза';
  }
  return subtitle;
}

String getRadioValue(bool? value) {
  return value != null && value ? '1' : '2';
}

bool getBoolValue(String? value) {
  return value != null && value == '1' ? true : false;
}

void navigateToPage(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}

void navigateToPageDynamic(BuildContext context,
    {required String title, required List<DataDynamic> thisData}) {
  navigateToPage(
    context,
    PageDynamic(title: title, thisData: thisData),
  );
}

void navigateToPageMenu(BuildContext context, EnumMenu menu) {
  final title = menu.displayName;
  Widget page = menu.pageBuilder(title);
  if (menu.displayName == EnumMenu.logOut.displayName) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (Route<dynamic> route) => false, // Удаляет все предыдущие маршруты
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}



// Функция для перехода по ссылке
Future<void> openUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    // Можно показать сообщение об ошибке, если ссылка не открывается
    debugPrint('Could not launch $url');
  }
}



Widget showProgressIndicator({double size = 20}) {
  return SizedBox(
    width: size,
    height: size,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: Colors.black,
    ),
  );
}

Future<File?> pickImage(ImageSource source) async {
  final pickedFile = await ImagePicker().pickImage(source: source);
  if (pickedFile == null) return null; // Если фото не выбрано, выходим
  return File(pickedFile.path);
}




// Обрезаем строку
String truncateString(String text, {int length = 10}) {
  return text.length > length ? '${text.substring(0, length)}...' : text;
}

// Вычисляет количество записей, имеющих isActive: true
int countActive(List<Syssind> list) {
  return list.where((item) => item.isActive).length;
}

// Метод для сравнения содержимого двух списков
bool areDifferent(oldList, newList) {
  if (oldList.length != newList.length) return true;
  for (int i = 0; i < oldList.length; i++) {
    if (oldList[i].name != newList[i].name ||
        oldList[i].isActive != newList[i].isActive) {
      return true;
    }
  }
  return false;
}

bool delBtnShowCalculate(String? date) {
  bool delBtnShow = false;
  if (date == null || date.isEmpty) return delBtnShow;
  DateTime dateTime1 = convertStrToDateTime(date)!;
  DateTime dateTime2 = getMoscowDateTime();
  // Вычисление разницы в часах
  Duration difference = dateTime2.difference(dateTime1);
  double hoursDifference = difference.inHours.toDouble();
  if (hoursDifference < 24) {
    delBtnShow = true;
  }
  return delBtnShow;
}

dynamic formatDouble(dynamic value, {int? fixedCount}) {
  if (value == null) return value;
  // Проверяем, является ли значение целым числом
  if (value == value.toInt().toDouble()) {
    return value.toInt().toString(); // Возвращаем значение как целое число
  } else {
    if (fixedCount != null) {
      value = double.parse(value.toStringAsFixed(fixedCount));
    }
    // Убираем нули в конце
    return value
        .toString()
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}


void scrollToContext(BuildContext context) {
  Scrollable.ensureVisible(
    context,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeOutExpo,
  );
}


TimeOfDay getMoscowTime() {
  DateTime now = DateTime.now().toUtc().add(Duration(hours: 3));
  return TimeOfDay(hour: now.hour, minute: now.minute);
}

DateTime getMoscowDateTime() {
  return DateTime.now().toUtc().add(Duration(hours: 3));
}

String? dateFormat(DateTime? date) {
  DateFormat dateFormat = DateFormat('dd.MM.yyyy');
  return date != null ? dateFormat.format(date) : null;
}

String? dateTimeFormat(DateTime? date) {
  DateFormat dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');
  return date != null ? dateTimeFormat.format(date) : null;
}

String? dateFullTimeFormat(DateTime? date) {
  DateFormat dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm:ss');
  return date != null ? dateTimeFormat.format(date) : null;
}

String? dateFullTimeFormatForFileName(DateTime? date) {
  DateFormat dateTimeFormat = DateFormat('dd.MM.yyyy HH.mm.ss');
  return date != null ? dateTimeFormat.format(date) : null;
}

// Форматирование времени в формат "HH:MM"
String timeFormat(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

DateTime? convertStrToDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  DateFormat dateFormat = DateFormat('dd.MM.yyyy');
  return dateFormat.parse(dateString);
}


DateTime? convertStrToDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm');
  return dateFormat.parse(dateString);
}

String? convertTimestampToDate(int? timestampDate) {
  // Преобразуем миллисекунды в объект DateTime
  DateTime? date = timestampDate != null
      ? DateTime.fromMillisecondsSinceEpoch(timestampDate, isUtc: true)
          .toLocal()
      : null;
  return dateFormat(date);
}

String? convertTimestampToDateTime(int? timestampDate) {
  // Преобразуем миллисекунды в объект DateTime
  DateTime? date = timestampDate != null
      ? DateTime.fromMillisecondsSinceEpoch(timestampDate, isUtc: true)
          .toLocal()
      : null;
  return dateTimeFormat(date);
}

// int? convertDateToTimestamp(String? dateString) {
//   if (dateString == null) return null;
//   // Преобразуем дату в миллисекунды с начала эпохи Unix
//   DateFormat dateFormat = DateFormat('dd.MM.yyyy');
//   DateTime date = dateFormat.parse(dateString);
//   return date.millisecondsSinceEpoch;
// }
//
// int? convertDateTimeToTimestamp(String? dateString) {
//   if (dateString == null) return null;
//   // Преобразуем дату в миллисекунды с начала эпохи Unix
//   DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm');
//   DateTime date = dateFormat.parse(dateString);
//   return date.millisecondsSinceEpoch;
// }

int? convertToTimestamp(String? dateString) {
  if (dateString == null) return null;

  try {
    // Определяем формат в зависимости от строки
    DateFormat dateFormat;
    if (dateString.contains(':')) {
      // Если есть двоеточие, предполагаем формат с временем
      try {
        dateFormat = DateFormat('dd.MM.yyyy HH:mm');
      } catch (e) {
        dateFormat = DateFormat('dd.MM.yyyy');
      }
    } else {
      dateFormat = DateFormat('dd.MM.yyyy');
    }

    DateTime date = dateFormat.parse(dateString);
    return date.millisecondsSinceEpoch;
  } catch (e) {
    debugPrint('Ошибка преобразования даты: $e');
    return null; // Возвращаем null в случае ошибки
  }
}

String calculateAge(String? birthDate,
    {required bool getFullAge, required bool getDoubleAge}) {
  if (birthDate == null) return '';

  // Преобразуем дату из строки
  DateFormat dateFormat = DateFormat('dd.MM.yyyy');
  DateTime birthDateTime = dateFormat.parse(birthDate);
  DateTime now = DateTime.now();

  // Вычисляем разницу в годах и месяцах
  int years = now.year - birthDateTime.year;
  int months = now.month - birthDateTime.month;

  if (months < 0) {
    years -= 1;
    months += 12;
  }

  if (getFullAge) return years.toString();
  if (getDoubleAge) return '$years.$months';

  // Если возраст меньше года
  if (years == 0) {
    return '$months ${_getMonthEnding(months)}';
  }

  // Если возраст больше года
  return '$years ${_getYearEnding(years)} $months ${_getMonthEnding(months)}';
}

String _getYearEnding(int years) {
  if (years % 10 == 1 && years % 100 != 11) {
    return 'год';
  } else if ([2, 3, 4].contains(years % 10) &&
      !(years % 100 >= 12 && years % 100 <= 14)) {
    return 'года';
  } else {
    return 'лет';
  }
}

String _getMonthEnding(int months) {
  if (months % 10 == 1 && months % 100 != 11) {
    return 'месяц';
  } else if ([2, 3, 4].contains(months % 10) &&
      !(months % 100 >= 12 && months % 100 <= 14)) {
    return 'месяца';
  } else {
    return 'месяцев';
  }
}

// Функция для выбора цвета в зависимости от значения
Color getColor(var value) {
  if (value < 30) return Colors.green;
  if (value < 70) return Colors.orange;
  return Colors.red;
}

IconData getIcon(int value) {
  if (value == 0) return FontAwesomeIcons.solidFaceSmileBeam;
  if (value < 30) return FontAwesomeIcons.solidFaceSmile;
  if (value < 70) return FontAwesomeIcons.solidFaceMeh;
  return FontAwesomeIcons.solidFaceFrownOpen;
}

// Кастомный форматтер для цифр и запятой
class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Разрешаем только цифры и одну запятую
    //final regExp = RegExp(r'^\d*\.?\d*$'); // Это без минуса
    final regExp = RegExp(r'^-?\d*\.?\d*$');
    String newText =
        newValue.text.replaceAll(',', '.'); // Заменяем точку на запятую

    if (regExp.hasMatch(newText)) {
      // Проверяем, что запятая встречается только один раз
      if (newText.split(',').length > 2) {
        return oldValue; // Если больше одной запятой, откатываемся
      }
      return TextEditingValue(
        text: newText,
        selection: newValue.selection,
      );
    }
    return oldValue; // Если ввод некорректен, возвращаем старое значение
  }
}
