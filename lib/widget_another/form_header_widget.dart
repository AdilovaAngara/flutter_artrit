import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class FormHeaderWidget extends StatelessWidget {
  final String title;
  final bool isUpperCase;

  const FormHeaderWidget({
    super.key,
    required this.title,
    this.isUpperCase = true
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 10),
                //color: mainColor.withAlpha(100),
                decoration: BoxDecoration(
                  // border: Border.all(
                  //   color: mainColor.withAlpha(100),
                  //   width: 2.0,
                  // ),
                  // border: Border.all(
                  //   color: Colors.transparent,
                  //   width: 2.0,
                  //
                  // ),
                  // gradient: LinearGradient(
                  //   colors: [Colors.deepPurple.shade300, Colors.indigo.shade200],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.purple.shade300,
                  //     spreadRadius: 50,
                  //     blurRadius: 50,
                  //     offset: Offset(-10, -40),
                  //   ),
                  //   BoxShadow(
                  //     color: Colors.deepPurple.shade300.withAlpha(200),
                  //     spreadRadius: 50,
                  //     blurRadius: 50,
                  //     offset: Offset(-10, -30),
                  //   ),
                  // ],
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: AutoSizeText(
                  isUpperCase ? title.toUpperCase() : title,
                  maxLines: 1,
                  minFontSize: 8,
                  // Минимальный размер шрифта
                  maxFontSize: 18,
                  // Максимальный размер шрифта
                  overflow: TextOverflow.ellipsis,
                  style: captionMenuTextStyle,
                ),
              ),
            ),
            //Spacer(),
          ],
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
//               color: mainColor.withAlpha(100),
//               child: AutoSizeText(
//                 title,
//                 maxLines: 1,
//                 minFontSize: 8, // Минимальный размер шрифта
//                 maxFontSize: 18, // Максимальный размер шрифта
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white,),
//               ),
//             ),
//             //Spacer(),
//           ],
//         ),
//         SizedBox(height: 10.0,),
//       ],
//     );
//   }
// }

// @override
// Widget build(BuildContext context) {
//   return Column(
//     children: [
//       Container(
//         padding: EdgeInsets.all(3.0),
//         color: mainColor.withAlpha(100),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             AutoSizeText(
//               title,
//               maxLines: 1,
//               minFontSize: 8, // Минимальный размер шрифта
//               maxFontSize: 18, // Максимальный размер шрифта
//               overflow: TextOverflow.ellipsis,
//               style: captionWhiteTextStyle,
//             ),
//           ],
//         ),
//       ),
//       SizedBox(height: 10,),
//     ],
//   );
// }
// }
