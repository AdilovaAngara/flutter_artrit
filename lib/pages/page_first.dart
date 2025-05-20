import 'package:artrit/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import '../roles.dart';
import '../routes.dart';
import '../widgets/circular_image_widget.dart';

class PageFirst extends StatefulWidget {
  const PageFirst({super.key});

  @override
  State<PageFirst> createState() => PageFirstState();
}

class PageFirstState extends State<PageFirst> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      left: false,
      right: false,
      maintainBottomViewPadding: false,
      minimum: EdgeInsets.all(0.0),
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            // Скрываем клавиатуру при касании пустого места
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 200.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircularImageWidget(
                      imagePath: 'assets/main_icon.png',
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      'Ювенильный артрит',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 30,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                      child: Text(
                    'Дистанционный мониторинг',
                    style: TextStyle(
                        color: Colors.black45,
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  )),
                  SizedBox(
                    height: 60,
                  ),
                  Center(
                    child: ButtonWidget(
                      labelText: 'Войти',
                      listRoles: Roles.all,
                      onPressed: () {
                        Navigator.pop(context); // закрыли текущее окно
                        Navigator.pushNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
