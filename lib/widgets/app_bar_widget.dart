import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../my_functions.dart';
import '../pages/menu.dart';
import '../pages/page_notifications_for_doctor.dart';
import '../pages/page_notifications_for_patient.dart';
import '../roles.dart';
import 'chat_provider.dart';
import 'notifications_provider.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenu;
  final bool showNotifications;
  final bool showChat;
  final bool closeMenu;
  final bool automaticallyImplyLeading;
  final VoidCallback? onPressed;

  const AppBarWidget({
    super.key,
    required this.title,
    this.showMenu = true,
    this.showNotifications = true,
    this.showChat = true,
    this.closeMenu = false,
    this.automaticallyImplyLeading = true,
    this.onPressed,
  });

  @override
  State<AppBarWidget> createState() => AppBarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppBarWidgetState extends State<AppBarWidget> {

  /// Параметры
  late int _role;

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  Future<void> _loadData() async {
    _role = await getUserRole();
    if (mounted) {
      setState(() {});
    }
  }




  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, NotificationsProvider>(
        builder: (context, chatProvider, notificationsProvider, child) {
        return AppBar(
          title: Text(
            widget.title,
            maxLines: 2,
          ),
          titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold),
          centerTitle: true,
          //backgroundColor: mainColor,
          backgroundColor: Colors.transparent,

          /// Устанавливаем прозрачный фон
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actionsIconTheme: const IconThemeData(color: Colors.grey),
          automaticallyImplyLeading: false,
          /// Иконка назад
          leading: widget.automaticallyImplyLeading
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onPressed ?? () => Navigator.pop(context),
          )
              : null,
          leadingWidth: 35.0,
          actions: [
            /// Иконка чата
            if (widget.showChat)
              GestureDetector(
                onTap: () => navigateToPageMenu(context, EnumMenu.chat),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _buildChatIcon(chatProvider.messageCount),
                ),
              ),

            /// Иконка уведомлений
            if (widget.showNotifications)
              GestureDetector(
                onTap: () => _onPressedNotifications(context, notificationsProvider),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _buildNotificationIcon(notificationsProvider.notificationsCount),
                ),
              ),

            /// Иконка меню
            if (widget.showMenu)
              IconButton(
                onPressed: () {
                  widget.closeMenu
                      ? Navigator.pop(context)
                      : Scaffold.of(context).openEndDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 35,
                ),
              ),
          ],
        );
      }
    );
  }

  void _onPressedNotifications(BuildContext context, NotificationsProvider notificationsProvider) {
    if (Roles.asPatient.contains(_role)) {
      showDialog(
        context: context,
        builder: (context) => PageNotificationsForPatient(
          thisData: notificationsProvider.patientNotifications ?? [],
          onDataUpdated: () async {
            await notificationsProvider.onNotificationsUpdated();
          },
        ),
      );
    } else if (Roles.asDoctor.contains(_role)) {
      showDialog(
        context: context,
        builder: (context) => PageNotificationsForDoctor(
          thisData: notificationsProvider.doctorNotifications ?? [],
          onDataUpdated: () async {
            await notificationsProvider.onNotificationsUpdated();
          },
        ),
      );
    }
  }



  Widget _buildNotificationIcon(int notificationsCount) {
    final icon = const Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
      child: Icon(Icons.notifications, color: Colors.white),
    );
    return notificationsCount > 0
        ? Badge.count(
      backgroundColor: Colors.orange,
      textStyle: const TextStyle(fontSize: 15),
      count: notificationsCount,
      child: icon,
    )
        : icon;
  }

  Widget _buildChatIcon(int messageCount) {
    final icon = const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Icon(Icons.chat, color: Colors.white),
    );
    return messageCount > 0
        ? Badge.count(
      backgroundColor: Colors.orange,
      textStyle: const TextStyle(fontSize: 15),
      count: messageCount,
      child: icon,
    )
        : icon;
  }
}
