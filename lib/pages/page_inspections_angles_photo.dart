import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_inspections_photo.dart';
import '../data/data_inspections_photo.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/future_builder_image.dart';
import '../widgets/image_gallery.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_text.dart';
import '../widgets/show_dialog_delete.dart';
import '../widgets/show_message.dart';
import 'page_inspections_angles_photo_add.dart';

class PageInspectionsAnglesPhoto extends StatefulWidget {
  final String cornersTitle;
  final String jointsId;
  final String inspectionsId;

  const PageInspectionsAnglesPhoto({
    super.key,
    required this.cornersTitle,
    required this.jointsId,
    required this.inspectionsId,
  });

  @override
  State<PageInspectionsAnglesPhoto> createState() =>
      PageInspectionsAnglesPhotoState();
}

class PageInspectionsAnglesPhotoState
    extends State<PageInspectionsAnglesPhoto> {
  late Future<void> _future;

  /// API
  final ApiInspectionsPhoto _api = ApiInspectionsPhoto();

  /// Данные
  List<DataInspectionsPhoto>? _thisData;

  /// Параметры
  bool _isLoading = false; // Флаг загрузки
  late int _role;
  late String _patientsId;
  late String _inspectionsId;
  final String _bodyType = 'angles';

  /// Ключи
  final _formKey = GlobalKey<FormState>();
  final _formDialogKey = GlobalKey<FormState>();
  final Map<Enum, GlobalKey<FormFieldState>> _keys = {
    for (var e in Enum.values) e: GlobalKey<FormFieldState>(),
  };

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }


  Future<void> _loadData() async {
    _role = await getUserRole();
    _patientsId = await readSecureData(SecureKey.patientsId);
    _inspectionsId = widget.inspectionsId;

    final thisData = await _api.get(
        patientsId: _patientsId,
        bodyType: _bodyType,
        inspectionsId: _inspectionsId);

    setState(() {
      _thisData = thisData.where((e) => e.jointsId == widget.jointsId).toList();
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }


  void _navigateAndRefresh(BuildContext context, File pickedImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageInspectionsAnglesPhotoAdd(
            photo: pickedImage,
            jointsId: widget.jointsId,
            inspectionsId: widget.inspectionsId,
            role: _role),
      ),
    ).then((_) async {
      await _refreshData();
    });
}



  Future<bool> _saveData(int index, String comments,
      int angle1, int? angle2) async {
    if (!_formDialogKey.currentState!.validate()) {
      ShowMessage.show(context: context);
      return false;
    }
    await _put(index, comments, angle1, angle2);
    await _refreshData();
    return true;
  }

  Future<void> _put(int index, String comments, int angle1, int? angle2) async {
    DataInspectionsPhoto thisData = DataInspectionsPhoto(
      id: _thisData![index].id,
      patientsId: _thisData![index].patientsId,
      jointsId: _thisData![index].jointsId,
      date: _thisData![index].date,
      comments: comments,
      angle1: angle1,
      angle2: angle2,
      inspectionId: widget.inspectionsId,
      creationDate: _thisData![index].creationDate,
      filedate: _thisData![index].filedate,
      filename: _thisData![index].filename,
      filetype: _thisData![index].filetype,
      filesize: _thisData![index].filesize,
    );
    _api.put(
        patientsId: _patientsId,
        recordId: _thisData![index].id,
        thisData: thisData);
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false, // Диалог не закроется при клике вне его
      builder: (BuildContext context) {
        return ShowDialogDelete(
          onConfirm: () async {
            // Сделать асинхронным
            String recordId = _thisData![index].id;
            await _api.delete(
                patientsId: _patientsId,
                recordId: recordId); // Дождаться удаления
            await _refreshData();
            setState(() {
            });
          },
        );
      },
    );
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
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.cornersTitle,
        showMenu: false,
        showChat: false,
        showNotifications: false,
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return errorDataWidget(snapshot.error);
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: paddingForm,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.topRight,
                            color: Colors.grey.shade100,
                            child: ButtonWidget(
                              labelText: 'Добавить',
                              icon: Icons.camera_alt,
                              onlyText: true,
                              listRoles: Roles.asPatient,
                              role: _role,
                              onPressed: () async {
                                File? pickedImage =
                                    await pickImage(ImageSource.camera);
                                if (pickedImage != null) {
                                  _navigateAndRefresh(context, pickedImage);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: (_thisData == null || _thisData!.isEmpty)
                          ? notDataWidget
                          : ListView.builder(
                        itemCount: _thisData!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: ListTile(
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    child: SizedBox(
                                      height: 130,
                                      width: 100,
                                      child: FutureBuilderImage(
                                        imageId: _thisData![index].id,
                                        isFullSize: false,
                                        isChatFiles: false,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageGallery(
                                            thisData: _thisData!,
                                            currentIndex: index,
                                            isSwipeEnabled: true,
                                            isAddEnabled: false,
                                            isDeleteEnabled:
                                            _delBtnShow(_thisData!, index),
                                            viewRegime: false,
                                            onDataUpdated: () async {
                                              await _refreshData();
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    width: 15
                                  ),
                                  buildForm(index),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildForm(int index) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RichText(
                maxLines: 2,
                softWrap: true,
                text: TextSpan(
                  children: [
                    const TextSpan(
                        text: 'Дата:  ',
                        style: labelStyle),
                    TextSpan(
                      text: convertTimestampToDateTime(
                          _thisData![index].creationDate ??
                              convertToTimestamp(
                                  dateTimeFormat(getMoscowDateTime()))) ??
                          '',
                      style: inputTextStyle,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4,),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                        text: 'Угол 1:  ',
                        style: labelStyle),
                    TextSpan(
                      text: '${_thisData![index].angle1}',
                      style: inputTextStyle,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4,),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                        text: 'Угол 2:  ',
                        style: labelStyle),
                    TextSpan(
                      text: '${_thisData![index].angle2 ?? ' - '}',
                      style: inputTextStyle,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4,),
              RichText(
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    const TextSpan(
                        text: 'Комментарий:  ',
                        style: labelStyle),
                    TextSpan(
                      text: _thisData![index].comments,
                      style: inputTextStyle,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Spacer(),
                  if (_delBtnShow(_thisData!, index))
                    ButtonWidget(
                      labelText: '',
                      icon: Icons.delete,
                      iconColor: redBtnColor,
                      iconSize: 25,
                      onlyText: true,
                      listRoles: Roles.asPatient,
                      role: _role,
                      onPressed: () {
                        _showDeleteDialog(index);
                      },
                    ),
                  ButtonWidget(
                    labelText: '',
                    icon: Icons.edit,
                    iconSize: 25,
                    onlyText: true,
                    listRoles: Roles.asPatient,
                    role: _role,
                    onPressed: () {
                      _showEditRecDialog(index);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditRecDialog(int index) {
    int angle1 = _thisData![index].angle1!;
    int? angle2 = _thisData![index].angle2;
    String comments = _thisData![index].comments;

    showDialog(
        context: context,
        barrierDismissible: false, // Диалог не закроется при клике вне его
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext dialogContext, StateSetter setDialogState) {
            return Form(
              key: _formDialogKey,
              child: AlertDialog(
                title: Text(getFormTitle(true), style: formHeaderStyle),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // Чтобы высота AlertDialog зависела от содержимого окна, а не занимала всю высоту экрана
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 350,
                          width: 350,
                          child: FutureBuilderImage(
                            imageId: _thisData![index].id,
                            isFullSize: false,
                            isChatFiles: false,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      InputText(
                        labelText: 'Угол 1',
                        fieldKey: _keys[Enum.angle1]!,
                        value: angle1,
                        required: true,
                        keyboardType: TextInputType.number,
                        min: 0,
                        max: 360,
                        listRoles: Roles.asPatient,
                        role: _role,
                        onChanged: (value) {
                          angle1 = int.tryParse(value) ?? 0;
                        },
                      ),
                      InputText(
                        labelText: 'Угол 2',
                        fieldKey: _keys[Enum.angle2]!,
                        value: angle2,
                        required: false,
                        keyboardType: TextInputType.number,
                        min: 0,
                        max: 360,
                        listRoles: Roles.asPatient,
                        role: _role,
                        onChanged: (value) {
                          angle2 = int.tryParse(value);
                        },
                      ),
                      InputText(
                        labelText: 'Комментарий',
                        fieldKey: _keys[Enum.comments]!,
                        value: comments,
                        required: false,
                        maxLength: 200,
                        listRoles: Roles.asPatient,
                        role: _role,
                        onChanged: (value) {
                          comments = value;
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
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 10),
                  ButtonWidget(
                    labelText: 'Сохранить',
                    onlyText: true,
                    dialogForm: true,
                    showProgressIndicator: _isLoading,
                    listRoles: Roles.asPatient,
                    role: _role,
                    onPressed: () async {
                      setDialogState(() {
                        _isLoading = true; // Обновляем состояние внутри диалога
                      });
                      bool success = await _saveData(index, comments, angle1, angle2);
                      if (success && context.mounted) {
                        await Future.delayed(Duration(microseconds: 10));
                        Navigator.pop(dialogContext);
                      }
                      if (context.mounted) {
                        setDialogState(() {
                          _isLoading = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            );
          });
        });
  }
}
