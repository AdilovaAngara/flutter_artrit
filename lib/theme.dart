import 'package:flutter/material.dart';


/// У labelStyle и inputTextStyle всегда должен быть одинаковый размер шрифта
const TextStyle labelStyle = TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w400,);
const TextStyle inputTextStyle = TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400,);

const TextStyle inputLabelStyle = TextStyle(fontSize: 19, color: Colors.black54, fontWeight: FontWeight.w400,);
const TextStyle inputTextStyleRed = TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.w400,);
const TextStyle inputTextStyleWhite = TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600,);
const TextStyle textStyleMini = TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400,);
const TextStyle errorStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w400,);
const TextStyle textStyleGreen = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.green);
const TextStyle labelStyleError = TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w400,);
const TextStyle listLabelStyle = TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400,);
const TextStyle listLabelStylePurple = TextStyle(fontSize: 16, color: Colors.purple, fontWeight: FontWeight.w400,);
const TextStyle captionTextStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black87,);
const TextStyle captionMiniTextStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87,);
const TextStyle captionTextStyleRed = TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.red,);
const TextStyle captionMenuTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87,);
const TextStyle captionWhiteTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white,);
const TextStyle formHeaderStyle = TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w400,);
final Color redBtnColor = Colors.red.shade400;
const Color btnColor = Colors.deepPurpleAccent;
const Color mainColor = Colors.deepPurple;
const TextStyle subtitleTextStyle = TextStyle(fontSize: 15, color: Colors.black54);
const TextStyle subtitleBoldTextStyle = TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.bold,);
const TextStyle subtitleMiniTextStyle = TextStyle(fontSize: 14, color: Colors.black54);




const TextStyle hyperTextStyle = TextStyle(
color: Colors.blue,
fontSize: 16,
fontWeight: FontWeight.w400,
decoration: TextDecoration.underline,
decorationColor: Colors.blue,
);

const TextStyle chatMsgTextStyle = TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w400,);
const TextStyle chatTimeStyle = TextStyle(fontSize: 11, color: Colors.grey,);
const TextStyle chatNewMsgCountStyle = TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.w500,);
const TextStyle chatDateStyle = TextStyle(fontSize: 11, color: Colors.black87);

TextStyle btnTextStyle(Color textColor) {
  return TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600,);
}


EdgeInsets paddingForm = EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0);
EdgeInsets paddingFormAll = EdgeInsets.all(10.0);

EdgeInsets paddingListTile (int index) {
 return index == 0
 ? const EdgeInsets.symmetric(vertical: 10.0)
    : const EdgeInsets.only(bottom: 10.0);
}





class AppTheme {

  static ThemeData lightTheme = (
      ThemeData(
        // primaryTextTheme: TextTheme(
        //   bodyMedium: TextStyle(
        //     color: Colors.white,
        //     fontSize: 20,
        //       fontWeight: FontWeight.w600
        //   ),
        // ),
        // primaryColor: Colors.black,
        // primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey.shade100,
        // buttonTheme: ButtonThemeData(
        //   textTheme: ButtonTextTheme.accent,
        //   minWidth: 200.0,
        //   height: 50.0,
        //   buttonColor: Colors.blue, // Цвет фона
        //   disabledColor: Colors.grey, // Цвет, если кнопка отключена
        //   splashColor: Colors.lightBlueAccent, // Цвет всплеска
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(12.0), // Радиус границ
        // ),),
        // textButtonTheme: TextButtonThemeData(
        //     style: TextButton.styleFrom(
        //       textStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        //       padding: const EdgeInsets.symmetric(horizontal: 90.0, vertical: 12.0),
        //       minimumSize: Size.square(5),
        //       backgroundColor: Colors.blueAccent, // Фон кнопки
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(10.0),
        //       ),),
        // ),
        // listTileTheme: ListTileThemeData( /// Параметры стилей для ListTile
        //   titleAlignment: ListTileTitleAlignment.center, // Это можно не указывать, т.к. указан contentPadding
        //   contentPadding: EdgeInsets.all(5.0),
        //   textColor: Colors.black,
        //   titleTextStyle: TextStyle(fontSize: 20),
        //   iconColor: Colors.blue,
        //   tileColor: Colors.white,
        //   selectedColor: Colors.orange, // Цвет текста для выделенных пунктов (когда selected: true).
        //   selectedTileColor: Colors.blue,
        //   style: ListTileStyle.list,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //  ),
        // dividerColor: Colors.white, // Цвет разделителя в ListView
        // dividerTheme: DividerThemeData(
        //   color: Colors.blue, // Цвет линии
        //   thickness: 1, // Толщина линии
        //   space: 20, // Отступы вокруг линии т.е. Пространство (отступы) вокруг разделителя
        //   indent: 5, // Отступ слева
        //   endIndent: 5, // Отступ справа
        // ),
        // textTheme: TextTheme(
        //     headlineMedium: TextStyle( // для заголовков
        //       fontWeight: FontWeight.w400,
        //       fontFamily: 'Arial',
        //       color: Colors.black,
        //       fontSize: 22,
        //     ),
        //     //bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
        //     bodyMedium: TextStyle( // для title
        //       fontWeight: FontWeight.w400,
        //       fontFamily: 'Arial',
        //       color: Colors.black,
        //       fontSize: 20,
        //     ),
        //     labelSmall: TextStyle( // для subtitle
        //       fontStyle: FontStyle.italic,
        //       fontFamily: 'Arial',
        //       color: Colors.blueGrey,
        //       fontSize: 18,
        //     )
        // ),
      )
  );

}
