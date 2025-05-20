import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../roles.dart';
import '../theme.dart';
import '../widgets/button_widget.dart';


class ChatPolitic extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool showAgreeBtn;

  const ChatPolitic({
    super.key,
    required this.onConfirm,
    required this.showAgreeBtn,
  });



  @override
  Widget build(BuildContext context) {
    const icon = Icon(
      FontAwesomeIcons.squareCheck,
      size: 18,
      color: Colors.deepPurpleAccent,
    );

    const policyItems = [
      'НО АДР не является поставщиком медицинских услуг.',
      'Приложение «Ювенильный артрит» осуществляет техническую поддержку. При наличии отклонений в состоянии здоровья Врач обязан отправить уведомление о необходимости обратиться на очную консультацию к врачу за получением медицинской помощи.',
      'При использовании приложения в функционале «Дистанционный мониторинг» НО АДР, разработчик приложения и медицинский работник не несут ответственности за здоровье пациента и принимаемые им решения на основании информации, полученной из приложения или иных источников.',
      'При использовании приложения в функционале «Дистанционный мониторинг» Врач вправе принять участие в организации маршрутизации пациента для оказания качественной медицинской помощи.',
      'НО АДР и разработчик приложения предлагают использовать алгоритм маршрутизации, предусмотренный действующими Клиническими рекомендациями по ведению пациентов с соответствующими заболеваниями.',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showAgreeBtn)...[
                    SizedBox(height: 20,),
                    Text(
                      'Ознакомьтесь, пожалуйста, с политикой чата:',
                      style: captionTextStyle,
                    ),
                  ],

                  const SizedBox(height: 20),
                  ...policyItems.map((text) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RichText(
                      softWrap: true,
                      strutStyle: const StrutStyle(height: 1.8),
                      text: TextSpan(
                        children: [
                          WidgetSpan(child: icon),
                          TextSpan(text: '  $text', style: inputTextStyle),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          if (showAgreeBtn)
          Container(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: ButtonWidget(
                labelText: 'Я принимаю условия чата',
                listRoles: Roles.all,
                onPressed: () {
                  onConfirm();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Вызов диалога
  static void showInWindow({
    required BuildContext context,
    required VoidCallback onConfirm,
    required showAgreeBtn,
    String title = 'Политика чата',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title, style: formHeaderStyle),
          content: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: ChatPolitic(
            onConfirm: () async {
              onConfirm();
            },
            showAgreeBtn: showAgreeBtn,
          ),
        ),
          actions: [
            ButtonWidget(
              labelText: 'Закрыть',
              onlyText: true,
              dialogForm: true,
              listRoles: Roles.all,
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Закрываем диалог
              },
            ),
          ],
        );
      },
    );
  }

}
