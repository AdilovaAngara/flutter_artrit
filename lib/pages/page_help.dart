import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import 'menu.dart';

class PageHelp extends StatefulWidget {
  final String title;

  const PageHelp({
    super.key,
    required this.title,
  });

  @override
  State<PageHelp> createState() => _PageHelpState();
}

class _PageHelpState extends State<PageHelp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.title,
      ),
      endDrawer: MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Служба поддержки:',
              style: captionTextStyle,),
            SizedBox(height: 15),
            Text('8(495)627-29-61 (будни 09:00-18:00)',
                style: inputTextStyle),
            SizedBox(height: 8),
            Text('it@aspirre-russia.ru',
                style: inputTextStyle),
          ],
        ),
      ),
    );
  }
}