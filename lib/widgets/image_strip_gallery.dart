import 'dart:io';
import 'package:flutter/material.dart';
import '../api/api_inspections_photo.dart';
import '../api/api_send_file.dart';
import '../data/data_inspections_photo.dart';
import '../data/data_send_file.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import 'button_widget.dart';
import 'file_picker_widget.dart';
import 'future_builder_image.dart';
import 'image_gallery.dart';
import 'input_text.dart';

class ImageStripGallery extends StatefulWidget {
  final String inspectionsId;
  final String? jointsId;
  final String bodyType;
  final bool addPhotoEnabled;
  final String addPhotoEnabledText;
  final bool addPhotoBtnShow;
  final VoidCallback? onDataUpdated;
  final bool viewRegime;

  const ImageStripGallery({
    super.key,
    required this.inspectionsId,
    required this.jointsId,
    required this.bodyType,
    this.addPhotoEnabled = true,
    this.addPhotoEnabledText = 'Добавление фотографий недоступно.',
    this.addPhotoBtnShow = true,
    this.onDataUpdated,
    required this.viewRegime,
  });

  @override
  State<ImageStripGallery> createState() => _ImageStripGalleryState();
}

class _ImageStripGalleryState extends State<ImageStripGallery> {
  late Future<void> _future;
  /// API
  final ApiInspectionsPhoto _apiPhoto = ApiInspectionsPhoto();
  final ApiSendFile _apiSendFile = ApiSendFile();

  /// Данные
  List<DataInspectionsPhoto>? _thisData;
  List<DataInspectionsPhoto>? _thisDataForJoint;

  /// Параметры
  late List<String> _listImages;
  late int _role;
  late String _patientsId;
  late String _inspectionsId;
  File? _pickedImage;
  String? _comments;
  bool _isLoading = false; // Флаг загрузки

  /// Ключи
  final Map<Enum, GlobalKey<FormFieldState>>
  _keys = {
    for (var e in Enum.values) e: GlobalKey<FormFieldState>(),
  };

