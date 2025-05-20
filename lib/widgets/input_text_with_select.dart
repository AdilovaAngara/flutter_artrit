import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../my_functions.dart';
import '../theme.dart'; // Предполагается, что стили определены в theme.dart


class ItemsCallBack {
  double? value;
  String? unit;

  ItemsCallBack({
    required this.value,
    required this.unit,
  });
}

class InputTextWithSelect extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState> fieldKey;
  final dynamic initialValue; // Начальное значение текста
  final String? initialUnit; // Начальная единица измерения
  final bool required;
  final bool readOnly;
  final bool autofocus;
  final InputBorder border;
  final int? maxLength;
  final double? min;
  final double? max;
  final ValueChanged<ItemsCallBack>? onChanged; // Колбэк возвращает текст и единицу
  final List<String>? unitOptions; // Список единиц измерения
  final String errorText;

  const InputTextWithSelect({
    super.key,
    required this.labelText,
    required this.fieldKey,
    this.initialValue,
    this.initialUnit,
    required this.required,
    this.readOnly = false,
    this.autofocus = false,
    this.border = const UnderlineInputBorder(),
    this.maxLength,
    this.min = 0.0,
    this.max = 100000000.0,
    this.onChanged,
    required this.unitOptions,
    this.errorText = 'Заполните хотя бы одно поле',
  });

  @override
  InputTextWithSelectState createState() => InputTextWithSelectState();
}

class InputTextWithSelectState extends State<InputTextWithSelect> {
  late TextEditingController _controller;
  String? _selectedUnit;
  late List<String> _unitOptions;


  @override
  void initState() {
    _unitOptions = widget.unitOptions ?? ['Нет данных'];
    _controller = TextEditingController(
      text: widget.initialValue != null ? widget.initialValue.toString() : '',
    );
    _selectedUnit = widget.initialUnit ??
        (_unitOptions.isNotEmpty ? _unitOptions[0] : null);
    super.initState();
  }


  @override
  void didUpdateWidget(InputTextWithSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unitOptions != widget.unitOptions) {
      setState(() {
        _unitOptions = widget.unitOptions ?? ['Нет данных'];
        if (_selectedUnit != null && !_unitOptions.contains(_selectedUnit)) {
          _selectedUnit = _unitOptions.isNotEmpty ? _unitOptions[0] : null;
          _updateValue();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void _updateValue() {
    if (widget.onChanged != null) {
      widget.onChanged!(
          ItemsCallBack(
              value: _controller.text.trim().isNotEmpty ? double.parse(_controller.text.trim()) : null,
              unit: (_controller.text.trim().isNotEmpty) ? _selectedUnit : null)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        key: widget.fieldKey,
        controller: _controller,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if ((value == null || value.toString().trim().isEmpty) &&
              widget.required &&
              !widget.readOnly) {
            return widget.errorText;
          } else if (widget.max != null && widget.min != null && value != null &&
              value.trim().isNotEmpty) {
            final doubleValue = double.tryParse(value.replaceAll(',', '.'));
            if (doubleValue == null || doubleValue < widget.min! || doubleValue > widget.max!) {
              return 'От ${widget.min} до ${widget.max}';
            }
          }
          if (_selectedUnit == null && widget.required && !widget.readOnly) {
            return 'Выберите единицу измерения';
          }
          return null;
        },
        maxLength: widget.maxLength,
        maxLines: 1,
        minLines: 1,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [NumberInputFormatter()],

        decoration: InputDecoration(
          labelText: widget.required && !widget.readOnly
              ? '${widget.labelText}*'
              : widget.labelText,
          labelStyle: inputLabelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.always, // Всегда отображать label сверху
          errorStyle: errorStyle,
          border: widget.border,
          suffixIcon: SizedBox(
            width: MediaQuery.of(context).size.width * 0.35, // 35% ширины поля
            child: DropdownButtonFormField<String>(
              value: _selectedUnit,
              style: inputTextStyle, decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 20), // Уменьшаем высоту
            ),
              dropdownColor: Colors.white,
              isDense: true, // Уменьшает высоту селекта
              isExpanded: true, // Растягиваем DropdownButtonFormField на всю доступную ширину
              items: _unitOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Text(
                      value,
                    ),
                  ),
                );
              }).toList(),
              onChanged: widget.readOnly
                  ? null
                  : (String? newValue) {
                setState(() {
                  _selectedUnit = newValue;
                  _updateValue(); // Обновляем значение при выборе единицы
                  widget.fieldKey.currentState?.validate(); // Валидация после выбора
                });
              },
            ),
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: 0,
            minHeight: 0,
            maxWidth:
            MediaQuery.of(context).size.width * 0.35, // Ограничение ширины
          ),
        ),
        style: inputTextStyle,
        onChanged: (value) {
          _updateValue();
          widget.fieldKey.currentState?.validate();
        },
      ),
    );
  }
}


