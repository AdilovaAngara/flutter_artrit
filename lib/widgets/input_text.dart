import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../theme.dart';

class InputText extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState> fieldKey;
  final dynamic value;
  final bool required;
  final TextInputType keyboardType;
  final bool readOnly;
  final String? hintText;
  final bool autofocus;
  final InputBorder border;
  final int? maxLength;
  final int min;
  final int max;
  final bool autofillHints;
  final ValueChanged<String>? onChanged;
  final int? role;
  final List<int>? listRoles;

  const InputText({
    super.key,
    required this.labelText,
    required this.fieldKey,
    required this.value,
    required this.required,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.hintText,
    this.autofocus = false,
    this.border = const UnderlineInputBorder(),
    this.maxLength,
    this.min = 0,
    this.max = 100000000,
    this.autofillHints = false,
    this.onChanged,
    this.role,
    required this.listRoles,
  });

  @override
  InputTextState createState() => InputTextState();
}

class InputTextState extends State<InputText> {
  TextEditingController controller = TextEditingController();
  double paddindDif = 0.0;

  @override
  void initState() {
    controller.text = widget.value?.toString() ?? '';
    paddindDif = widget.maxLength != null ? 10.0 : paddindDif;
    super.initState();
  }

  // Работает только для readOnly полей
  @override
  void didUpdateWidget(covariant InputText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Синхронизируем controller.text с новым значением widget.value
    if (widget.readOnly && widget.value?.toString() != controller.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.text = widget.value?.toString() ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: EdgeInsets.only(bottom: (10.0 - paddindDif)),
            child: (widget.listRoles == Roles.all ||
                widget.listRoles!.contains(widget.role)) &&
                !widget.readOnly
                ? TextFormField(
              key: widget.fieldKey,
              controller: controller,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              //autovalidateMode: AutovalidateMode.onUserInteraction, // Валидация при взаимодействии
              validator: (value) {
                // Проверка на обязательность заполнения
                if ((value == null || value.trim().isEmpty) &&
                    widget.required &&
                    !widget.readOnly) {
                  return 'Заполните поле';
                }

                // Проверка для e-mail
                if (widget.keyboardType == TextInputType.emailAddress &&
                    value != null &&
                    value.isNotEmpty) {
                  final emailPattern = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailPattern.hasMatch(value)) {
                    return 'Введите корректный e-mail';
                  }
                }

                // Проверка для номера телефона
                if (widget.keyboardType == TextInputType.phone &&
                    value != null &&
                    value.isNotEmpty) {
                  // Убираем все нечисловые символы для проверки длины
                  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                  if (digitsOnly.length != 11) {
                    return 'Введите полный номер телефона';
                  }
                }

                // Проверка числовых значений (int или double)
                if (widget.keyboardType == TextInputType.number &&
                    value != null &&
                    value.isNotEmpty) {
                  final numValue = num.tryParse(value);
                  if (numValue == null) {
                    return 'Введите корректное число';
                  }
                  if (numValue < widget.min || numValue > widget.max) {
                    return 'От ${widget.min} до ${widget.max}';
                  }
                }
                return null;
              },
              maxLength: widget.maxLength,
              maxLines: 30,
              minLines: 1,
              keyboardType: widget.keyboardType,
              //textCapitalization: (widget.keyboardType == TextInputType.name) ? TextCapitalization.words : TextCapitalization.none, // Делает первую букву каждого слова заглавной
              inputFormatters: [
                selectTextInputFormatter(widget.keyboardType),
              ],
              decoration: InputDecoration(
                labelText: (widget.required && !widget.readOnly)
                    ? '${widget.labelText}*'
                    : widget.labelText,
                labelStyle: inputLabelStyle,
                // label: Text((widget.required && !widget.readOnly)
                //     ? '${widget.labelText}*'
                //     : widget.labelText, maxLines: 3, softWrap: true, overflow: TextOverflow.visible, style: inputLabelStyle,),
                errorStyle: errorStyle,
                border: widget.border,
                floatingLabelBehavior: FloatingLabelBehavior
                    .always, // Всегда отображать label сверху
                hintText: widget.hintText,
                filled: widget.hintText != null ? true : false,
                fillColor: Colors.white,
              ),
              style: inputTextStyle,
              autofillHints: widget.autofillHints ? widget.keyboardType == TextInputType.emailAddress
                  ? [AutofillHints.email, AutofillHints.username]
                  : [AutofillHints.username] : null, // Добавляем auto заполнение
              onChanged: (value) {
                if (widget.onChanged != null) {
                  widget.onChanged!(value.trim()); // Вызов колбэк-функции
                }
                if (widget.fieldKey.currentState != null) {
                  widget.fieldKey.currentState!.validate();
                }
              },
          )
        : RichText(
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
                  text: widget.value?.toString() ?? '',
                  style: inputTextStyle,
                ),
              ],
            ),
            ),
    );
  }
}

TextInputFormatter selectTextInputFormatter(TextInputType keyboardType) {
  if (keyboardType == TextInputType.emailAddress) {
    return EmailInputFormatter(); // Форматтер для email
  } else if (keyboardType == TextInputType.phone) {
    return PhoneNumberFormatter(); // Форматтер для телефона
  } else if (keyboardType == TextInputType.number) {
    //return FilteringTextInputFormatter.digitsOnly; // Только цифры
    return NumberInputFormatter(); // Только цифры
  } else {
    return FilteringTextInputFormatter.allow(
        RegExp(r'.*')); // Разрешить любые символы
  }
}

class EmailInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Разрешённые символы для e-mail на основе регулярного выражения
    final allowedCharacters = RegExp(r'[a-zA-Z0-9._%+-@]');
    final filteredText = newValue.text.split('').where((char) {
      return allowedCharacters.hasMatch(char);
    }).join();

    // Если текст не изменился (например, введён недопустимый символ), возвращаем старое значение
    if (filteredText == oldValue.text) {
      return oldValue;
    }

    return TextEditingValue(
      text: filteredText,
      selection: newValue.selection,
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly =
        newValue.text.replaceAll(RegExp(r'\D'), ''); // Убираем все, кроме цифр
    String formatted = '';
    if (digitsOnly.isNotEmpty) {
      formatted += '+7 ';
    }
    if (digitsOnly.isNotEmpty) {
      formatted += '(${digitsOnly.substring(1, digitsOnly.length.clamp(1, 4))}';
    }
    if (digitsOnly.length > 4) {
      formatted +=
          ') ${digitsOnly.substring(4, digitsOnly.length.clamp(4, 7))}';
    }
    if (digitsOnly.length > 7) {
      formatted += '-${digitsOnly.substring(7, digitsOnly.length.clamp(7, 9))}';
    }
    if (digitsOnly.length > 9) {
      formatted +=
          '-${digitsOnly.substring(9, digitsOnly.length.clamp(9, 11))}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
