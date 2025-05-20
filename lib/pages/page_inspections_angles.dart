import 'package:flutter/material.dart';
import '../form_data/form_data_inspections_angles.dart';
import '../my_functions.dart';
import '../widgets/app_bar_widget.dart';
import 'page_inspections_angles_select.dart';

class PageInspectionsAngles extends StatefulWidget {
  final String inspectionsId;
  final VoidCallback? onDataUpdated;

  const PageInspectionsAngles({
    super.key,
    required this.inspectionsId,
    required this.onDataUpdated,
  });

  @override
  State<PageInspectionsAngles> createState() => PageInspectionsAnglesState();
}

class PageInspectionsAnglesState extends State<PageInspectionsAngles> {
  late Future<void> _future;
  /// Параметры
  List<ImagesItem> _imagesItem = [];

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _imagesItem = await FormDataInspectionsAngles(inspectionsId: widget.inspectionsId).getImageItem();
    setState(() {});
  }


  Future<void> _refreshData() async {
    await _loadData();
    if (mounted) {
      setState(() {});
    }
  }



  void _navigateAndRefresh(BuildContext context, {required int index}) {
    navigateToPage(
      context,
      PageInspectionsAnglesSelect(
        cornersTitle: _imagesItem[index].label,
        index: index,
        inspectionsId: widget.inspectionsId,
        onDataUpdated: () async {
          await _refreshData();
          widget.onDataUpdated?.call();
        },
        isFavoritePage: index == 0,
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Измерение углов',
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
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Две колонки
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75, // Квадратные картинки
                ),
                itemCount: _imagesItem.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        _navigateAndRefresh(context, index: index);
                      },
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    _imagesItem[index].path,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (_imagesItem[index].photoCount > 0)
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      Badge.count(
                                        backgroundColor: Colors.deepPurple.shade300,
                                        textStyle: TextStyle(fontSize: 17),
                                        count: _imagesItem[index].photoCount,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: Text(
                                _imagesItem[index].label,
                                maxLines: 2,
                                style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500,),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  );
                },
              ),
            ),
          );
        }
      ),
    );
  }
}


