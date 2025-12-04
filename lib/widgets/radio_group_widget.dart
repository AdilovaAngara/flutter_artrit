import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';

class RadioGroupWidget extends StatefulWidget {
  final String? labelText;
  final List<String> listAnswers;
  final int? selectedIndex;
  final double dividerHeight;
  final ValueChanged<int?>? onChanged;
  final int? role;
  final List<int>? listRoles;

  const RadioGroupWidget({
    super.key,
    this.labelText,
    required this.listAnswers,
    required this.selectedIndex,
    this.dividerHeight = 20.0,
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
              if (widget.labelText != null && widget.labelText!.isNotEmpty)
                Text('${widget.labelText!}:',
                    style: labelStyle),

              RadioGroup<int>(
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value;
                  });
                  state.didChange(value);
                  widget.onChanged?.call(value);
                },
                child: Column(
                  children: widget.listAnswers.asMap().entries.expand((entry) {
                    int index = entry.key;
                    String option = entry.value;

                    final isEnabled =
                        widget.listRoles == Roles.all ||
                            widget.listRoles!.contains(widget.role);

                    return [
                      RadioListTile<int>(
                        title: Text(option, style: listLabelStyle),
                        value: index,
                        enabled: isEnabled,
                        contentPadding: const EdgeInsets.only(top: 8),
                        visualDensity: VisualDensity.compact,
                        dense: true,
                      ),

                      if (index < widget.listAnswers.length - 1)
                        Divider(
                          height: widget.dividerHeight,
                          thickness: 0.5,
                          color: Colors.black12,
                        ),
                    ];
                  }).toList(),
                ),
              ),
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