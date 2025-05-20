import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';
import 'button_widget.dart';

class ShowDialogConfirm extends StatelessWidget {
  final BuildContext parentContext; // Контекст родительской страницы
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const ShowDialogConfirm({
    super.key,
    required this.parentContext,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: formHeaderStyle),
      content: Text(message, style: labelStyle),
      actions: [
        ButtonWidget(
          labelText: 'Нет',
          onlyText: true,
          dialogForm: true,
          listRoles: Roles.all,
          onPressed: () {
            Navigator.of(context).pop(); // Закрываем диалог
          },
        ),
        ButtonWidget(
          labelText: 'Да',
          onlyText: true,
          dialogForm: true,
          listRoles: Roles.all,
          onPressed: () {
            Navigator.of(context).pop(); // Закрываем диалог
            onConfirm();
          },
        ),
      ],
    );
  }


  /// Вызов диалога
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onConfirm,
    String title = 'Внимание',
    required message,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ShowDialogConfirm(
          parentContext: context, // Передаем родительский контекст
          title: title,
          message: message,
          onConfirm: onConfirm,
        );
      },
    );
  }
}
