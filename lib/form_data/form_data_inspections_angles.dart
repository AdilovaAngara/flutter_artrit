import '../api/api_inspections_joints_favorite.dart';
import '../api/api_inspections_photo.dart';
import '../data/data_inspections_joints_favorite.dart';
import '../data/data_inspections_photo.dart';
import '../my_functions.dart';
import '../secure_storage.dart';


class ImagesItem {
  final String path;
  final String label;
  final List<ImagesJointsItem> listImageAndId;
  int photoCount;

  ImagesItem({
    required this.path,
    required this.label,
    required this.listImageAndId,
    this.photoCount = 0
  });
}

class ImagesJointsItem {
  final String path;
  final String jointsId;
  String? jointsLabel;
  bool isFavorite;
  int photoCount;

  ImagesJointsItem({
    required this.path,
    required this.jointsId,
    this.jointsLabel,
    this.isFavorite = false,
    this.photoCount = 0
  });
}

class FormDataInspectionsAngles {
  final String inspectionsId;
  FormDataInspectionsAngles({
    required this.inspectionsId,
  });

  /// API
  final ApiInspectionsJointsFavorite _api = ApiInspectionsJointsFavorite();
  final ApiInspectionsPhoto _apiPhoto = ApiInspectionsPhoto();
  /// Данные
  List<DataInspectionsJointsFavorite>? _thisData;
  List<DataInspectionsPhoto>? _thisDataPhoto;
  /// Параметры
  late String _patientsId;
  final String _bodyType = 'angles';


  Future<List<ImagesItem>> getImageItem() async {
    _patientsId = await readSecureData(SecureKey.patientsId);
    _thisData = await _api.get(patientsId: _patientsId);
    _thisDataPhoto = await _apiPhoto.get(
        patientsId: _patientsId,
        bodyType: _bodyType,
        inspectionsId: inspectionsId);

    // Составляем список избранных положений суставов
    ImageData.listImageAndIdFavorite = _thisData!.isEmpty
        ? [] : _thisData!.where((e) => e.jointId != null).map((item) {
      return ImagesJointsItem(
          path: _getFavoritePath(item.jointId!),
          jointsId: item.jointId!,
          //jointsLabel: _getJointsLabel(item.jointId!, imagesItem),
          isFavorite: true
      );
    }).toList()..sort((a, b) => int.parse(extractImageNumber(a.path)).compareTo(int.parse(extractImageNumber(b.path))));

    List<ImagesItem> imagesItem = [
      ImagesItem(path: 'assets/love.jpg', label: 'Избранное', listImageAndId: ImageData.listImageAndIdFavorite, photoCount: _getPhotoCountMain(ImageData.listImageAndIdFavorite)),
      ImagesItem(path: 'assets/ankle_thumbnail.jpg', label: 'Голеностопные суставы', listImageAndId: ImageData.listImageAndIdAnkle, photoCount: _getPhotoCountMain(ImageData.listImageAndIdAnkle)),
      ImagesItem(path: 'assets/knee_thumbnail.jpg', label: 'Коленные суставы', listImageAndId: ImageData.listImageAndIdKnee, photoCount: _getPhotoCountMain(ImageData.listImageAndIdKnee)),
      ImagesItem(path: 'assets/elbow_thumbnail.jpg', label: 'Локтевые суставы', listImageAndId: ImageData.listImageAndIdElbow, photoCount: _getPhotoCountMain(ImageData.listImageAndIdElbow)),
      ImagesItem(path: 'assets/wrist_thumbnail.jpg', label: 'Лучезапястные суставы', listImageAndId: ImageData.listImageAndIdWrist, photoCount: _getPhotoCountMain(ImageData.listImageAndIdWrist)),
      ImagesItem(path: 'assets/hand_thumbnail.jpg', label: 'Мелкие суставы кисти', listImageAndId: ImageData.listImageAndIdHand, photoCount: _getPhotoCountMain(ImageData.listImageAndIdHand)),
      ImagesItem(path: 'assets/shoulder_thumbnail.jpg', label: 'Плечевые суставы', listImageAndId: ImageData.listImagesAndIdShoulder, photoCount: _getPhotoCountMain(ImageData.listImagesAndIdShoulder)),
      ImagesItem(path: 'assets/spine_thumbnail.jpg', label: 'Позвоночник', listImageAndId: ImageData.listImageAndIdSpine, photoCount: _getPhotoCountMain(ImageData.listImageAndIdSpine)),
      ImagesItem(path: 'assets/hip_thumbnail.jpg', label: 'Тазобедренные суставы', listImageAndId: ImageData.listImageAndIdHip, photoCount: _getPhotoCountMain(ImageData.listImageAndIdHip)),
      ImagesItem(path: 'assets/neck_thumbnail.jpg', label: 'Шейный отдел', listImageAndId: ImageData.listImageAndIdNeck, photoCount: _getPhotoCountMain(ImageData.listImageAndIdNeck)),
    ];

    _updateImageData(imagesItem);
    return imagesItem;
  }