  @override
  void initState() {
    _inspectionsId = widget.inspectionsId;
    _future = _loadData();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ImageStripGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.jointsId != oldWidget.jointsId || widget.inspectionsId != oldWidget.inspectionsId) {
      setState(() {
        _future = _loadData();
      });
    }
  }


  Future<void> _loadData() async {
    _role = await getUserRole();
    _patientsId = await readSecureData(SecureKey.patientsId);
    final thisData = await _apiPhoto.get(
      patientsId: _patientsId,
      bodyType: widget.bodyType,
      inspectionsId: _inspectionsId,
    );
    _thisData = thisData;
    _photoFilter();
  }



  void _photoFilter() {
    setState(() {
      _thisDataForJoint = widget.jointsId != null
          ? _thisData?.where((e) => e.jointsId == widget.jointsId).toList()
          : _thisData;
      _listImages = _thisDataForJoint?.map((e) => e.id).toList() ?? [];
      debugPrint(_listImages.join(', '));
    });
  }


  Future<bool> _saveData() async {
    if (_pickedImage == null) return false;
    await _post();
    widget.onDataUpdated?.call(); // ✅ Вызываем колбэк, если он передан
    return true;
  }



  Future<void> _post() async {
    if (_pickedImage != null) {
      DataSendFile dataSendFile = await _apiSendFile.sendFile(path: _pickedImage!.path);
      String id = dataSendFile.id;

      DataInspectionsPhoto thisData = DataInspectionsPhoto(
        id: id,
        patientsId: _patientsId,
        inspectionId: widget.inspectionsId,
        jointsId: widget.jointsId!,
        date: convertToTimestamp(dateTimeFormat(getMoscowDateTime())),
        comments: _comments ?? '',
        creationDate: convertToTimestamp(dateTimeFormat(getMoscowDateTime())),
      );

      await _apiPhoto.post(patientsId: _patientsId, thisData: thisData);
    }
  }


  bool _delBtnShow(List<DataInspectionsPhoto> thisData, int index) {
    String? date = dateTimeFormat(getMoscowDateTime());
    if (thisData[index].creationDate != null) {
      date = convertTimestampToDateTime(thisData[index].creationDate!);
    }
    return delBtnShowCalculate(date);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return errorDataWidget(snapshot.error);
          }
          /// Лента миниатюр в нижней части экрана
          return SizedBox(
            height: 100,
            child: Row(
              children: [
                if (widget.addPhotoBtnShow) _buildCameraButton(),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ValueListenableBuilder<int>(
                      valueListenable: ValueNotifier<int>(0),
                      builder: (context, selectedIndex, _) {
                        return Row(
                          children: List.generate(_listImages.length, (index) {
                            return _buildThumbnail(index, selectedIndex);
                          }),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }




  Widget _buildThumbnail(int index, int selectedIndex) {
    final imageId = _listImages[index];
    return GestureDetector(
      onTap: () {
        // Открытие ImageGallery при клике
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageGallery(
              thisData: _thisDataForJoint,
              currentIndex: index,
              isSwipeEnabled: false,
              isAddEnabled: widget.addPhotoEnabled,
              isDeleteEnabled: _delBtnShow(_thisData!, index),
              viewRegime: widget.viewRegime,
              onDataUpdated: () {
                widget.onDataUpdated?.call(); // ✅ Вызываем колбэк, если он передан
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color:selectedIndex == index
                ? Colors.blueAccent : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: FutureBuilderImage(
          imageId: imageId,
          isFullSize: false,
          isChatFiles: false,
        ),
      ),
    );
  }

  // Кнопка камеры в ленте миниатюр, закрепленная
  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: (){
        if (widget.addPhotoEnabled && _listImages.length < 3) {
          FilePickerWidget(
            onFileUploaded: (files) {
              if (files.isNotEmpty) {
                setState(() {
                  _pickedImage = files.first.file;
                });
                _showSavePhotoForm();
              }
            },
            isDocument: false,
            onlyOneFile: true,
            onLoadingChanged: (value) {
              setState(() {
                _isLoading = value;
              });
            },
          ).showPicker(context);
        } else {
          _showImagePickerDialog();
        }
      },
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black38, width: 2),
        ),
        child: const Icon(Icons.camera_alt, size: 40, color: Colors.black54),
      ),
    );
  }





  void _showSavePhotoForm() {
    showDialog(
      context: context,
      barrierDismissible: false, // Диалог не закроется при клике вне его
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext dialogContext, StateSetter setState) {
              return AlertDialog(
                title: Text('Сохранить изображение', style: formHeaderStyle,),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_pickedImage != null)
                        Image.file(_pickedImage!, height: 350, width: 350, fit: BoxFit.fitHeight),
                      SizedBox(height: 10),
                      InputText(
                        labelText: 'Комментарий',
                        fieldKey: _keys[
                        Enum.comments]!,
                        value: '',
                        required: false,
                        maxLength: 200,
                        listRoles: Roles.asPatient,
                        role: _role,
                        onChanged: (value) {
                          _comments = value;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  ButtonWidget(
                    labelText: 'Отмена',
                    onlyText: true,
                    dialogForm: true,
                    listRoles: Roles.asPatient,
                    role: _role,
                    onPressed: () {
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  SizedBox(width:  10.0),
                  ButtonWidget(
                    labelText: 'Сохранить',
                    onlyText: true,
                    dialogForm: true,
                    showProgressIndicator: _isLoading,
                    listRoles: Roles.asPatient,
                    role: _role,
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      // Ждем перерисовки UI перед началом длительной операции
                      await Future.delayed(Duration.zero);

                      // Выполняем сохранение
                      final success = await _saveData();

                      if (dialogContext.mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                        if (success) {
                          Navigator.of(dialogContext).pop();
                        }
                      }
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }




  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          const Padding(padding: EdgeInsets.all(5.0)),
          if (!widget.addPhotoEnabled)
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(widget.addPhotoEnabledText),
              onTap: () async {
                Navigator.pop(context);
              },
            ),
          if (widget.addPhotoEnabled && _listImages.length == 3)
            ListTile(
              leading: const Icon(Icons.info),
              title: Text('Больше трех фотографий на один ${(widget.bodyType == 'skin') ? 'участок тела' : 'сустав' } добавлять нельзя!'),
              onTap: () async {
                Navigator.pop(context);
              },
            ),
          const Padding(padding: EdgeInsets.all(10.0)),
        ],
      ),
    );
  }



}
