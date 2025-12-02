import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../data/data_spr_item.dart';
import '../roles.dart';
import '../theme.dart';

class WidgetInputSelect extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState> fieldKey;
  final List<SprItem> allValues;
  final String? selectedValue;
  final bool required;
  final bool readOnly;
  final bool cleanAvailable;
  final ValueChanged<String?>? onChanged;
  final bool isSort;
  final int? roleId;
  final List<int>? listRoles;

  const WidgetInputSelect({
    super.key,
    required this.labelText,
    required this.fieldKey,
    required this.allValues,
    required this.selectedValue,
    required this.required,
    this.readOnly = false,
    this.cleanAvailable = true,
    this.onChanged,
    this.isSort = true,
    this.roleId,
    required this.listRoles,
  });

  @override
  WidgetInputSelectState createState() => WidgetInputSelectState();
}

class WidgetInputSelectState extends State<WidgetInputSelect> {
  TextEditingController controller = TextEditingController();

  Future<SprItem?> _showDropdownDialog(BuildContext context) async {
    String searchQuery = '';

    // Создаём копию allValues и сортируем её по name
    List<SprItem> sortedAllValues = [];
    if (widget.isSort) {
      sortedAllValues = List.from(widget.allValues)..sort((a, b) => a.name.compareTo(b.name));
    } else {
      sortedAllValues = widget.allValues;
    }

    return showDialog<SprItem>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return widget.allValues.isNotEmpty
                ? AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Выберите значение', style: formHeaderStyle),
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
                  children: [
                    if (sortedAllValues.length >= 10)
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Поиск',
                          suffixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          searchQuery = value;
                          setState(() {});
                        },
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: sortedAllValues
                              .where((option) => option.name
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                              .map((option) {
                            return ListTile(
                              title: Text(
                                option.name,
                                style: listLabelStyle,
                              ),
                              onTap: () {
                                Navigator.pop(context, option);
                              },
                            );
                          })
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Выберите значение', style: formHeaderStyle),
                  IconButton(
                    icon: const Icon(Icons.close),
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

  @override
  void initState() {
    super.initState();
    // Инициализация контроллера, проверяем, что selectedValue есть в allValues
    controller = TextEditingController(
      text: widget.allValues.map((e) => e.id).contains(widget.selectedValue)
          ? widget.allValues.firstWhere((e) => e.id == widget.selectedValue).name
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant WidgetInputSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Асинхронно обновляем controller.text
    if (widget.selectedValue != oldWidget.selectedValue ||
        widget.allValues != oldWidget.allValues) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final text = widget.allValues.map((e) => e.id).contains(widget.selectedValue)
              ? widget.allValues.firstWhere((e) => e.id == widget.selectedValue).name
              : '';
          if (controller.text != text) {
            controller.text = text;
            widget.fieldKey.currentState?.didChange(widget.selectedValue);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  bool _isChangeAvailable() {
    return (widget.listRoles == Roles.all ||
        widget.listRoles!.contains(widget.roleId)) && !widget.readOnly;
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
          border: const UnderlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.selectedValue != null && widget.selectedValue!.isNotEmpty && widget.cleanAvailable)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          controller.clear();
                          widget.onChanged?.call(null);
                          widget.fieldKey.currentState?.didChange(null);
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
          final selected = await _showDropdownDialog(context);
          if (selected != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  controller.text = selected.name;
                  widget.onChanged?.call(selected.id);
                  widget.fieldKey.currentState?.didChange(selected.name);
                  widget.fieldKey.currentState?.validate();
                });
              }
            });
          }
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
              text: widget.allValues.map((e) => e.id).contains(widget.selectedValue)
                  ? widget.allValues.firstWhere((e) => e.id == widget.selectedValue).name
                  : '',
              style: inputTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}