  // Расчет количества фотографий в на главной странице "Измерение углов"
  int _getPhotoCountMain(List<ImagesJointsItem> listImageAndId)
  {
    if (_thisData == null) return 0;
    int photoCount = 0;
    for (int i = 0; i < listImageAndId.length; i++) {
      photoCount += _thisDataPhoto!.where((e) => e.numericId == int.parse(extractImageNumber(listImageAndId[i].path))).length;
    }
    return photoCount;
  }



  String _getFavoritePath(String jointsId) {
    // Список всех списков для поиска
    final allLists = [
      ImageData.listImageAndIdAnkle,
      ImageData.listImageAndIdKnee,
      ImageData.listImageAndIdElbow,
      ImageData.listImageAndIdWrist,
      ImageData.listImageAndIdHand,
      ImageData.listImagesAndIdShoulder,
      ImageData.listImageAndIdSpine,
      ImageData.listImageAndIdHip,
      ImageData.listImageAndIdNeck,
    ];
    // Поиск пути по jointsId
    for (var list in allLists) {
      try {
        final item = list.firstWhere((e) => e.jointsId == jointsId);
        return item.path; // Возвращаем путь, если нашли
      } catch (e) {
        // Продолжаем поиск в следующем списке
        continue;
      }
    }
    // Если ничего не найдено, возвращаем путь по умолчанию
    return ''; // Можно заменить на путь к заглушке, например 'assets/placeholder.jpg'
  }


  String _getJointsLabel(String jointsId, List<ImagesItem> imagesItem) {
    for (var item in imagesItem) {
      // Пропускаем элемент с label 'Избранное', потому что нам нужна категория суставов, а не текст "Избранное"
      if (item.label == 'Избранное') continue;
      // Ищем в listImageAndId текущего item запись с нужным jointsId
      if (item.listImageAndId.any((joint) => joint.jointsId == jointsId)) {
        return item.label; // Возвращаем label, если нашли совпадение
      }
    }
    return ''; // Возвращаем null, если ничего не найдено
  }




  void _updateImageData(List<ImagesItem> imagesItem) {
    if (_thisData == null) return;
    final allLists = [
      ImageData.listImageAndIdAnkle,
      ImageData.listImageAndIdKnee,
      ImageData.listImageAndIdElbow,
      ImageData.listImageAndIdWrist,
      ImageData.listImageAndIdHand,
      ImageData.listImagesAndIdShoulder,
      ImageData.listImageAndIdSpine,
      ImageData.listImageAndIdHip,
      ImageData.listImageAndIdNeck,
    ];

    // Определяем является ли положение избранным
    for (int i = 0; i < allLists.length; i++) {
      for (int j = 0; j < allLists[i].length; j++)
      {
        allLists[i][j].isFavorite = _thisData!.any((e) => e.jointId == allLists[i][j].jointsId);
      }
    }

    // Добавим в список listImageAndIdFavorite, чтобы для него тоже посчитать кол-во фото
    allLists.add(ImageData.listImageAndIdFavorite);

    for (int i = 0; i < allLists.length; i++) {
      for (int j = 0; j < allLists[i].length; j++)
      {
        // Расчет количества фотографий на странице выбора положения
        allLists[i][j].photoCount = (_thisDataPhoto != null) ? _thisDataPhoto!.where((e) => e.numericId == int.parse(extractImageNumber(allLists[i][j].path))).length : 0;
        allLists[i][j].jointsLabel = _getJointsLabel(allLists[i][j].jointsId, imagesItem);
      }
    }
  }




}





















class ImageData {

  static List<ImagesJointsItem> listImageAndIdFavorite = [

  ];

