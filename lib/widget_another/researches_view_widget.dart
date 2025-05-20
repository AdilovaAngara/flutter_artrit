import 'package:flutter/material.dart';
import '../file_methods.dart';
import '../roles.dart';
import '../theme.dart';
import '../widgets/button_widget.dart';
import '../widgets/download_file_widget.dart';
import '../widgets/file_view_widget.dart';
import 'label_join_widget.dart';


class ResearchesViewWidget extends StatefulWidget {
  final String? fileName;
  final String? fileId;
  final String? comment;

  const ResearchesViewWidget({
    super.key,
    required this.fileName,
    required this.fileId,
    required this.comment,
  });

  @override
  State<ResearchesViewWidget> createState() => _ResearchesViewWidgetState();
}

class _ResearchesViewWidgetState extends State<ResearchesViewWidget> {
  @override
  Widget build(BuildContext context) {
    String fileName = widget.fileName ?? '';
    String? fileId = widget.fileId;
    String? comment = widget.comment ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LabelJoinWidget(
          labelText: 'Файл',
          value: fileName,
        ),
        if (fileName.isNotEmpty && fileId != null && fileId.isNotEmpty)
          Column(
            children: [
              Container(
                height: 2,
                color: Colors.grey.shade300,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Spacer(),
                  if (fileName.isNotEmpty && FileMethods.isAvailableViewIcon(fileName))
                    ButtonWidget(
                      labelText: '',
                      icon: Icons.visibility,
                      iconColor: mainColor.withAlpha(150),
                      iconSize: 30,
                      onlyText: true,
                      listRoles: Roles.all,
                      onPressed: () {
                        FileViewWidget.show(context,
                            fileName: fileName,
                            fileId: fileId,
                            isLocal: false,
                            isChatFiles: false
                        );
                      },
                    ),
                  ButtonWidget(
                    labelText: '',
                    icon: Icons.download,
                    iconColor: mainColor.withAlpha(150),
                    iconSize: 30,
                    onlyText: true,
                    listRoles: Roles.all,
                    onPressed: () {
                      downloadFile(
                        fileName: fileName,
                        fileId: fileId,
                        context: context,
                        isChatFiles: false,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        LabelJoinWidget(
          labelText: 'Комментарий',
          value: comment,
        ),
      ],
    );
  }
}
