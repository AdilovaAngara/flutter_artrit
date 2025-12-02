import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../theme.dart';

class WidgetInputSelectDateTime extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState>? fieldKey;
  final String? value;
  final bool showDate;
  final bool showTime;
  final bool required;
  final bool readOnly;
  final ValueChanged<String?>? onChanged;
  final DateTime? initialDate;
  final DateTime? firstDateTime;
  final DateTime? lastDateTime;
  final bool isFirstDateTimeNow;
  final bool isLastDateTimeNow;
  final int? roleId;
  final List<int>? listRoles;

  const WidgetInputSelectDateTime({
    super.key,
    required this.labelText,
    required this.fieldKey,
    required this.value,
    this.showDate = true,
    this.showTime = false,
    required this.required,
    this.readOnly = false,
    this.onChanged,
    this.initialDate,
    this.firstDateTime,
    this.lastDateTime,
    this.isFirstDateTimeNow = false,
    this.isLastDateTimeNow = false,
    this.roleId,
    required this.listRoles,
  });

  @override
  WidgetInputSelectDateTimeState createState() =>
      WidgetInputSelectDateTimeState();
}

class WidgetInputSelectDateTimeState extends State<WidgetInputSelectDateTime> {
  TextEditingController controller = TextEditingController();
  String? errorText;
  DateTime now = getMoscowDateTime();

  @override
  void initState() {
    super.initState();
    controller.text = _formatValue(widget.value);
    //errorText = _validate(controller.text);
  }

