import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';

class RadioGroupWidget extends StatefulWidget {
  final List<String> listAnswers;
  final int? selectedIndex;
  final ValueChanged<int?>? onChanged;
  final int? role;
  final List<int>? listRoles;

  const RadioGroupWidget({
    super.key,
    required this.listAnswers,
    required this.selectedIndex,
    this.onChanged,
    this.role,
    required this.listRoles,
  });

  @override
  RadioGroupFormState createState() => RadioGroupFormState();
}

class RadioGroupFormState extends State<RadioGroupWidget> {
  int? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedIndex; // Инициализация значения
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: FormField<int>(
        initialValue: _selectedValue,
        validator: (value) {
          if (value == null) {
            return 'Выберите один из вариантов';
          }
          return null;
        },
        builder: (FormFieldState<int> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Генерируем список с Divider
              ...widget.listAnswers.asMap().entries.expand((entry) {
                int index = entry.key;
                String option = entry.value;
                return [
                  RadioListTile<int>(
                    title: Text(option, style: listLabelStyle),
                    value: index,
                    groupValue: widget.selectedIndex,
                    onChanged: widget.listRoles == Roles.all ||
                        widget.listRoles!.contains(widget.role)
                        ? (value) {
                      setState(() {
                        _selectedValue = value;
                      });
                      state.didChange(value);
                      widget.onChanged?.call(value);
                    }
                        : null,
                    contentPadding: const EdgeInsets.only(top: 8),
                    visualDensity: VisualDensity.compact,
                    dense: true,
                  ),
                  // Добавляем Divider, если это не последний элемент
                  if (index < widget.listAnswers.length - 1)
                    const Divider(
                      height: 20, // Высота с учётом отступов
                      thickness: 0.5, // Толщина линии
                      color: Colors.black12 , // Цвет линии
                    ),
                ];
              }),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}