import 'dart:io';
import 'package:artrit/secure_storage.dart';
import 'package:artrit/widgets/audio_provider.dart';
import 'package:artrit/widgets/chat_provider.dart';
import 'package:artrit/widgets/notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:artrit/routes.dart';
import 'package:artrit/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:provider/provider.dart';
import 'api/base_client.dart';
import 'my_functions.dart';



// Перед публикацией
// 1. Скрыть тестовые кнопки
// 2. Заменить адрес API
// 3. Закомментировать код, который отключает проверку сертификата HttpOverrides.global = MyHttpOverrides();
// 4. Увеличить номер сборки в pubspec.yaml и codemagic.yaml
// 5. При сборке для Android надо указывать после знака + версию, которая выше той, что уже опубликована. Андроид почему-то не смотрит, что предыдущие цифры стали выше



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  int role = await getUserRole();
  String login = await readSecureData(SecureKey.login);
  String password = await readSecureData(SecureKey.password);
  if (Platform.isAndroid) {
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = '/';
  }
  // Этот код отключает проверку сертификата (раскомментировать только для тестирования, если андроид ругается на сертификат)
  if (BaseClient().isTest) {
    HttpOverrides.global = MyHttpOverrides();
  }
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AudioProvider()),
            ChangeNotifierProvider(
              create: (context) => ChatProvider(
                audioProvider: Provider.of<AudioProvider>(context, listen: false),
              ),
            ),
            ChangeNotifierProvider(create: (_) => NotificationsProvider()),
          ],
          child: Main(
            role: role,
            login: login,
            password: password,
          ))
  );
}




class Main extends StatelessWidget {
  final int role;
  final String login;
  final String password;

  const Main({
    super.key,
    required this.role,
    required this.login,
    required this.password
  });






  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'), // Английский
        Locale('ru', 'RU'), // Русский
      ],
      locale: Locale('ru', 'RU'), // Устанавливаем русскую локализацию
        title: 'Название приложения',
        theme: AppTheme.lightTheme,
        // Используйте тему из отдельного файла
        //home: Page1(), // это можно использовать, когда всего 1 страница
        initialRoute: (login.isNotEmpty && password.isNotEmpty && role == 2) ? AppRoutes.doctorMain : (login.isNotEmpty && password.isNotEmpty && role == 1) ? AppRoutes.patientMain : AppRoutes.first,
        // указывает изначальный путь
        routes: routes,
    );
  }
}






class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}