  @override
  void didUpdateWidget(covariant WidgetInputSelectDateTime oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.text = _formatValue(widget.value);
        }
      });
    }

    // Если изменились min или max, вызываем валидацию
    if (oldWidget.firstDateTime != widget.firstDateTime ||
        oldWidget.lastDateTime != widget.lastDateTime ||
        oldWidget.value != widget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          errorText = _validate(controller.text, true);
        }
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  bool _isChangeAvailable() {
    return (widget.listRoles == Roles.all ||
        widget.listRoles!.contains(widget.roleId)) && !widget.readOnly;
  }


  // Метод валидации
  String? _validate(String? value, bool isDidUpdateWidget) {
    if (!isDidUpdateWidget && widget.required && (value == null || value.isEmpty)) {
      return 'Заполните поле';
    }

    if (value != null && value.isNotEmpty) {
      if (!widget.showDate && widget.showTime) {
        // Валидация времени
        final time = _parseTime(value);
        if (time == null) {
          return 'Некорректный формат времени';
        }
        return _isValidTime(time);
      } else if (widget.showDate && !widget.showTime) {
        // Валидация даты
        final date = convertStrToDate(value);
        if (date == null) {
          return 'Некорректный формат даты';
        }
        return _isValidDate(date);
      } else if (widget.showDate && widget.showTime) {
        // Валидация даты и времени
        final dateTime = convertStrToDateTime(value);
        if (dateTime == null) {
          return 'Некорректный формат даты и времени';
        }
        return _isValidDateTime(dateTime);
      }
    }
    return null;
  }

  // Парсинг строки времени в TimeOfDay
  TimeOfDay? _parseTime(String value) {
    try {
      final parts = value.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1].split(':')[0]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!widget.showDate) {
      /// Если только время
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.input,
        initialTime: _getInitialTime(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (selectedTime != null && mounted) {
        setState(() {
          final timeStr =
              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
          controller.text = timeStr;
          controller.selection = TextSelection.collapsed(
            offset: timeStr.length,
          );
          errorText = _validate(timeStr, false);
          widget.onChanged?.call(timeStr);
          widget.fieldKey?.currentState?.didChange(timeStr);
          widget.fieldKey?.currentState?.validate();
        });
      }
    } else {
      DateTime firstDate = _getFirstDate();
      DateTime lastDate = _getLastDate();

      if (lastDate.isBefore(firstDate)) {
        lastDate = firstDate;
      }

      /// Выбираем дату
      DateTime? selectedDate = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDate: _getInitialDate(firstDate, lastDate),
        firstDate: firstDate,
        lastDate: lastDate,
        locale: const Locale('ru', 'RU'),
      );

      /// Если дата выбрана, то выбираем еще и время, если showTime = true
      if (selectedDate != null) {
        if (widget.showTime) {
          TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialEntryMode: TimePickerEntryMode.input,
            initialTime: _getInitialTime(),
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            },
          );

          if (selectedTime != null && mounted) {
            DateTime finalDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            setState(() {
              final dateTimeStr =
                  dateTimeFormat(finalDateTime) ?? _formatValue(finalDateTime);
              controller.text = dateTimeStr;
              controller.selection = TextSelection.collapsed(
                offset: dateTimeStr.length,
              );
              errorText = _validate(dateTimeStr, false);
              widget.onChanged?.call(dateTimeStr);
              widget.fieldKey?.currentState?.didChange(dateTimeStr);
              widget.fieldKey?.currentState?.validate();
            });
          }
        } else if (mounted) {
          /// Если время showTime = false, значит оставляем только дату
          final finalDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          );
          setState(() {
            final dateStr =
                dateFormat(finalDateTime) ?? _formatValue(finalDateTime);
            controller.text = dateStr;
            controller.selection = TextSelection.collapsed(
              offset: dateStr.length,
            );
            errorText = _validate(dateStr, false);
            widget.onChanged?.call(dateStr);
            widget.fieldKey?.currentState?.didChange(dateStr);
            widget.fieldKey?.currentState?.validate();
          });
        }
      }
    }
  }

  String? _isValidTime(TimeOfDay time) {
    int selectedMinutes = time.hour * 60 + time.minute;
    final firstMinutes =
    widget.firstDateTime != null
        ? widget.firstDateTime!.hour * 60 + widget.firstDateTime!.minute
        : null;
    final lastMinutes =
    widget.lastDateTime != null
        ? widget.lastDateTime!.hour * 60 + widget.lastDateTime!.minute
        : null;

    if (!widget.showDate && (firstMinutes != null || lastMinutes != null)) {
      final startTime = _formatTime(widget.firstDateTime);
      final endTime = _formatTime(widget.lastDateTime);

      if (firstMinutes != null && lastMinutes != null) {
        if (selectedMinutes < firstMinutes || selectedMinutes > lastMinutes) {
          return 'Допустимо от $startTime до $endTime';
        }
      } else if (firstMinutes != null && selectedMinutes < firstMinutes) {
        return 'Допустимо от $startTime';
      } else if (lastMinutes != null && selectedMinutes > lastMinutes) {
        return 'Допустимо до $endTime';
      }
    }
    return null;
  }

  // Функция для форматирования времени
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String? _isValidDateTime(DateTime dateTime) {
    DateTime? first = widget.firstDateTime;
    DateTime? last = widget.lastDateTime;

    if (first != null && last != null) {
      if (!(dateTime.isAfter(first) && dateTime.isBefore(last) ||
          dateTime.isAtSameMomentAs(first) ||
          dateTime.isAtSameMomentAs(last))) {
        return 'Допустимо от ${dateTimeFormat(widget.firstDateTime) ?? _formatDateTime(widget.firstDateTime!)} '
            'до ${dateTimeFormat(widget.lastDateTime) ?? _formatDateTime(widget.lastDateTime!)}';
      }
    } else if (first != null) {
      if (!(dateTime.isAfter(first) || dateTime.isAtSameMomentAs(first))) {
        return 'Допустимо от ${dateTimeFormat(widget.firstDateTime) ?? _formatDateTime(widget.firstDateTime!)}';
      }
    } else if (last != null) {
      if (!(dateTime.isBefore(last) || dateTime.isAtSameMomentAs(last))) {
        return 'Допустимо до ${dateTimeFormat(widget.lastDateTime) ?? _formatDateTime(widget.lastDateTime!)}';
      }
    }
    return null;
  }

  String? _isValidDate(DateTime dateTime) {
    DateTime? first = widget.firstDateTime;
    DateTime? last = widget.lastDateTime;

    if (first != null && last != null) {
      if (!(dateTime.isAfter(first) && dateTime.isBefore(last) ||
          dateTime.isAtSameMomentAs(first) ||
          dateTime.isAtSameMomentAs(last))) {
        return 'Допустимо от ${dateFormat(widget.firstDateTime) ?? _formatDate(widget.firstDateTime!)} '
            'до ${dateFormat(widget.lastDateTime) ?? _formatDate(widget.lastDateTime!)}';
      }
    } else if (first != null) {
      if (!(dateTime.isAfter(first) || dateTime.isAtSameMomentAs(first))) {
        return 'Допустимо от ${dateFormat(widget.firstDateTime) ?? _formatDate(widget.firstDateTime!)}';
      }
    } else if (last != null) {
      if (!(dateTime.isBefore(last) || dateTime.isAtSameMomentAs(last))) {
        return 'Допустимо до ${dateFormat(widget.lastDateTime) ?? _formatDate(widget.lastDateTime!)}';
      }
    }
    return null;
  }

  TimeOfDay _getInitialTime() {
    if (widget.value != null && widget.value.toString().isNotEmpty) {
      try {
        final parts = widget.value.toString().split(':');
        if (parts.length >= 2) {
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1].split(':')[0]); // Игнорируем секунды
          return TimeOfDay(hour: hour, minute: minute);
        }
      } catch (_) {}
    }
    return TimeOfDay.fromDateTime(widget.initialDate ?? now);
  }

  DateTime _getInitialDate(DateTime first, DateTime last) {
    DateTime candidate =
        widget.initialDate ??
            (widget.value != null ? convertStrToDate(widget.value)! : now);

    if (candidate.isBefore(first)) return first;
    if (candidate.isAfter(last)) return last;
    return candidate;
  }

  DateTime _getLastDate() {
    return widget.lastDateTime != null
        ? DateTime(
      widget.lastDateTime!.year,
      widget.lastDateTime!.month,
      widget.lastDateTime!.day,
    )
        : widget.isLastDateTimeNow
        ? now
        : now.add(Duration(days: 365 * 100));
  }

  DateTime _getFirstDate() {
    return widget.firstDateTime != null
        ? DateTime(
      widget.firstDateTime!.year,
      widget.firstDateTime!.month,
      widget.firstDateTime!.day,
    )
        : widget.isFirstDateTimeNow
        ? now
        : DateTime(1900);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatValue(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      if (widget.showDate && widget.showTime) return _formatDateTime(value);
      if (widget.showDate) return _formatDate(value);
      if (widget.showTime) {
        return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
      }
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: _isChangeAvailable()
          ? TextFormField(
        key: widget.fieldKey,
        controller: controller,
        readOnly: true,
        validator: (_) => _validate(controller.text, false),
        decoration: InputDecoration(
          labelText:
          widget.required && widget.labelText.isNotEmpty
              ? '${widget.labelText}*'
              : widget.labelText,
          errorText: errorText,
          labelStyle: inputLabelStyle,
          errorStyle: errorStyle,
          border: const UnderlineInputBorder(),
          suffixIcon:
          !widget.readOnly
              ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.value != null && widget.value!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) {
                        if (mounted) {
                          controller.clear();
                          widget.onChanged?.call(null);
                          widget.fieldKey?.currentState
                              ?.didChange(null);
                          setState(() {});
                        }
                      });
                    },
                  ),
                Icon(
                  widget.showDate
                      ? Icons.calendar_today
                      : Icons.access_time,
                ),
              ],
            ),
          )
              : null,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        style: inputTextStyle,
        onTap: () => !widget.readOnly ? _selectDateTime(context) : null,
      )
          : RichText(
        maxLines: 2,
        softWrap: true,
        strutStyle: const StrutStyle(height: 0.1, leading: 1.5),
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
