import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';

class InputSwitch extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState> fieldKey;
  final bool? value;
  final bool readOnly;
  final ValueChanged<bool>? onChanged;
  final int? role;
  final List<int>? listRoles;

  const InputSwitch({
    super.key,
    required this.labelText,
    required this.fieldKey,
    required this.value,
    this.readOnly = false,
    this.onChanged,
    this.role,
    required this.listRoles,
  });

  @override
  InputSwitchState createState() => InputSwitchState();
}

class InputSwitchState extends State<InputSwitch> {
  late bool _value; // Переменная для хранения текущего значения переключателя

  @override
  void initState() {
    super.initState();
    _value = widget.value ?? false; // Инициализация текущего значения
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: (widget.listRoles == Roles.all ||
                  widget.listRoles!.contains(widget.role)) &&
              !widget.readOnly
          ? FormField<bool>(
              key: widget.fieldKey,
              initialValue: _value,
              builder: (FormFieldState<bool> state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Switch(
                      value: _value,
                      onChanged: (value) {
                        setState(() {
                          _value = value; // Обновляем значение
                        });
                        state.didChange(value); // Обновляем состояние FormField
                        widget.onChanged?.call(value); // Вызываем колбэк
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      _value
                          ? '${widget.labelText}: Да'
                          : '${widget.labelText}: Нет',
                      style: labelStyle,
                    ),
                  ],
                );
              },
            )
          : RichText(
              maxLines: 10,
              softWrap: true,
              strutStyle: const StrutStyle(
                height:
                    0.1, // Увеличивает высоту строки (1.0 — стандартное значение)
                leading:
                    1.5, // Добавляет дополнительное пространство перед строкой
              ),
              text: TextSpan(
                children: [
                  TextSpan(text: '${widget.labelText}:  ', style: labelStyle),
                  TextSpan(
                    text: (widget.value == null)
                        ? 'Нет'
                        : widget.value!
                            ? 'Да'
                            : 'Нет',
                    style: inputTextStyle,
                  ),
                ],
              ),
            ),
    );
  }
}
