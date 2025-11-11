import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../my_functions.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import 'menu.dart';

class PageHelp extends StatefulWidget {
  final String title;

  const PageHelp({
    super.key,
    required this.title,
  });

  @override
  State<PageHelp> createState() => _PageHelpState();
}

class _PageHelpState extends State<PageHelp> {
  late Future<void> _future;

  /// Параметры
  late int _role;
  static const String supportEmail = 'qa2@nitrosbase.com';

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }


  Future<void> _loadData() async {
    _role = await getUserRole();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return errorDataWidget(snapshot.error);
          }

        return Scaffold(
          appBar: AppBarWidget(
            title: widget.title,
            showMenu: _role > -1,
            showChat: _role > -1,
            showNotifications: _role > -1,
          ),
          endDrawer: _role > -1 ? MenuDrawer() : null,
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Служба поддержки:',
                  style: captionTextStyle,),
                SizedBox(height: 15),
                Text('8(495)627-29-61 (будни 09:00-18:00)',
                    style: inputTextStyle),
                SizedBox(height: 8),
                InkWell(
                  onTap: launchEmail,
                  child: const Text(
                    supportEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // Функция для запуска mailto
  void launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {'subject': 'Вопрос о приложении Appee'},
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      copyToClipboard(context, textToCopy: supportEmail, textName: 'Адрес');
      throw 'Не удалось открыть почтовый клиент';
    }
  }
}