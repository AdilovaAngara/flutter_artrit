import 'package:artrit/widgets/input_text.dart';
import 'package:artrit/widgets/show_dialog_delete.dart';
import 'package:artrit/widgets/text_view_widget.dart';
import 'package:flutter/material.dart';
import '../api/api_inspections_photo.dart';
import '../data/data_inspections_photo.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import 'package:artrit/widgets/button_widget.dart';
import 'download_file_widget.dart';
import 'future_builder_image.dart';
import 'list_tile_widget.dart';

class ImageGallery extends StatefulWidget {
  final List<DataInspectionsPhoto>? thisData;
  final int currentIndex;
  final bool isSwipeEnabled; // Возможность листать фотографии
  final bool isAddEnabled;
  final bool isDeleteEnabled;
  final VoidCallback? onDataUpdated;
  final bool viewRegime;

  const ImageGallery({
    super.key,
    required this.thisData,
    required this.currentIndex,
    this.isSwipeEnabled = true, // По умолчанию включено
    this.isAddEnabled = true,
    this.isDeleteEnabled = true,
    this.onDataUpdated,
    required this.viewRegime,
  });

  @override
  ImageGalleryState createState() => ImageGalleryState();
}

class ImageGalleryState extends State<ImageGallery> {
  late Future<void> _future;

  /// API
  final ApiInspectionsPhoto _api = ApiInspectionsPhoto();

