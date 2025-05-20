import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';

class InputCheckbox extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState> fieldKey;
  final bool value;
  final bool readOnly;
  final ValueChanged<bool>? onChanged;
  final TextStyle textStyle;
  final bool requiredTrue;
  final double padding;
  final int? role;
  final List<int>? listRoles;


  const InputCheckbox({
    super.key,
    required this.labelText,
    required this.fieldKey,
    required this.value,
    this.readOnly = false,
    this.onChanged,
    this.textStyle = inputTextStyle,
    this.requiredTrue = false,
    this.padding = 10.0,
    this.role,
    required this.listRoles,
  });

  @override
  CheckboxInputState createState() => CheckboxInputState();
}

class CheckboxInputState extends State<InputCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.padding),
      child: FormField<bool>(
        key: widget.fieldKey,
        initialValue: widget.value,
        validator: (value) {
          if (widget.requiredTrue && (value == null || !value)) {
            return ''; // Пустая строка вместо текста ошибки
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        builder: (FormFieldState<bool> state) {
          return InkWell(
            onTap: ((widget.listRoles == Roles.all || widget.listRoles!.contains(widget.role))
                && !widget.readOnly) ? () {
              bool newValue = !widget.value;
              state.didChange(newValue);
              widget.onChanged?.call(newValue);
            } : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: widget.value,
                  checkColor: Colors.white,
                  activeColor: Colors.deepPurple,
                  onChanged: ((widget.listRoles == Roles.all || widget.listRoles!.contains(widget.role))
                      && !widget.readOnly) ? (value) {
                    state.didChange(value);
                    widget.onChanged?.call(value ?? false);
                  } : null,
                  side: state.hasError
                      ? const BorderSide(color: Colors.red, width: 2)
                      : null,
                  //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Убираем лишний отступ
                  visualDensity: VisualDensity.compact, // Минимизируем отступы
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.labelText,
                    style: widget.textStyle.copyWith(
                      color: state.hasError ? Colors.red : null,
                    ),
                    maxLines: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}