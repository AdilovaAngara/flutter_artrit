import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import 'menu.dart';


class PageInfo extends StatefulWidget {
  final String title;

  const PageInfo({
    super.key,
    required this.title,
  });

  @override
  State<PageInfo> createState() => _PageInfoState();
}

class _PageInfoState extends State<PageInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.title,
      ),
      endDrawer: MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('Система дистанционного мониторинга и самоконтроля пациента с ювенильным артритом',
                        style: captionTextStyle),
                  ),
                  SizedBox(width: 10,),
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Image.asset(
                      'assets/main_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                ],
              ),
              SizedBox(height: 20,),
              Text('Система дистанционного мониторинга и самоконтроля пациента с ювенильным артритом разработана ведущими детскими ревматологами для активного участия пациента с ювенильным артритом и его семьи в процессе лечения заболевания.',
                  style: inputTextStyle),
              SizedBox(height: 10,),
              Text('Система включает приложение для мобильных устройств и его web-версию и может работать в режиме самоконтроля и в режиме дистанционного наблюдения.',
                  style: inputTextStyle),
              SizedBox(height: 10,),
              Text('Приложение для пациента позволяет следить за симптомами артрита, оценивать качество жизни, вносить результаты лабораторных и инструментальных исследований, вести дневник приема лекарственных препаратов.',
                  style: inputTextStyle),
              SizedBox(height: 10,),
              Text('В режиме самоконтроля вы можете сформировать наглядный отчет о состоянии здоровья вашего ребенка и показать его вашему лечащему врачу на приеме. Это поможет врачу быстрее принять решение о дальнейшем лечении.',
                  style: inputTextStyle),
              SizedBox(height: 10,),
              Text('При подключении к системе дистанционного наблюдения, ваш лечащий врач сможет получать информацию о состоянии здоровья вашего ребенка, а также отслеживать результаты анализов и регулярность лечения.',
                  style: inputTextStyle),
              SizedBox(height: 20,),

              RichText(
                softWrap: true,
                strutStyle: const StrutStyle(
                  height: 1.8, // Увеличивает высоту строки
                ),
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.info,
                        size: 21,
                        color: Colors.orange,
                      ),
                    ),
                    const TextSpan(
                        text: ' Внимание! Использование приложения не заменяет консультацию Вашего лечащего врача.',
                        style: captionTextStyle),
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Text('Важная информация:',
                style: captionTextStyle,),
              SizedBox(height: 15,),

              RichText(
                softWrap: true,
                strutStyle: const StrutStyle(
                  height: 1.8, // Увеличивает высоту строки
                ),
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.check_box,
                        size: 20,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const TextSpan(
                        text: ' Информация, содержащаяся в системе, не должна рассматриваться пользователями как замена консультации медицинского работника.',
                        style: inputTextStyle),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              RichText(
                softWrap: true,
                strutStyle: const StrutStyle(
                  height: 1.8, // Увеличивает высоту строки
                ),
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.check_box,
                        size: 20,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const TextSpan(
                        text: ' Приложение осуществляет техническую поддержку. При наличии отклонений в состоянии здоровья Пациенту следует обратиться на очную консультацию к врачу за получением медицинской помощи, прежде чем предпринимать или воздерживаться от тех или иных действий на основании информации, полученной из приложения.',
                        style: inputTextStyle),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              RichText(
                softWrap: true,
                strutStyle: const StrutStyle(
                  height: 1.8, // Увеличивает высоту строки
                ),
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.check_box,
                        size: 20,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const TextSpan(
                        text: ' При использовании приложения в режимах «Самоконтроль» и «Дистанционный мониторинг» НО АДР, разработчик приложения и медицинский работник не несут ответственности за здоровье пациента и принимаемые им решения на основании информации, полученной из приложения или иных источников.',
                        style: inputTextStyle),
                  ],
                ),
              ),
              SizedBox(height: 40,),
            ],
          ),
        ),
      ),
    );
  }
}