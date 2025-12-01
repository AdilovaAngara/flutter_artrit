import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';






import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../data/data_spr_item.dart';
import '../roles.dart';
import '../theme.dart';

class InputMultiSelect extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState>? fieldKey;
  final List<String>? selectedValues; // Изменён тип на List<String>?
  final bool required;
  final bool readOnly;
  final bool cleanAvailable;
  final InputBorder border;
  final List<SprItem> allValues;
  final ValueChanged<List<String>?>? onChanged; // Изменён тип аргумента
  final int? roleId;
  final List<int>? listRoles;

  const InputMultiSelect({
    super.key,
    required this.labelText,
    required this.fieldKey,
    this.selectedValues,
    required this.required,
    this.readOnly = false,
    this.cleanAvailable = true,
    this.border = const UnderlineInputBorder(),
    required this.allValues,
    this.onChanged,
    this.roleId,
    required this.listRoles,
  });

  @override
  WidgetInputMultiSelectState createState() => WidgetInputMultiSelectState();
}

class WidgetInputMultiSelectState extends State<InputMultiSelect> {
  TextEditingController controller = TextEditingController();
  List<String>? selectedValues; // Изменён тип на List<String>?


  bool _isChangeAvailable() {
    return (widget.listRoles == Roles.all ||
        widget.listRoles!.contains(widget.roleId)) && !widget.readOnly;
  }

  Future<void> _showMultiSelectDialog(BuildContext context) async {
    // Сохраняем исходное состояние перед открытием диалога
    List<String>? originalSelectedValues = List.from(selectedValues ?? []);
    List<String> tempSelectedValues = List.from(selectedValues ?? []);
    String searchQuery = '';

    // Создаём копию allValues и сортируем её по name
    List<SprItem> sortedAllValues = List.from(widget.allValues)..sort((a, b) => a.name.compareTo(b.name));

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return widget.allValues.isNotEmpty
                ? AlertDialog(
              backgroundColor: Colors.white,
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
              content: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 400, maxWidth: 1000, minHeight: 300),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sortedAllValues.length >= 10)
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
                            children: sortedAllValues
                                .where((option) => option.name
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()))
                                .map((option) {
                              bool isSelected = tempSelectedValues.contains(option.id);
                              return CheckboxListTile(
                                value: isSelected,
                                title: Text(
                                  option.name.replaceAll('\n', '').trim(),
                                  style: listLabelStyle,
                                ),
                                onChanged: (bool? isChecked) {
                                  setDialogState(() {
                                    if (isChecked == true && !tempSelectedValues.contains(option.id)) {
                                      tempSelectedValues.add(option.id);
                                    } else if (isChecked == false) {
                                      tempSelectedValues.remove(option.id);
                                    }
                                    // Сортируем tempSelectedValues для консистентности
                                    tempSelectedValues.sort();
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
              ),
              actions: [
                TextButton(
                  child: const Text('Отмена'),
                  onPressed: () {
                    // Восстанавливаем исходное состояние при отмене
                    setState(() {
                      selectedValues = originalSelectedValues;
                      controller.text = _getDisplayText(selectedValues);
                    });
                    widget.onChanged?.call(selectedValues);
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    setState(() {
                      selectedValues = tempSelectedValues.isEmpty ? null : tempSelectedValues;
                      controller.text = _getDisplayText(selectedValues);
                    });
                    widget.onChanged?.call(selectedValues);
                    Navigator.pop(context);
                    widget.fieldKey?.currentState?.validate();
                  },
                ),
              ],
            )
                : AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Выберите значение', style: formHeaderStyle),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              content: IntrinsicHeight(
                child: Text('Нет данных', style: listLabelStyle),
              ),
            );
          },
        );
      },
    );
  }

  String _getDisplayText(List<String>? values) {
    if (values == null || values.isEmpty) return '';
    return values.map((id) {
      SprItem? item = widget.allValues.firstWhere((item) => item.id == id, orElse: () => SprItem(id: '', name: ''));
      return item.name.trim();
    }).join(', ');
  }

  @override
  void initState() {
    super.initState();
    selectedValues = widget.selectedValues?.where((id) => widget.allValues.any((item) => item.id == id)).toList();
    // Сортируем selectedValues при инициализации
    if (selectedValues != null) {
      selectedValues!.sort();
    }
    controller.text = _getDisplayText(selectedValues);
  }

  @override
  void didUpdateWidget(covariant InputMultiSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValues != oldWidget.selectedValues ||
        widget.allValues != oldWidget.allValues) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          selectedValues = widget.selectedValues?.where((id) => widget.allValues.any((item) => item.id == id)).toList();
          // Сортируем selectedValues при обновлении
          if (selectedValues != null) {
            selectedValues!.sort();
          }
          controller.text = _getDisplayText(selectedValues);
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
      padding: const EdgeInsets.only(bottom: 10.0),
      child: _isChangeAvailable()
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
          labelText: widget.required && widget.labelText.isNotEmpty
              ? '${widget.labelText}*'
              : widget.labelText,
          labelStyle: inputLabelStyle,
          errorStyle: errorStyle,
          border: widget.border,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.selectedValues != null && widget.selectedValues!.isNotEmpty && widget.cleanAvailable)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          controller.clear();
                          widget.onChanged?.call(null);
                          widget.fieldKey?.currentState?.didChange(null);
                          setState(() {});
                        }
                      });
                    },
                  ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        style: inputTextStyle,
        onTap: () async {
          FocusScope.of(context).unfocus();
          await _showMultiSelectDialog(context);
        },
      )
          : RichText(
        softWrap: true,
        strutStyle: const StrutStyle(
          height: 0.1,
          leading: 1.5,
        ),
        text: TextSpan(
          children: [
            TextSpan(text: widget.labelText.isNotEmpty ? '${widget.labelText}:  ' : '  ', style: labelStyle),
            TextSpan(
              text: _getDisplayText(selectedValues),
              style: inputTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}











class InputMultiSelect0 extends StatefulWidget {
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

  const InputMultiSelect0({
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

class InputMultiSelectState extends State<InputMultiSelect0> {
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
