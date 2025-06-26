import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';

class InputSelect extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState> fieldKey;
  final dynamic value;
  final bool required;
  final bool readOnly;
  final bool cleanAvailable;
  final List<dynamic>? listValues;
  final ValueChanged<String>? onChanged;
  final int? role;
  final List<int>? listRoles;

  const InputSelect({
    super.key,
    required this.labelText,
    required this.fieldKey,
    required this.value,
    required this.required,
    this.readOnly = false,
    this.cleanAvailable = true,
    required this.listValues,
    this.onChanged,
    this.role,
    required this.listRoles,
  });

  @override
  InputSelectState createState() => InputSelectState();
}

class InputSelectState extends State<InputSelect> {
  TextEditingController controller = TextEditingController();

  Future<String?> _showDropdownDialog(BuildContext context) async {
    String searchQuery = '';

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return (widget.listValues != null && widget.listValues!.isNotEmpty)
                ? AlertDialog(
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
                      child: Column(
                        //mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.listValues!.length >= 10)
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Поиск',
                                suffixIcon: Icon(Icons
                                    .search), // Если хотим иконку слева, то используем prefixIcon
                              ),
                              onChanged: (value) {
                                searchQuery = value.toString();
                                setState(
                                    () {}); // Обновляем состояние для фильтрации списка
                              },
                            ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                //mainAxisSize: MainAxisSize.min,
                                children: widget.listValues!
                                    .where((option) => option
                                        .toString()
                                        .toLowerCase()
                                        .contains(searchQuery.toLowerCase()))
                                    .map((option) {
                                  return ListTile(
                                    title: Text(
                                      option.toString(),
                                      style: listLabelStyle,
                                    ),
                                    onTap: () {
                                      Navigator.pop(
                                          context,
                                          option
                                              .toString()); // Возвращаем выбранное значение
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
    controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant InputSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Синхронизируем controller.text с новым значением widget.value
    if (widget.value?.toString() != controller.text) {
      controller.text = widget.value?.toString() ?? '';
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
          child: (widget.listRoles == Roles.all ||
              widget.listRoles!.contains(widget.role)) &&
              !widget.readOnly
              ? TextFormField(
              key: widget.fieldKey,
              controller: controller,
              readOnly: true,
              validator: (value) {
                if ((value == null || value.toString().isEmpty) &&
                    widget.required) {
                  return 'Заполните поле';
                }
                return null;
              },
              maxLines: 10,
              minLines: 1,
              decoration: InputDecoration(
                labelText:
                    widget.required ? '${widget.labelText}*' : widget.labelText,
                labelStyle: inputLabelStyle,
                errorStyle: errorStyle,
                border: UnderlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                // Всегда отображать label сверху
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.text.isNotEmpty &&
                          widget
                              .cleanAvailable) // Показываем крестик только если есть текст и разрешено очищать поле
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            controller.clear(); // Очищаем поле
                            if (widget.onChanged != null) {
                              widget.onChanged!(
                                  ''); // Вызываем колбэк с пустым значением
                            }
                            widget.fieldKey.currentState
                                ?.validate(); // Перепроверяем валидацию
                          },
                        ),
                      Icon(
                        Icons.arrow_drop_down,
                      ), // Иконка раскрытия списка
                    ],
                  ),
                ),
              ),
              style: inputTextStyle,
              onTap: () async {
                FocusScope.of(context).unfocus();
                final selected = await _showDropdownDialog(context);
                if (selected != null) {
                  // Откладываем обновление состояния
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        controller.text = selected.toString();
                        if (widget.onChanged != null) {
                          widget.onChanged!(selected.toString());
                        }
                      });
                      widget.fieldKey.currentState?.validate();
                    }
                  });
                }
              },
        )
        : RichText(
            softWrap: true,
            strutStyle: const StrutStyle(
              height: 0.1, // Увеличивает высоту строки (1.0 — стандартное значение)
              leading: 1.5, // Добавляет дополнительное пространство перед строкой
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