  static final List<ImagesJointsItem> listImageAndIdAnkle = [
    ImagesJointsItem(path: 'assets/ankle_img_38.jpg', jointsId: '9412f18c-f1bf-4abd-b17e-df77d1ffab94'),
    ImagesJointsItem(path: 'assets/ankle_img_45.jpg', jointsId: 'e95552cd-8aa8-4895-bb9b-4c4e5380d839'),
    ImagesJointsItem(path: 'assets/ankle_img_46.jpg', jointsId: 'bfbcf64d-5190-4c36-957f-b8201c275429'),
    ImagesJointsItem(path: 'assets/ankle_img_47.jpg', jointsId: 'f5fa189b-4574-430d-a74a-c0416f6a8821'),
    ImagesJointsItem(path: 'assets/ankle_img_48.jpg', jointsId: '35a412a7-e63e-4a85-8a8f-34cec971534c'),
    ImagesJointsItem(path: 'assets/ankle_img_49.jpg', jointsId: 'c92d3f6c-c396-4910-a660-20dd785908ba'),
    ImagesJointsItem(path: 'assets/ankle_img_50.jpg', jointsId: '4cbd4c5a-451e-4c31-9c85-b10a741eea28'),
    ImagesJointsItem(path: 'assets/ankle_img_55.jpg', jointsId: '163cc99b-8c35-4778-8f9f-4b26e76ce639'),
  ];

  static final List<ImagesJointsItem> listImageAndIdKnee = [
    ImagesJointsItem(path: 'assets/knee_img_39.jpg', jointsId: 'a7da0a9d-4bf4-4f73-af8e-49f8f725a253'),
    ImagesJointsItem(path: 'assets/knee_img_40.jpg', jointsId: '83b761e6-b02e-41a5-96e3-84bc6ae116f9'),
    ImagesJointsItem(path: 'assets/knee_img_41.jpg', jointsId: 'df2264f8-3642-4af1-848d-df98f8c10992'),
    ImagesJointsItem(path: 'assets/knee_img_42.jpg', jointsId: '15c3e8f1-e776-49d9-826b-92742fe71cde'),
    ImagesJointsItem(path: 'assets/knee_img_43.jpg', jointsId: 'bd052e1e-ce26-4907-8928-7f1b4fa2427b'),
  ];

  static final List<ImagesJointsItem> listImageAndIdElbow = [
    ImagesJointsItem(path: 'assets/elbow_img_7.jpg', jointsId: '4fa2e30a-26bf-41e1-96e0-950bbfc2be12'),
    ImagesJointsItem(path: 'assets/elbow_img_8.jpg', jointsId: '0c440b88-0e67-4799-8a73-5e23210f2956'),
    ImagesJointsItem(path: 'assets/elbow_img_9.jpg', jointsId: 'db5589ee-5cbc-4624-9745-a86ec443d48e'),
    ImagesJointsItem(path: 'assets/elbow_img_10.jpg', jointsId: '4e2cead6-1609-4eb6-be50-ef6a187763fb'),
    ImagesJointsItem(path: 'assets/elbow_img_11.jpg', jointsId: 'e8468a13-7883-4fd8-99ff-ac140c2f166b'),
  ];

  static final List<ImagesJointsItem> listImageAndIdWrist = [
    ImagesJointsItem(path: 'assets/wrist_img_13.jpg', jointsId: 'f19fa77d-8d90-4d69-a350-f879853b606e'),
    ImagesJointsItem(path: 'assets/wrist_img_14.jpg', jointsId: 'ab3c972a-1081-450c-a605-55f4b40fdcca'),
    ImagesJointsItem(path: 'assets/wrist_img_24.jpg', jointsId: '66253de0-4126-4d7b-86d2-f75e008f93a9'),
    ImagesJointsItem(path: 'assets/wrist_img_25.jpg', jointsId: 'be76d4f3-4c5e-4a9b-b5f7-bf8543d6a3e6'),
  ];

  static final List<ImagesJointsItem> listImageAndIdHand = [
    ImagesJointsItem(path: 'assets/hand_img_19.jpg', jointsId: '795fef45-a731-442a-ac00-35758c41b28f'),
    ImagesJointsItem(path: 'assets/hand_img_20.jpg', jointsId: 'c4ce143c-6026-49e2-99c0-5393e7af3ddd'),
    ImagesJointsItem(path: 'assets/hand_img_21.jpg', jointsId: '31f909ce-45dd-4460-8d31-5d09c59515ee'),
    ImagesJointsItem(path: 'assets/hand_img_22.jpg', jointsId: '17967ac0-d317-47a5-acbe-940e82b39b9f'),
    ImagesJointsItem(path: 'assets/hand_img_23.jpg', jointsId: 'eb6146aa-0034-48fa-b6b2-de634b506675'),
    ImagesJointsItem(path: 'assets/hand_img_27.jpg', jointsId: '59b688da-2b46-481d-b9b4-e126488bf8d4'),
    ImagesJointsItem(path: 'assets/hand_img_28.jpg', jointsId: '24e737a9-9cfb-4824-b13e-a1a868a8b39a'),
    ImagesJointsItem(path: 'assets/hand_img_29.jpg', jointsId: '30adf4ee-d19d-4b22-b5f3-4809d89d2eee'),
    ImagesJointsItem(path: 'assets/hand_img_30.jpg', jointsId: 'a5df2859-c400-4e57-a587-c94fd58e5cd0'),
    ImagesJointsItem(path: 'assets/hand_img_31.jpg', jointsId: '222cead4-d403-40d6-bc36-42859cb0b91e'),
  ];

