import 'package:artrit/file_methods.dart';
import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../theme.dart';
import 'button_widget.dart';
import 'download_file_widget.dart';
import 'file_picker_widget.dart';
import 'file_view_widget.dart';

class InputFile extends StatefulWidget {
  final String labelText;
  final GlobalKey<FormFieldState> fieldKey;
  final String? fileName;
  final String? fileId;
  final bool required;
  final bool readOnly;
  final bool showUploadIcon;
  final Function(FileItems?) onFileUploaded; // Колбэк с id загруженного файла
  final int? role;
  final List<int>? listRoles;

  const InputFile({
    super.key,
    required this.labelText,
    required this.fieldKey,
    this.fileName,
    this.fileId,
    this.required = false,
    this.readOnly = false,
    this.showUploadIcon = true,
    required this.onFileUploaded,
    this.role,
    required this.listRoles,
  });

  @override
  InputFileState createState() => InputFileState();
}

class InputFileState extends State<InputFile> {
  final TextEditingController _controller = TextEditingController();
  String? _fileName;
  String? _fileId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fileName = widget.fileName;
    _fileId = widget.fileId;
    _controller.text = _fileName ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: (widget.listRoles == Roles.all ||
              widget.listRoles!.contains(widget.role)) &&
              !widget.readOnly
              ? TextFormField(
            key: widget.fieldKey,
            controller: _controller,
            readOnly: true,
            decoration: InputDecoration(
              labelText: widget.required ? '${widget.labelText}*' : widget.labelText,
              labelStyle: inputLabelStyle,
              errorStyle: errorStyle,
              border: const UnderlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: _isLoading
                  ? showProgressIndicator(size: 10.0)
                  : widget.showUploadIcon
                  ? IconButton(
                icon: Icon(
                  Icons.upload_file,
                  color: mainColor.withAlpha(150),
                  size: 30,
                ),
                onPressed: () {
                  FilePickerWidget(
                    onFileUploaded: (files) {
                      if (files.isNotEmpty) {
                        setState(() {
                          _fileName = files.first.fileName;
                          _fileId = null; // Если сервер вернёт ID, обновите здесь
                          _controller.text = _fileName ?? '';
                        });
                        widget.onFileUploaded(files.first);
                      }
                    },
                    onLoadingChanged: (value) {
                      setState(() {
                        _isLoading = value;
                      });
                    },
                  ).showPicker(context);
                },
              )
                  : null,
            ),
            style: inputTextStyle,
            minLines: 1,
            maxLines: 5,
            validator: (value) {
              if (widget.required && (value == null || value.isEmpty)) {
                return 'Пожалуйста, загрузите файл';
              }
              return null;
            },
          ) : RichText(
            maxLines: 50,
            softWrap: true,
            strutStyle: const StrutStyle(
              height: 0.1, // Увеличивает высоту строки
              leading: 1.5, // Добавляет доп. пространство перед строкой
            ),
            text: TextSpan(
              children: [
                TextSpan(text: '${widget.labelText}:  ', style: labelStyle),
                TextSpan(
                  text: widget.fileName?.toString() ?? '',
                  style: inputTextStyle,
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_fileId != null && _fileId!.isNotEmpty && _fileName != null && _fileName!.isNotEmpty
                && FileMethods.isAvailableViewIcon(_fileName!))
              ButtonWidget(
                labelText: '',
                icon: Icons.visibility,
                iconColor: mainColor.withAlpha(150),
                iconSize: 30,
                onlyText: true,
                listRoles: Roles.all,
                onPressed: () {
                  FileViewWidget.show(context,
                      fileName: _fileName,
                      fileId: _fileId,
                      isLocal: false,
                      isChatFiles: false
                  );
                },
              ),
            if (_fileId != null && _fileId!.isNotEmpty && _fileName != null && _fileName!.isNotEmpty)
              ButtonWidget(
                labelText: '',
                icon: Icons.download,
                iconColor: mainColor.withAlpha(150),
                iconSize: 30,
                onlyText: true,
                listRoles: Roles.all,
                onPressed: () {
                  downloadFile(
                    fileName: _fileName!,
                    fileId: _fileId!,
                    context: context,
                    isChatFiles: false,
                  );
                },
              ),
          ],
        ),
        if (_fileId == null) SizedBox(height: 15),
      ],
    );
  }
}
