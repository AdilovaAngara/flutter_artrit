import 'package:artrit/pages/page_anamnesis.dart';
import 'package:artrit/pages/page_chat_main.dart';
import 'package:artrit/pages/page_doctor_edit.dart';
import 'package:artrit/pages/page_doctor_main.dart';
import 'package:artrit/pages/page_help.dart';
import 'package:artrit/pages/page_info.dart';
import 'package:artrit/pages/page_inspections_main.dart';
import 'package:artrit/pages/page_library.dart';
import 'package:artrit/pages/page_login.dart';
import 'package:artrit/pages/page_patient_edit.dart';
import 'package:artrit/pages/page_patient_main.dart';
import 'package:artrit/pages/page_patients.dart';
import 'package:artrit/pages/page_questionnaire.dart';
import 'package:artrit/pages/page_report.dart';
import 'package:artrit/pages/page_researches.dart';
import 'package:artrit/pages/page_scale.dart';
import 'package:artrit/pages/page_settings.dart';
import 'package:artrit/pages/page_tests.dart';
import 'package:artrit/pages/page_treatment.dart';
import 'package:artrit/pages/page_tuberculosis.dart';
import 'package:artrit/pages/page_vaccination.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/chat_provider.dart';
import '../widgets/notifications_provider.dart';
import '../widgets/show_dialog_confirm.dart';
import '../widgets/text_view_widget.dart';


