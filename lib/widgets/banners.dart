import 'package:flutter/material.dart';


void showTopActionBanner({
  required BuildContext context,
  required String message,
  required VoidCallback onPressed,
}) {
  final messenger = ScaffoldMessenger.of(context);
  /// Очищаем предыдущий баннер
  messenger.clearSnackBars();
  /// Создаем баннер
  final banner = MaterialBanner(
    content: Text(
      message,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black87),
    ),
    backgroundColor: Colors.orange,
    elevation: 2, // тень
    actions: [
      TextButton(
        onPressed: () {
          messenger.hideCurrentMaterialBanner();
          onPressed();
        },
        child: const Text(
          'Перейти',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
      ),
    ],
  );

  /// Показываем баннер
  messenger.showMaterialBanner(banner);

  /// Автоматическое закрытие через 5 секунд
  Future.delayed(const Duration(seconds: 5), () {
    if (context.mounted) {
      messenger.hideCurrentMaterialBanner();
    }
  });
}



void showTopBanner({
  required BuildContext context,
  String message = 'Исправьте ошибки на форме!',
}) {
  final messenger = ScaffoldMessenger.of(context);
  final banner = MaterialBanner(
    content: Text(
      message,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black87),
    ),
    backgroundColor: Colors.orange,
    actions: [
      TextButton(
        onPressed: () {
          messenger.hideCurrentMaterialBanner();
        },
        child: Text('Закрыть',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
      ),
    ],
  );

  messenger.showMaterialBanner(banner);

  /// Автоматическое исчезновение баннера через 3 секунды
  Future.delayed(Duration(seconds: 3), () {
    messenger.hideCurrentMaterialBanner();
  });
}



void showBottomBanner({
  required BuildContext context,
  String message = 'Исправьте ошибки на форме!',
  int seconds = 3,
}) {
  final messenger = ScaffoldMessenger.of(context);

  // Очищаем предыдущие SnackBar'ы
  messenger.clearSnackBars();
  // Показываем SnackBar с автоматическим закрытием через duration
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black.withAlpha(90),
      duration: Duration(seconds: seconds), // Устанавливаем время отображения
    ),
  );
}







