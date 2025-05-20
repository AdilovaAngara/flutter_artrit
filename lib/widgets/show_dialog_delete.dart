import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';
import 'button_widget.dart';

class ShowDialogDelete extends StatelessWidget {
  final VoidCallback onConfirm;
  final String? text;

  const ShowDialogDelete({
    super.key,
    required this.onConfirm,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Подтверждение удаления', style: formHeaderStyle,),
      content: Text(
        text ?? 'Вы действительно хотите удалить запись?',
        style: labelStyle,
      ),
      actions: [
        ButtonWidget(
          labelText: 'Нет',
          onlyText: true,
          dialogForm: true,
          listRoles: Roles.all,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        SizedBox(width: 10.0),
        ButtonWidget(
          labelText: 'Да',
          onlyText: true,
          dialogForm: true,
          listRoles: Roles.all,
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
      ],
    );
  }
}