enum EnumMenu {
  homePatient,
  homeDoctor,
  profilePatient,
  profileDoctor,
  anamnesis,
  inspections,
  tests,
  researches,
  treatment,
  tuberculosis,
  vaccination,
  questionnaire,
  scale,
  report,
  library,
  settings,
  help,
  info,
  logOut,
  patients,
  chat,
}

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  late Future<void> _future;
  late int _role;

  @override
  void initState() {
    super.initState();
    _future = getRole();
  }

  Future<void> getRole() async {
    _role = await getUserRole();
  }



  // Списки пунктов меню для разных ролей
  static const List<EnumMenu> _menuItemsPatient = [
    EnumMenu.homePatient,
    EnumMenu.profilePatient,
    EnumMenu.chat,
    EnumMenu.anamnesis,
    EnumMenu.inspections,
    EnumMenu.tests,
    EnumMenu.researches,
    EnumMenu.treatment,
    EnumMenu.tuberculosis,
    EnumMenu.vaccination,
    EnumMenu.questionnaire,
    EnumMenu.scale,
    EnumMenu.report,
    EnumMenu.library,
    EnumMenu.settings,
    EnumMenu.help,
    EnumMenu.info,
    EnumMenu.logOut,
  ];

  static const List<EnumMenu> _menuItemsDoctor = [
    EnumMenu.homeDoctor,
    EnumMenu.profileDoctor,
    EnumMenu.chat,
    EnumMenu.patients,
    EnumMenu.library,
    EnumMenu.settings,
    EnumMenu.help,
    EnumMenu.info,
    EnumMenu.logOut,
  ];


  static const List<EnumMenu> _menuItemsAnonymous = [
    EnumMenu.library,
    EnumMenu.help,
    EnumMenu.info,
  ];


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

        final menuItems = Roles.asPatient.contains(_role)
            ? _menuItemsPatient
            : Roles.asDoctor.contains(_role)
            ? _menuItemsDoctor
            : _menuItemsAnonymous;

        return Drawer(
          width: MediaQuery.of(context).size.width * 0.70,
          child: Scaffold(
            appBar: AppBarWidget(
              title: 'Меню',
              closeMenu: true,
              automaticallyImplyLeading: false,
              showChat: false,
              showNotifications: false,
            ),
            backgroundColor: Colors.white,
            body: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final menu = menuItems[index];
                return MenuCard(
                  menuItem: MenuItem(
                    icon: menu.icon,
                    iconColor: menu.iconColor,
                    title: menu.displayName,
                    onTap: () {
                      if (menu.displayName == EnumMenu.logOut.displayName) {
                        ShowDialogConfirm.show(
                          context: context,
                          message: 'Вы действительно хотите выйти?',
                          onConfirm: () async {
                            navigateToPageMenu(context, EnumMenu.logOut);
                            // Очищаем провайдеры
                            Provider.of<NotificationsProvider>(context, listen: false).clear();
                            Provider.of<ChatProvider>(context, listen: false).clear();
                            // Очищаем SecureStorage
                            await deleteAllSecureData();
                          }

                        );
                      } else {
                        navigateToPageMenu(context, menu);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class MenuItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });
}

class MenuCard extends StatelessWidget {
  final MenuItem menuItem;

  const MenuCard({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      //elevation: 2, // Нижнее подчеркивание последнего пункта меню
      child: InkWell(
        onTap: () {
          menuItem.onTap();
        },
        splashColor: Colors.deepPurple.withGreen(130).withAlpha(100),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                menuItem.icon,
                size: 30,
                color: menuItem.iconColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextViewWidget(
                  text: menuItem.title,
                  style: listLabelStyle,
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






extension EnumMenuExtension on EnumMenu {

  String get displayName {
    switch (this) {
      case EnumMenu.homePatient:
        return 'Главная';
      case EnumMenu.homeDoctor:
        return 'Главная';
      case EnumMenu.profilePatient:
        return 'Мои данные';
      case EnumMenu.profileDoctor:
        return 'Мои данные';
      case EnumMenu.chat:
        return 'Чат';
      case EnumMenu.anamnesis:
        return 'Анамнез';
      case EnumMenu.inspections:
        return 'Осмотры';
      case EnumMenu.tests:
        return 'Анализы';
      case EnumMenu.researches:
        return 'Исследования';
      case EnumMenu.treatment:
        return 'Лечение';
      case EnumMenu.tuberculosis:
        return 'Туберкулёзная инфекция';
      case EnumMenu.vaccination:
        return 'Вакцинация';
      case EnumMenu.questionnaire:
        return 'Опросник качества жизни';
      case EnumMenu.scale:
        return 'Шкалы';
      case EnumMenu.report:
        return 'Отчет';
      case EnumMenu.library:
        return 'Библиотека';
      case EnumMenu.settings:
        return 'Настройки';
      case EnumMenu.help:
        return 'Помощь';
      case EnumMenu.info:
        return 'О приложении';
      case EnumMenu.logOut:
        return 'Выход';
      case EnumMenu.patients:
        return 'Пациенты';
    }
  }

  IconData get icon {
    switch (this) {
      case EnumMenu.homePatient:
        return Icons.home;
      case EnumMenu.homeDoctor:
        return Icons.home;
      case EnumMenu.profilePatient:
        return FontAwesomeIcons.solidUser;
      case EnumMenu.profileDoctor:
        return FontAwesomeIcons.userDoctor;
      case EnumMenu.chat:
        return FontAwesomeIcons.message;
      case EnumMenu.anamnesis:
        return FontAwesomeIcons.bookMedical;
      case EnumMenu.inspections:
        return FontAwesomeIcons.stethoscope;
      case EnumMenu.tests:
        return FontAwesomeIcons.flask;
      case EnumMenu.researches:
        return FontAwesomeIcons.notesMedical;
      case EnumMenu.treatment:
        return FontAwesomeIcons.capsules;
      case EnumMenu.tuberculosis:
        return FontAwesomeIcons.bacteria;
      case EnumMenu.vaccination:
        return FontAwesomeIcons.shieldVirus;
      case EnumMenu.questionnaire:
        return FontAwesomeIcons.solidStar;
      case EnumMenu.scale:
        return FontAwesomeIcons.arrowUpRightDots;
      case EnumMenu.report:
        return Icons.list_alt_outlined;
      case EnumMenu.library:
        return Icons.my_library_books;
      case EnumMenu.settings:
        return Icons.settings;
      case EnumMenu.help:
        return FontAwesomeIcons.question;
      case EnumMenu.info:
        return Icons.info;
      case EnumMenu.logOut:
        return Icons.logout;
      case EnumMenu.patients:
        return FontAwesomeIcons.users;
    }
  }

  Color get iconColor {
    switch (this) {
      case EnumMenu.homePatient:
        return Colors.green.shade200;
      case EnumMenu.homeDoctor:
        return Colors.green.shade200;
      case EnumMenu.profilePatient:
        return Colors.deepPurple.shade200;
      case EnumMenu.profileDoctor:
        return Colors.blueAccent.shade100;
      case EnumMenu.chat:
        return Colors.indigo.shade200;
      case EnumMenu.anamnesis:
        return Colors.brown.shade200;
      case EnumMenu.inspections:
        return Colors.black54;
      case EnumMenu.tests:
        return Colors.red.shade200;
      case EnumMenu.researches:
        return Colors.blue.shade200;
      case EnumMenu.treatment:
        return Colors.orange.shade200;
      case EnumMenu.tuberculosis:
        return Colors.green.shade200;
      case EnumMenu.vaccination:
        return Colors.blueAccent.shade100;
      case EnumMenu.questionnaire:
        return Colors.yellow.shade600;
      case EnumMenu.scale:
        return Colors.blueGrey.shade200;
      case EnumMenu.report:
        return Colors.blue.shade200;
      case EnumMenu.library:
        return Colors.purple.shade200;
      case EnumMenu.settings:
        return Colors.grey;
      case EnumMenu.help:
        return Colors.orange.shade200;
      case EnumMenu.info:
        return Colors.indigo.shade200;
      case EnumMenu.logOut:
        return Colors.deepPurple.shade200;
      case EnumMenu.patients:
        return Colors.deepPurple.shade200;
    }
  }

  Widget Function(String) get pageBuilder {
    switch (this) {
      case EnumMenu.homePatient:
        return (title) => PagePatientMain();
      case EnumMenu.homeDoctor:
        return (title) => PageDoctorMain();
      case EnumMenu.profilePatient:
        return (title) => PagePatientEdit(title: title);
      case EnumMenu.profileDoctor:
        return (title) => PageDoctorEdit(title: title);
      case EnumMenu.chat:
        return (title) => PageChatMain(title: title,);
      case EnumMenu.anamnesis:
        return (title) => PageAnamnesis(title: title);
      case EnumMenu.inspections:
        return (title) => PageInspectionsMain(title: title);
      case EnumMenu.tests:
        return (title) => PageTests(title: title);
      case EnumMenu.researches:
        return (title) => PageResearches(title: title);
      case EnumMenu.treatment:
        return (title) => PageTreatment(title: title);
      case EnumMenu.tuberculosis:
        return (title) => PageTuberculosis(title: title);
      case EnumMenu.vaccination:
        return (title) => PageVaccination(title: title);
      case EnumMenu.questionnaire:
        return (title) => PageQuestionnaire(title: title);
      case EnumMenu.scale:
        return (title) => PageScale(title: title);
      case EnumMenu.report:
        return (title) => PageReport(title: title);
      case EnumMenu.library:
        return (title) => PageLibrary(title: title);
      case EnumMenu.settings:
        return (title) => PageSettings(title: title);
      case EnumMenu.help:
        return (title) => PageHelp(title: title);
      case EnumMenu.info:
        return (title) => PageInfo(title: title);
      case EnumMenu.logOut:
        return (title) => PageLogin();
      case EnumMenu.patients:
        return (title) => PagePatients(title: title);
    }
  }
}