  static final List<ImagesJointsItem> listImagesAndIdShoulder = [
    ImagesJointsItem(path: 'assets/shoulder_img_1.jpg', jointsId: 'bcc5cb36-1eb3-4555-83b6-6035ba5a1492'),
    ImagesJointsItem(path: 'assets/shoulder_img_2.jpg', jointsId: 'e739c368-02cd-418c-994e-176aa9d81a66'),
    ImagesJointsItem(path: 'assets/shoulder_img_3.jpg', jointsId: 'b6b8c287-610c-484d-a2b6-99392c50bc37'),
    ImagesJointsItem(path: 'assets/shoulder_img_4.jpg', jointsId: 'd6266b52-9466-4411-9198-e78834ff282c'),
    ImagesJointsItem(path: 'assets/shoulder_img_5.jpg', jointsId: '74503fc0-db1b-4267-b8d7-d0404a845f11'),
    ImagesJointsItem(path: 'assets/shoulder_img_6.jpg', jointsId: '980779a7-0ea2-4a12-9df2-e218bcda729b'),
    ImagesJointsItem(path: 'assets/shoulder_img_12.jpg', jointsId: 'f73b7240-1f0b-486e-9cc5-877ffb39b850'),
  ];

  static final List<ImagesJointsItem> listImageAndIdSpine = [
    ImagesJointsItem(path: 'assets/spine_img_51.jpg', jointsId: 'c8be77f5-9460-4163-adac-7865b43c267b'),
    ImagesJointsItem(path: 'assets/spine_img_52.jpg', jointsId: 'faf6f10b-0211-49ef-b94d-5aebcdde6433'),
    ImagesJointsItem(path: 'assets/spine_img_53.jpg', jointsId: '6e755817-7449-4959-b181-9dae46f9cd60'),
    ImagesJointsItem(path: 'assets/spine_img_54.jpg', jointsId: 'c955c5fa-3087-4693-a60f-3c5080960bae'),
  ];

  static final List<ImagesJointsItem> listImageAndIdHip = [
    ImagesJointsItem(path: 'assets/hip_img_26.jpg', jointsId: '58e6aeb8-ef54-4e79-8d20-959276813e03'),
    ImagesJointsItem(path: 'assets/hip_img_32.jpg', jointsId: 'b60d801c-f615-4c4a-87a1-70e09c9ac75a'),
    ImagesJointsItem(path: 'assets/hip_img_33.jpg', jointsId: '8d3425ac-1909-4c35-97db-59f5e818dbe3'),
    ImagesJointsItem(path: 'assets/hip_img_34.jpg', jointsId: '6cf69de3-76cc-42b0-861a-02458ace848d'),
    ImagesJointsItem(path: 'assets/hip_img_35.jpg', jointsId: '626fa424-1fc1-4ee0-9b0c-dd0d899b99d1'),
    ImagesJointsItem(path: 'assets/hip_img_36.jpg', jointsId: '03a62099-4194-4298-91c6-cc0aa888fa26'),
    ImagesJointsItem(path: 'assets/hip_img_37.jpg', jointsId: '06eb515d-7f35-432a-bd73-719565969e1c'),
    ImagesJointsItem(path: 'assets/hip_img_44.jpg', jointsId: '248280fc-893a-4d57-a67e-72a7661876f9'),
  ];

  static final List<ImagesJointsItem> listImageAndIdNeck = [
    ImagesJointsItem(path: 'assets/neck_img_15.jpg', jointsId: '7c2c0021-91fb-4590-93f6-432c387d39a8'),
    ImagesJointsItem(path: 'assets/neck_img_16.jpg', jointsId: '31d05c70-a074-40e6-96d6-20b00d56b51a'),
    ImagesJointsItem(path: 'assets/neck_img_17.jpg', jointsId: 'fe42cb63-e8eb-4db5-bb4b-2881c49baccb'),
    ImagesJointsItem(path: 'assets/neck_img_18.jpg', jointsId: 'fa9b7011-e916-4309-88f9-aa60ca64955a'),
  ];
}
