import 'package:flutter/material.dart';
import '../theme.dart';

class ListTileColorWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String imagePath;
  final Color colorBorder;
  final double? shapeParam;
  final VoidCallback onPressed;

  const ListTileColorWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.imagePath,
    this.colorBorder = Colors.grey,
    this.shapeParam,
    required this.onPressed,
  });

  @override
  ListTileColorWidgetState createState() => ListTileColorWidgetState();
}

class ListTileColorWidgetState extends State<ListTileColorWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: widget.colorBorder,
          border: Border.all(
            color: widget.colorBorder, // Цвет рамки
            width: 1.0, // Ширина рамки
          ),
          borderRadius: BorderRadius.circular(widget.shapeParam ?? 12.0), // Скругление углов
        ),
        padding: EdgeInsets.all(1.0), // Отступы внутри контейнера
        child: Row(
          children: [
            Expanded(
              child: Material( // Добавляем Material для корректного отображения цвета
                color: Colors.white, // Указываем белый цвет явно
                borderRadius: BorderRadius.circular(widget.shapeParam ?? 12.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  tileColor: Colors.white, // Это уже не обязательно, но можно оставить
                  trailing: Icon(
                    Icons.navigate_next,
                    color: Colors.grey,
                    size: 25,
                  ),
                  title: Text(
                    widget.title,
                    style: inputTextStyle,
                  ),
                  subtitle: widget.subtitle != null
                      ? Text(
                    widget.subtitle!,
                    style: subtitleTextStyle,
                  ) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.shapeParam ?? 12.0),
                  ),
                  onTap: widget.onPressed,
                ),
              ),
            ),
            SizedBox(width: 10),
            Image.asset(
              widget.imagePath,
              width: 40,
              height: 40,
              color: Colors.white,
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}


