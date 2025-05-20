import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class InputTextObscure extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState> fieldKey;
  final String value;
  final bool required;
  final bool readOnly;
  final bool autofocus;
  final InputBorder border;
  final ValueChanged<String>? onChanged;

  const InputTextObscure({
    super.key,
    required this.labelText,
    required this.fieldKey,
    required this.value,
    required this.required,
    this.readOnly = false,
    this.autofocus = false,
    this.border = const UnderlineInputBorder(),
    this.onChanged,
  });

  @override
  InputTextObscureState createState() => InputTextObscureState();
}

class InputTextObscureState extends State<InputTextObscure> {
  late final TextEditingController controller = TextEditingController();
  bool _isObscure = true; // Управляет состоянием видимости пароля

  @override
  void initState() {
    controller.text = widget.value;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        key: widget.fieldKey,
        controller: controller,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        obscureText: _isObscure, // Скрыть/показать пароль
        obscuringCharacter: '*', // Символ шифрования
        validator: (value) {
          if ((value == null || value.trim().isEmpty) && widget.required && !widget.readOnly) {
            return 'Заполните поле';
          }
          if (value != null && value.isNotEmpty) {
            // Проверка минимальной длины (опционально)
            if (value.length < 6) {
              return 'Пароль должен содержать минимум 6 символов';
            }
            // Проверка на наличие недопустимых символов
            final allowedPattern = RegExp(r'^[a-zA-Z0-9!@#$%^&*_-]+$');
            if (!allowedPattern.hasMatch(value)) {
              return 'Только английские буквы, цифры и символы !@#\$%^&*_-';
            }
          }
          return null;
        },
        // validator: (value) {
        //   if ((value == null || value.trim().isEmpty) && widget.required && !widget.readOnly) {
        //     return 'Заполните поле';
        //   }
        //   if (value != null && value.isNotEmpty) {
        //     if (value.length < 8) {
        //       return 'Пароль должен содержать минимум 8 символов';
        //     }
        //     final allowedPattern = RegExp(r'^[a-zA-Z0-9!@#$%^&*_-]+$');
        //     if (!allowedPattern.hasMatch(value)) {
        //       return 'Только английские буквы, цифры и символы !@#\$%^&*_-';
        //     }
        //     if (!RegExp(r'[A-Z]').hasMatch(value)) {
        //       return 'Добавьте хотя бы одну заглавную букву';
        //     }
        //     if (!RegExp(r'[0-9]').hasMatch(value)) {
        //       return 'Добавьте хотя бы одну цифру';
        //     }
        //     if (!RegExp(r'[!@#$%^&*_-]').hasMatch(value)) {
        //       return 'Добавьте хотя бы один символ (!@#\$%^&*_-';
        //     }
        //   }
        //   return null;
        // },


        inputFormatters: [
          // Фильтр для ввода только допустимых символов
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9!@#$%^&*_-]')),
        ],
        decoration: InputDecoration(
          labelText: widget.required ? '${widget.labelText}*' : widget.labelText,
          labelStyle: inputLabelStyle,
          errorStyle: errorStyle,
          border: widget.border,
          floatingLabelBehavior: FloatingLabelBehavior.always, // Всегда отображать label сверху
          suffixIcon: IconButton(
            icon: Icon(
              _isObscure ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure; // Переключение состояния
              });
            },
          ),
        ),
        style: inputTextStyle,
        autofillHints: [AutofillHints.password],
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value.trim()); // Вызов колбэк-функции
          }
          if (mounted && widget.fieldKey.currentState != null) {
            widget.fieldKey.currentState!.validate();
          }
        },
      ),
    );
  }
}