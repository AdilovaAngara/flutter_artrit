import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';

class InputMultiSelect extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState> fieldKey;
  final List<dynamic> listSelectValue; // Список начальных выбранных значений
  final bool required;
  final bool readOnly;
  final InputBorder border;
  final List<String>? listValues; // Полный список доступных значений
  final ValueChanged<List<String>>? onChanged;
  final int? role;
  final List<int>? listRoles;

  const InputMultiSelect({
    super.key,
    required this.labelText,
    required this.fieldKey,
    required this.listSelectValue,
    required this.required,
    this.readOnly = false,
    this.border = const UnderlineInputBorder(),
    required this.listValues,
    this.onChanged,
    this.role,
    required this.listRoles,
  });

  @override
  InputMultiSelectState createState() => InputMultiSelectState();
}

class InputMultiSelectState extends State<InputMultiSelect> {
  TextEditingController controller = TextEditingController();

  // Список выбранных значений
  List<String> selectedValues = [];

  Future<void> _showMultiSelectDialog(BuildContext context) async {
    // Локальное состояние для обновления внутри диалога
    List<String> tempSelectedValues = List.from(selectedValues);
    String searchQuery = '';

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return (widget.listValues != null && widget.listValues!.isNotEmpty)
                ? AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Выберите значения', style: formHeaderStyle),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    content: IntrinsicHeight(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.listValues!.length >= 10)
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Поиск',
                                suffixIcon: Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                searchQuery = value;
                                setDialogState(() {});
                              },
                            ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: widget.listValues!
                                    .where((option) => option
                                        .toLowerCase()
                                        .contains(searchQuery.toLowerCase()))
                                    .map((option) {
                                  return CheckboxListTile(
                                    value: tempSelectedValues
                                        .map((v) => v.toLowerCase())
                                        .contains(option.toLowerCase()),
                                    title: Text(option.replaceAll('\n', '').trim(), style: listLabelStyle),
                                    onChanged: (bool? isChecked) {
                                      setDialogState(() {
                                        if (isChecked == true &&
                                            !tempSelectedValues
                                                .map((v) => v.toLowerCase())
                                                .contains(
                                                    option.toLowerCase())) {
                                          tempSelectedValues.add(
                                              option); // Добавляем оригинальное значение
                                        } else if (isChecked == false) {
                                          tempSelectedValues.removeWhere((v) =>
                                              v.toLowerCase() ==
                                              option.toLowerCase());
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Отмена'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          setState(() {
                            selectedValues =
                                tempSelectedValues; // Сохраняем выбранные значения
                            controller.text =
                                selectedValues.join(', ').replaceAll('\n', '').trim(); // Обновляем текст
                          });
                          if (widget.onChanged != null) {
                            widget.onChanged!(
                                selectedValues); // Вызываем колб Honorableэк
                          }
                          Navigator.pop(context);
                          widget.fieldKey.currentState?.validate();
                        },
                      ),
                    ],
                  )
                : AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Выберите значение',
                          style: formHeaderStyle,
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    content: IntrinsicHeight(
                      child: Text(
                        'Нет данных',
                        style: listLabelStyle,
                      ),
                    ),
                  );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.listValues == null || widget.listValues!.isEmpty) return;
    // Инициализируем selectedValues из listSelectValue с учетом регистра
    selectedValues =
        widget.listSelectValue.map((value) => value.toString()).toList();
    // Приводим selectedValues к значениям из listValues с сохранением оригинального регистра
    selectedValues = selectedValues.map((selected) {
      return widget.listValues!.firstWhere(
        (option) => option.toLowerCase() == selected.toLowerCase(),
        orElse: () => selected, // Если не найдено, оставляем как есть
      );
    }).toList();
    // Устанавливаем начальный текст в контроллер
    controller.text = selectedValues
        .map((value) => value.trim()) // Убираем пробелы с каждого элемента
        .join(', ')                   // Объединяем с запятой и пробелом
        .replaceAll('\n', '');
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
          child: (widget.listRoles == Roles.all ||
              widget.listRoles!.contains(widget.role)) &&
              !widget.readOnly
              ? TextFormField(
              key: widget.fieldKey,
              controller: controller,
              readOnly: true,
              validator: (value) {
                if ((value == null || value.isEmpty) && widget.required) {
                  return 'Заполните поле';
                }
                return null;
              },
              maxLines: 50,
              minLines: 1,
              decoration: InputDecoration(
                labelText:
                    widget.required ? '${widget.labelText}*' : widget.labelText,
                labelStyle: inputLabelStyle,
                errorStyle: errorStyle,
                border: widget.border,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
              style: inputTextStyle,
              onTap: () async {
                FocusScope.of(context).unfocus(); // Снимаем фокус с других полей
                await _showMultiSelectDialog(context);
              },
        )
        : RichText(
      softWrap: true,
      strutStyle: const StrutStyle(
        height: 0.1, // Увеличивает высоту строки
        leading: 1.5, // Добавляет дополнительное пространство перед строкой
      ),
      text: TextSpan(
        children: [
          TextSpan(text: '${widget.labelText}:  ', style: labelStyle),
          TextSpan(
            text: selectedValues
                .map((value) => value.trim()) // Убираем пробелы с каждого элемента
                .join(', ')                   // Объединяем с запятой и пробелом
                .replaceAll('\n', ''),
            style: inputTextStyle,
          ),
        ],
      ),
    ),
    );
  }
}
