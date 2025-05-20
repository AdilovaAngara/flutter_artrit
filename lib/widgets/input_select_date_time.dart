import 'package:artrit/my_functions.dart';
import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';

class InputSelectDateTime extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState> fieldKey;
  final dynamic value;
  final bool required;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final int? role;
  final List<int>? listRoles;

  const InputSelectDateTime({
    super.key,
    required this.labelText,
    required this.fieldKey,
    required this.value,
    required this.required,
    this.readOnly = false,
    this.onChanged,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.role,
    required this.listRoles,
  });

  @override
  InputSelectDateTimeState createState() => InputSelectDateTimeState();
}

class InputSelectDateTimeState extends State<InputSelectDateTime> {
  TextEditingController controller = TextEditingController();
  String? errorText;
  DateTime now = getMoscowDateTime();

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime firstDate = _getFirstDate();
    DateTime lastDate = _getLastDate();

    // Корректируем lastDate, если он раньше firstDate
    if (lastDate.isBefore(firstDate)) {
      lastDate = firstDate; // Устанавливаем lastDate равным firstDate
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: _getInitialDate(firstDate, lastDate), // Передаём скорректированные границы
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ru', 'RU'), // Русская локализация
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.input,
        initialTime: TimeOfDay.fromDateTime(now), // Используем локальное время
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), // Используем 24 часовое время
            child: child!,
          );
        },
      );

      if (selectedTime != null) {

        DateTime finalDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        setState(() {
          String? dateTimeStr = dateTimeFormat(finalDateTime); // форматируем дату и время
          controller.text = dateTimeStr ?? '';
          widget.onChanged?.call(dateTimeStr ?? ''); // Вызов колбэк-функции
          widget.fieldKey.currentState?.validate();
        });
      }
    }
  }

  @override
  void initState() {
    controller.text = widget.value?.toString() ?? '';
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  DateTime _getInitialDate(DateTime firstDate, DateTime lastDate) {
    DateTime candidateDate;

    if (widget.initialDate != null) {
      candidateDate = widget.initialDate!;
    } else if (widget.value != null && converStrToDateTime(widget.value) != null) {
      candidateDate = converStrToDateTime(widget.value)!;
    } else {
      candidateDate = now;
    }

    // Корректируем initialDate, чтобы она была в пределах firstDate и lastDate
    if (candidateDate.isBefore(firstDate)) {
      return firstDate;
    } else if (candidateDate.isAfter(lastDate)) {
      return lastDate;
    }
    return candidateDate;
  }

  DateTime _getLastDate() {
    return widget.lastDate ?? now; // По умолчанию текущая дата
  }

  DateTime _getFirstDate() {
    return widget.firstDate ?? DateTime(2005); // По умолчанию 2005 год
  }





  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: (widget.listRoles == Roles.all ||
          widget.listRoles!.contains(widget.role)) && !widget.readOnly
          ? TextFormField(
        key: widget.fieldKey,
        controller: controller,
        readOnly: true, // тут всегда будет true. так как ввод через календарь
        validator: (value) {
          if ((value == null || value.isEmpty) && widget.required) {
            return 'Заполните поле';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: widget.required ? '${widget.labelText}*' : widget.labelText,
          errorText: errorText,
          labelStyle: inputLabelStyle,
          errorStyle: errorStyle,
          suffixIcon: !widget.readOnly ? Icon(Icons.calendar_today) : null,
          floatingLabelBehavior: FloatingLabelBehavior.always, // Всегда отображать label сверху
        ),
        style: inputTextStyle,
        onTap: () => !widget.readOnly ? _selectDateTime(context) : null,
    ) : RichText(
      maxLines: 2,
      softWrap: true,
      strutStyle: const StrutStyle(
        height: 0.1, // Увеличивает высоту строки (1.0 — стандартное значение)
        leading: 1.5, // Добавляет дополнительное пространство перед строкой
      ),
      text: TextSpan(
        children: [
          TextSpan(text: '${widget.labelText}:  ', style: labelStyle),
          TextSpan(
            text: widget.value?.toString() ?? '',
            style: inputTextStyle,
          ),
        ],
      ),
    ),
    );
  }
}
