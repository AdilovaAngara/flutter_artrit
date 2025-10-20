import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../theme.dart';

class InputSelectDate extends StatefulWidget {
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

  const InputSelectDate({
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
  InputSelectDateState createState() => InputSelectDateState();
}

class InputSelectDateState extends State<InputSelectDate> {
  TextEditingController controller = TextEditingController();
  String? errorText;
  DateTime now = getMoscowDateTime();

  Future<void> _selectDate(BuildContext context) async {
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
      setState(() {
        String? date = dateFormat(selectedDate);
        controller.text = date ?? ''; // Обновляем текст контроллера
        if (widget.onChanged != null) {
          widget.onChanged!(date ?? ''); // Вызываем колбэк с выбранной датой
        }
        if (widget.fieldKey.currentState != null) {
          widget.fieldKey.currentState!.validate();
        }
      });
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
    } else if (widget.value != null && convertStrToDate(widget.value) != null) {
      candidateDate = convertStrToDate(widget.value)!;
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
          child: (widget.listRoles == Roles.all || widget.listRoles!.contains(widget.role)) && !widget.readOnly
              ? TextFormField(
                key: widget.fieldKey,
                controller: controller,
                readOnly: true, // Ввод только через календарь
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
                onTap: () => !widget.readOnly ? _selectDate(context) : null,
              )

        : RichText(
      maxLines: 2,
      softWrap: true,
      strutStyle: const StrutStyle(
        height: 0.1, // Увеличивает высоту строки
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