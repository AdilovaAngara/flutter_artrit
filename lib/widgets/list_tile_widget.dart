import 'package:flutter/material.dart';
import '../theme.dart';

class ListTileWidget extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final Widget? widgetSubtitle;
  final IconData? iconTrailing;
  final IconData? iconLeading;
  final double iconSize;
  final Color? colorIconTrailing;
  final Color? colorIconLeading;
  final double? shapeParam;
  final TextStyle textStyle;
  final double horizontalPadding;
  final int? maxLines;
  final VoidCallback onTap;
  final double padding;
  final Widget? widgetTrailing;

  const ListTileWidget({
    super.key,
    this.title,
    this.subtitle,
    this.widgetSubtitle,
    this.iconTrailing,
    this.iconLeading,
    this.iconSize = 30,
    this.colorIconTrailing,
    this.colorIconLeading,
    this.shapeParam,
    this.textStyle = captionMenuTextStyle,
    this.horizontalPadding = 15.0,
    this.maxLines,
    required this.onTap,
    this.padding = 10.0,
    this.widgetTrailing,
  });

  @override
  ListTileWidgetState createState() => ListTileWidgetState();
}

class ListTileWidgetState extends State<ListTileWidget> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.padding) ,
      child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding, vertical: 6.0),
            tileColor: Colors.white,
            trailing: widget.widgetTrailing ?? (widget.iconTrailing != null
                ? Icon(
              widget.iconTrailing!,
              color: widget.colorIconTrailing ?? Colors.grey,
              size: widget.iconSize,
            )
                : null),
            leading: widget.iconLeading != null
                ? Icon(
              widget.iconLeading!,
              color: widget.colorIconLeading ?? Colors.grey,
              size: widget.iconSize,
            )
                : null,
            title: widget.title != null
                ? Text(
              widget.title!,
              style: widget.textStyle,
            ) : null,
            subtitle: widget.subtitle != null
                ? Text(
              widget.subtitle!,
              maxLines: (widget.maxLines != null) ? widget.maxLines : null,
              style: subtitleTextStyle,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            )
                : (widget.widgetSubtitle != null) ? widget.widgetSubtitle! : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.shapeParam ?? 12.0),
              ),
            onTap: widget.onTap,
              //Navigator.pushNamed(context, widget.pageName!);
          ),
    );
  }
}
