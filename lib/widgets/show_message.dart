import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';
import 'button_widget.dart';

class ShowMessage extends StatelessWidget {
  final BuildContext parentContext; // Контекст родительской страницы
  final String title;
  final String message;
  final VoidCallback? onConfirm;

  const ShowMessage({
    super.key,
    required this.parentContext,
    required this.title,
    required this.message,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: formHeaderStyle),
      content: Text(message, style: labelStyle),
      actions: [
        ButtonWidget(
          labelText: 'Ок',
          onlyText: true,
          dialogForm: true,
          listRoles: Roles.all,
          onPressed: () {
            // Закрываем диалог с использованием контекста диалога
            Navigator.of(context).pop();
            // Вызываем onConfirm с использованием parentContext
            if (onConfirm != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onConfirm!(); // Выполняем callback после завершения текущего кадра
              });
            }
          },
        ),
      ],
    );
  }

  // Статический метод для удобного вызова диалога
  static Future<void> show({
    required BuildContext context,
    VoidCallback? onConfirm,
    String title = 'Внимание',
    String message = 'Исправьте ошибки на форме!',
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: onConfirm != null ? false : true, // Диалог не закроется при клике вне его
      builder: (BuildContext dialogContext) {
        return ShowMessage(
          parentContext: context, // Передаем родительский контекст
          title: title,
          message: message,
          onConfirm: onConfirm,
        );
      },
    );
  }
}
