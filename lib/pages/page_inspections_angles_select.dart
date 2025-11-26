import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_inspections_joints_favorite.dart';
import '../data/data_inspections_joints_favorite.dart';
import '../form_data/form_data_inspections_angles.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/show_dialog_confirm.dart';
import 'page_inspections_angles_photo.dart';

class PageInspectionsAnglesSelect extends StatefulWidget {
  final String cornersTitle;
  final int index;
  final String inspectionsId;
  final bool isFavoritePage;

  const PageInspectionsAnglesSelect({
    super.key,
    required this.cornersTitle,
    required this.index,
    required this.inspectionsId,
    required this.isFavoritePage,
  });

  @override
  PageInspectionsAnglesSelectState createState() => PageInspectionsAnglesSelectState();
}

class PageInspectionsAnglesSelectState extends State<PageInspectionsAnglesSelect> {
  late Future<void> _future;
  /// API
  final ApiInspectionsJointsFavorite _api = ApiInspectionsJointsFavorite();

  /// Параметры
  late int _role;
  late String _patientsId;
  late String _recordId;
  late PageController _pageController;
  late int _currentIndex;
  List<ImagesItem> _imagesItem = [];
  List<ImagesJointsItem> _listImageAndId = [];

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }



  Future<void> _loadData() async {
    _role = await getUserRole();
    _patientsId = await readSecureData(SecureKey.patientsId);
    _imagesItem = await FormDataInspectionsAngles(inspectionsId: widget.inspectionsId).getImageItem();
    _listImageAndId = _imagesItem[widget.index].listImageAndId;
    _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
    setState(() {});
  }



  Future<void> _refreshData() async {
    _imagesItem = await FormDataInspectionsAngles(inspectionsId: widget.inspectionsId).getImageItem();
    _listImageAndId = _imagesItem[widget.index].listImageAndId;
    setState(() {});
  }



  void _navigateAndRefresh(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageInspectionsAnglesPhoto(
            cornersTitle: '${_listImageAndId[_currentIndex].jointsLabel}, положение ${extractImageNumber(
                _listImageAndId[_currentIndex].path)}',
            jointsId: _listImageAndId[_currentIndex].jointsId,
            inspectionsId: widget.inspectionsId),
      ),
    ).then((_) async {
      await _refreshData();
    });
}



  void _changeData({required ImagesJointsItem data,
    required bool isPost}) async {
    await _request(data: data, isPost: isPost);
    await _refreshData();
  }


  Future<void> _request({required ImagesJointsItem data, required bool isPost}) async {
    _recordId = data.jointsId;

    DataInspectionsJointsFavorite thisData = DataInspectionsJointsFavorite(
      patientId: _patientsId,
      jointId: _recordId,
      jointName: data.path
    );
    isPost
        ? await _api.post(patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.delete(patientsId: _patientsId, recordId: _recordId);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            return (_listImageAndId.isEmpty) ?
            notDataWidget : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: _listImageAndId.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: 40,),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Положение ${extractImageNumber(
                                        _listImageAndId[index].path)}',
                                      style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                ButtonWidget(
                                  labelText: '',
                                  icon: (_listImageAndId[index].isFavorite) ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                                  iconColor: (_listImageAndId[index].isFavorite) ? Colors.red : Colors.grey,
                                  iconSize: 40,
                                  iconAlignment: IconAlignment.start,
                                  onlyText: true,
                                  listRoles: Roles.all,
                                  role: _role,
                                  onPressed: () async {
                                    if (_listImageAndId[index].isFavorite) {
                                      await ShowDialogConfirm.show(context: context,
                                          message: 'Удалить положение из списка "Избранное"?',
                                          onConfirm: () {
                                            _changeData(data: _listImageAndId[index], isPost: false);
                                            _listImageAndId[index].isFavorite = false;
                                            if (widget.isFavoritePage) {
                                              _listImageAndId.removeAt(index);
                                            }
                                          });
                                    }
                                    else {
                                      await ShowDialogConfirm.show(context: context,
                                          message: 'Добавить положение в список "Избранное"?',
                                          onConfirm: () {
                                            _changeData(data: _listImageAndId[index], isPost: true);
                                            _listImageAndId[index].isFavorite = true;
                                          });
                                    }
                                    setState(() {
                                    });
                                  },
                                ),
                              ],
                            ),
                            Expanded(child: Stack(
                              children: [
                                Image.asset(_listImageAndId[index].path),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      Badge.count(
                                        backgroundColor: Colors.deepPurple.shade300,
                                        textStyle: TextStyle(fontSize: 20),
                                        count: _listImageAndId[index].photoCount,
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            )
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _listImageAndId.length,
                        (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index ? Colors.purple.shade300 : Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ButtonWidget(
                  labelText: 'Выбрать',
                  listRoles: Roles.all,
                  role: _role,
                  onPressed: () {
                    _navigateAndRefresh(context);
                  },
                ),
                SizedBox(height: 50),
              ],
            );
          }
        ),
    );
  }
}