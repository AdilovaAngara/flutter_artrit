import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';

class SwitchWidget extends StatefulWidget {
  final String labelTextFirst;
  final String labelTextLast;
  final bool value;
  final bool readOnly;
  final ValueChanged<bool> onChanged;
  final TextStyle style;
  final int? role;
  final List<int>? listRoles;

  const SwitchWidget({super.key,
    required this.labelTextFirst,
    required this.labelTextLast,
    required this.value,
    this.readOnly = false,
    required this.onChanged,
    this.style = inputTextStyle,
    this.role,
    required this.listRoles,
  });

  @override
  SwitchWidgetState createState() => SwitchWidgetState();
}

class SwitchWidgetState extends State<SwitchWidget> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return (widget.listRoles == Roles.all ||
        widget.listRoles!.contains(widget.role)) && !widget.readOnly ? FormField<bool>(
      initialValue: _value,
      builder: (FormFieldState<bool> state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.labelTextFirst,
              style: widget.style,
            ),
            SizedBox(width: 10),
            Switch(
              value: _value,
              onChanged: (newValue) {
                setState(() {
                  _value = newValue;
                });
                widget.onChanged(newValue);
                state.didChange(newValue);
              },
              activeColor: Colors.deepPurple.shade300, // Цвет активного состояния
              inactiveThumbColor: Colors.deepPurple.shade300, // Цвет неактивного состояния
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white, // Цвет трека в неактивном состоянии
            ),
            SizedBox(width: 10),
            Text(
              widget.labelTextLast,
              style: inputTextStyle,
            ),
          ],
        );
      },
    ) : Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: RichText(
        maxLines: 10,
        softWrap: true,
        strutStyle: const StrutStyle(
          height: 0.1, // Увеличивает высоту строки
          leading: 1.5, // Добавляет дополнительное пространство перед строкой
        ),
        text: TextSpan(
          children: [
            TextSpan(
              text: !widget.value ? widget.labelTextFirst : widget.labelTextLast,
              style: inputTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}