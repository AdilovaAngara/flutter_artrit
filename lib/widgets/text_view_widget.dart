import 'package:flutter/material.dart';
import '../theme.dart';

class TextViewWidget extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextStyle style;

  const TextViewWidget({
    super.key,
    required this.text,
    this.maxLines = 2,
    this.style = subtitleMiniTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      maxLines: maxLines, // Ограничение до двух строк
      overflow: TextOverflow.ellipsis, // Троеточие в конце maxLines строки, если текст не влезает
      softWrap: true, // Включаем автоматический перенос слов
    );
  }
}




class TextScrollViewWidget extends StatelessWidget {
  final String? text;
  final int? maxLines;

  const TextScrollViewWidget({
    super.key,
    required this.text,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        child: Text(
          text ?? '',
          style: subtitleMiniTextStyle,
          maxLines: maxLines,
          overflow: TextOverflow.visible,
          softWrap: true, // Включаем автоматический перенос слов
        ),
      ),
    );
  }
}



