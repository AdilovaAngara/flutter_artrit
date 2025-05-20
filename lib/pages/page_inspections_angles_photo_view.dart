import 'package:flutter/material.dart';
import '../data/data_inspections_photo.dart';
import '../my_functions.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/future_builder_image.dart';
import '../widgets/image_gallery.dart';

class PageInspectionsAnglesPhotoView extends StatefulWidget {
  final String cornersTitle;
  final List<DataInspectionsPhoto>? thisData;

  const PageInspectionsAnglesPhotoView({
    super.key,
    required this.cornersTitle,
    required this.thisData,
  });

  @override
  State<PageInspectionsAnglesPhotoView> createState() =>
      PageInspectionsAnglesPhotoViewState();
}

class PageInspectionsAnglesPhotoViewState
    extends State<PageInspectionsAnglesPhotoView> {
  late Future<void> _future;

  /// Данные
  List<DataInspectionsPhoto>? _thisData;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  @override
  void didUpdateWidget(covariant PageInspectionsAnglesPhotoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.thisData != oldWidget.thisData) {
      _loadData();
    }
  }


  Future<void> _loadData() async {
    _thisData = widget.thisData;
    setState(() {

    });
  }

  Future<void> _refreshData() async {
    await _loadData();
    if (mounted) {
      setState(() {});
    }
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
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
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
                                          thisData: _thisData,
                                          currentIndex: index,
                                          isSwipeEnabled: true,
                                          isAddEnabled: false,
                                          isDeleteEnabled: false,
                                          viewRegime: true,
                                          onDataUpdated: () {
                                            _refreshData();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: 15
                                ),
                                _buildForm(index),
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
          );
        },
      ),
    );
  }

  Widget _buildForm(int index) {
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
                maxLines: 2,
                softWrap: true,
                text: TextSpan(
                  children: [
                    const TextSpan(
                        text: 'Суставы:  ',
                        style: labelStyle),
                    TextSpan(
                      text: _thisData![index].subtype,
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
                        text: 'Положение:  ',
                        style: labelStyle),
                    TextSpan(
                      text: '${_thisData![index].numericId}',
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
            ],
          ),
        ],
      ),
    );
  }

}
