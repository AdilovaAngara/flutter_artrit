import 'package:flutter/material.dart';
import '../roles.dart';
import '../widgets/button_widget.dart';
import '../theme.dart';

class ShowDialogBack extends StatelessWidget {
  final BuildContext parentContext; // Контекст родительской страницы
  final String title;
  final String message;

  const ShowDialogBack({
    super.key,
    required this.parentContext,
    required this.title,
    required this.message,
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
            Navigator.of(parentContext).pop(); // Возвращаемся назад на родительскую страницу
          },
        ),
      ],
    );
  }

  // Статический метод для удобного вызова диалога
  static Future<void> show({
    required BuildContext context,
    String title = 'Внимание',
    String message = 'Вы действительно хотите покинуть страницу, не сохранив данные?',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ShowDialogBack(
          parentContext: context, // Передаем родительский контекст
          title: title,
          message: message,
        );
      },
    );
  }
}