  /// Параметры
  late int _role;
  late String _patientsId;
  late String _recordId;
  late List<String> _listImages;
  late final PageController _pageController;
  late final ValueNotifier<int> _selectedIndex;
  late String? _comments;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
    _selectedIndex = ValueNotifier<int>(widget.currentIndex);
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    _patientsId = await readSecureData(SecureKey.patientsId);
    setState(() {
      if (widget.thisData != null && widget.thisData!.isNotEmpty) {
        _listImages = widget.thisData!.map((e) => e.id).toList();
        _recordId = widget.thisData![_selectedIndex.value].id;
        _comments = widget.thisData![_selectedIndex.value].comments;
      }
    });
  }

  Future<void> _refreshData() async {
    _future = _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }


  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false, // Диалог не закроется при клике вне его
      builder: (BuildContext context) {
        return ShowDialogDelete(
          onConfirm: () async {
            String recordId = _listImages[index];

            if (mounted) {
              setState(() {
                String recordId = _listImages[index];
                // ❌ Удаляем из списка изображений
                _listImages.removeAt(index);
                // ❌ Удаляем из основного списка данных
                widget.thisData!.removeWhere((item) => item.id == recordId);

                if (_listImages.isEmpty) {
                  Navigator.pop(context);
                } else {
                  int newIndex = (index > 0) ? index - 1 : 0;
                  _selectedIndex.value = newIndex;
                  _pageController.jumpToPage(newIndex);
                  _comments = widget.thisData![newIndex].comments;
                }
              });
            }
            await _api.delete(patientsId: _patientsId, recordId: recordId);
            widget.onDataUpdated?.call(); // ✅ Вызываем колбэк, если он передан
            _refreshData();
          },
        );
      },
    );
  }

  void _saveData(int index) async {
    _recordId = widget.thisData![index].id;

    DataInspectionsPhoto thisData = DataInspectionsPhoto(
      id: _recordId,
      patientsId: _patientsId,
      inspectionId: widget.thisData![index].inspectionId!,
      jointsId: widget.thisData![index].jointsId,
      angle1: widget.thisData![index].angle1,
      angle2: widget.thisData![index].angle2,
      date: widget.thisData![index].date,
      comments: _comments ?? '',
      creationDate: widget.thisData![index].creationDate,
    );
    await _api.put(
        patientsId: _patientsId, recordId: _recordId, thisData: thisData);
    widget.onDataUpdated?.call(); // ✅ Вызываем колбэк, если он передан
    setState(() {
      widget.thisData![index].comments = _comments!;
    });
  }

  String _getFileName(int index){
    return widget.thisData![index].name != null &&
        widget.thisData![index].name!.isNotEmpty
        ? widget.thisData![index].name ?? 'Нет данных'
        : '${widget.thisData![index].subtype ?? 'Сустав'}, положение ${widget.thisData![index].numericId ?? 'не указано'}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return errorDataWidget(snapshot.error);
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 40),
                Expanded(child: _buildImageViewer()),
                _buildThumbnailStrip(),
                const SizedBox(height: 10),
              ],
            );
          }),
    );
  }

  Widget _buildCloseAndDeleteButton(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ButtonWidget(
            labelText: '',
            icon: Icons.arrow_back_outlined,
            iconColor: Colors.black,
            onlyText: true,
            listRoles: Roles.all,
            onPressed: () {
              setState(() {
                Navigator.pop(context);
                //_showImageViewer = false;
              });
            }),
        Row(
          children: [
            (widget.isDeleteEnabled && !widget.viewRegime)
                ? ButtonWidget(
              labelText: '',
              icon: Icons.delete,
              iconColor: redBtnColor,
              onlyText: true,
              listRoles: Roles.asPatient,
              role: _role,
              onPressed: () {
                _showDeleteDialog(index);
              },
            ) : SizedBox(),
            ButtonWidget(
              labelText: '',
              icon: Icons.download,
              onlyText: true,
              listRoles: Roles.all,
              onPressed: () {
                downloadFile(
                  fileName: '${_getFileName(index)}, ${widget.thisData![index].filename ?? ''}',
                  fileId: _listImages[index],
                  context: context,
                  isChatFiles: false,);
              },
            ),
          ],
        ),
      ],
    );
  }

  // Просмотр изображения и описание под ним
  Widget _buildImageViewer() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: widget.isSwipeEnabled
          ? (index) => _selectedIndex.value = index
          : null,
      physics: widget.isSwipeEnabled
          ? const ScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: _listImages.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            _buildCloseAndDeleteButton(index),
            Expanded(
                child: FutureBuilderImage(
                  imageId: _listImages[index],
                  isFullSize: true,
                  isChatFiles: false,
                )),
            _buildComment(index),
          ],
        );
      },
    );
  }

  // Описание изображения
  Widget _buildComment(int index) {
    return ListTileWidget(
      title: _getFileName(index),
      subtitle: 'Комментарий: ${widget.thisData![index].comments}',
      iconTrailing: Icons.navigate_next,
      colorIconTrailing: Colors.blue.shade200,
      textStyle: inputTextStyle,
      horizontalPadding: 10.0,
      maxLines: 2,
      onTap: () {
        viewComment(index: index);
      },
    );
  }

  // Лента миниатюр в нижней части экрана
  Widget _buildThumbnailStrip() {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          //if (widget.addPhotoEnabled) _buildCameraButton(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndex,
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

  Widget _buildThumbnail(int index, int selectedIndex) {
    final imageId = _listImages[index];
    return GestureDetector(
      onTap: () {
        _selectedIndex.value = index;
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color:
            selectedIndex == index ? Colors.blueAccent : Colors.transparent,
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

  void viewComment({required int index}) {
    GlobalKey<FormFieldState> key = GlobalKey<FormFieldState>();

    showDialog(
        context: context,
        barrierDismissible: false, // Диалог не закроется при клике вне его
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Комментарий',
              style: formHeaderStyle,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // Чтобы высота AlertDialog зависела от содержимого окна, а не занимала всю высоту экрана
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (!widget.viewRegime)
                      ? InputText(
                    labelText: '',
                    fieldKey: key,
                    value: widget.thisData![index].comments,
                    required: false,
                    maxLength: 200,
                    listRoles: Roles.asPatient,
                    role: _role,
                    onChanged: (value) {
                      _comments = value;
                    },
                  )
                      : TextScrollViewWidget(
                    text: widget.thisData![index].comments,
                  ),
                ],
              ),
            ),
            actions: [
              ButtonWidget(
                labelText: (!widget.viewRegime) ? 'Отмена' : "ОК",
                onlyText: true,
                dialogForm: true,
                listRoles: Roles.all,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              if (!widget.viewRegime)
                SizedBox(
                  width: 10.0,
                ),
              if (!widget.viewRegime)
                ButtonWidget(
                  labelText: 'Сохранить',
                  onlyText: true,
                  dialogForm: true,
                  listRoles: Roles.asPatient,
                  role: _role,
                  onPressed: () {
                    _saveData(index);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          );
        });
  }
}
