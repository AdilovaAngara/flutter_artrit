import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';

class CheckboxGroupWidget extends StatefulWidget {
  final String? labelText;
  final List<String> listAnswers;
  final List<bool> selectedIndexes;
  final bool required;
  final bool showDivider;
  final ValueChanged<List<bool>>? onChanged;
  final GlobalKey<FormFieldState<List<bool>>>? fieldKey;
  final int? role;
  final List<int>? listRoles;

  const CheckboxGroupWidget({
    super.key,
    this.labelText,
    required this.listAnswers,
    required this.selectedIndexes,
    required this.required,
    this.showDivider = true,
    this.onChanged,
    this.fieldKey,
    this.role,
    required this.listRoles,
  });

  @override
  CheckboxGroupFormState createState() => CheckboxGroupFormState();
}

class CheckboxGroupFormState extends State<CheckboxGroupWidget> {
  late List<bool> _selectedIndexes;

  @override
  void initState() {
    super.initState();
    _selectedIndexes = List.from(widget.selectedIndexes); // Инициализация значений
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: FormField<List<bool>>(
        key: widget.fieldKey,
        initialValue: _selectedIndexes,
        validator: (value) {
          if (widget.required && (value == null || !value.contains(true))) {
            return 'Выберите хотя бы один вариант'; // Сообщение об ошибке
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction, // Валидация при взаимодействии
        builder: (FormFieldState<List<bool>> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.labelText != null && widget.labelText!.isNotEmpty)
                Text('${widget.labelText!}:',
                    style: labelStyle),
              ...widget.listAnswers.asMap().entries.expand((entry) {
                int index = entry.key;
                String option = entry.value;
                return [
                  CheckboxListTile(
                    title: Text(
                      option,
                      style: listLabelStyle.copyWith(
                        // Красный цвет текста при ошибке
                        color: state.hasError ? Colors.red : null,
                      ),
                    ),
                    value: _selectedIndexes[index],
                    onChanged: widget.listRoles == Roles.all ||
                        widget.listRoles!.contains(widget.role)
                        ? (value) {
                      setState(() {
                        _selectedIndexes[index] = value!;
                      });
                      state.didChange(_selectedIndexes);
                      widget.onChanged?.call(_selectedIndexes);
                    }
                        : null,
                    contentPadding: const EdgeInsets.only(top: 8),
                    visualDensity: VisualDensity.compact,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading, // Чекбокс слева
                    // Подсвечиваем чекбокс красным при ошибке
                    activeColor: state.hasError ? Colors.red : null,
                    checkColor: Colors.white,
                    side: state.hasError
                        ? const BorderSide(color: Colors.red, width: 2)
                        : null,
                  ),
                  // Добавляем Divider, если это не последний элемент
                  if (index < widget.listAnswers.length - 1 && widget.showDivider)
                    const Divider(
                      height: 20, // Высота с учётом отступов
                      thickness: 0.5, // Толщина линии
                      color: Colors.black12, // Цвет линии
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