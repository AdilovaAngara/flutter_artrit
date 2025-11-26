import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../api/api_inspections_photo.dart';
import '../api/api_send_file.dart';
import '../data/data_inspections_photo.dart';
import '../data/data_send_file.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/input_text.dart';
import '../widgets/show_message.dart';
import '../widgets/switch_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/tooltip_widget.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class PageInspectionsAnglesPhotoAdd extends StatefulWidget {
  final File photo;
  final String jointsId;
  final String inspectionsId;
  final int role;

  const PageInspectionsAnglesPhotoAdd({
    super.key,
    required this.photo,
    required this.jointsId,
    required this.inspectionsId,
    required this.role
  });

  @override
  PageInspectionsAnglesPhotoAddState createState() =>
      PageInspectionsAnglesPhotoAddState();
}

class PageInspectionsAnglesPhotoAddState
    extends State<PageInspectionsAnglesPhotoAdd> {
  /// API
  final ApiInspectionsPhoto _api = ApiInspectionsPhoto();
  final ApiSendFile _apiSendFile = ApiSendFile();
  /// Параметры
  late int _role;
  late String _patientsId;
  late File? _pickedImage;
  /// Ключи
  final _formKey = GlobalKey<FormState>();
  final Map<Enum, GlobalKey<FormFieldState>>
  _keys = {
    for (var e in Enum.values) e: GlobalKey<FormFieldState>(),
  };

  final double radius = 130;
  late Offset center = Offset(MediaQuery.of(context).size.width / 2,
      (MediaQuery.of(context).size.height - 200) / 2);
  late List<Offset> points = _initializePoints();
  int pointsCount = 2;
  bool twoAngle = false;
  bool zoomRegime = false;
  bool _isLoading = false; // Флаг загрузки
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _role = widget.role;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      center = Offset(size.width / 2, (size.height - 200) / 2);
      points = _initializePoints();
      setState(() {});
    });
  }


  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }


  Widget _buildBackgroundImage() {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 1.0,
      maxScale: 4.0,
      panEnabled: true,
      // Разрешает перемещение
      scaleEnabled: true,
      // Разрешает масштабирование
      child: Image.file(
        widget.photo,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildPoints() {
    return IgnorePointer(
      ignoring: zoomRegime, // Если зум включён, игнорируем жесты для точек
      child: GestureDetector(
        onPanUpdate: (details) {
          if (!zoomRegime) {
            // Двигать точки можно только если зум выключен
            for (int i = 0; i < pointsCount; i++) {
              if ((points[i] - details.localPosition).distance < 30) {
                _updatePoint(details, i);
              }
            }
          }
        },
        child: CustomPaint(
          painter: CirclePainter(
              center, radius, points), // Точки и окружность всегда видны
        ),
      ),
    );
  }

  List<Offset> _initializePoints() {
    return [
      for (int i = 0; i < pointsCount; i++)
        Offset(
          center.dx + radius * cos(i * 2 * pi / 4),
          center.dy + radius * sin(i * 2 * pi / 4),
        ),
    ];
  }

  double _calculateAngle(Offset p1, Offset p2) {
    double angle1 = atan2(p1.dy - center.dy, p1.dx - center.dx);
    double angle2 = atan2(p2.dy - center.dy, p2.dx - center.dx);
    double angleRad = angle2 - angle1; // Угол в радианах
    double angle = angleRad * 180 / pi; // Конвертация в градусы
    return angle < 0 ? angle + 360 : angle;
  }

  bool _isAngleValid(double angle, int index) {
    for (int i = 0; i < points.length; i++) {
      if (i != index) {
        double existingAngle =
            atan2(points[i].dy - center.dy, points[i].dx - center.dx);
        double diff = (angle - existingAngle).abs();
        if (diff < 0.1 || diff > (2 * pi - 0.1)) {
          return false;
        }
      }
    }
    return true;
  }

  void _updatePoint(DragUpdateDetails details, int index) {
    setState(() {
      double angle = atan2(details.localPosition.dy - center.dy,
          details.localPosition.dx - center.dx);
      if (_isAngleValid(angle, index)) {
        points[index] = Offset(
            center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      }
    });
  }

  Future<File> _captureImage() async {
    try {
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Создаем временный файл
      final tempDir = await getTemporaryDirectory();
      File file = File('${tempDir.path}/${dateFullTimeFormatForFileName(getMoscowDateTime())}.png');
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      debugPrint("Ошибка при сохранении изображения: $e");
      throw Exception("Ошибка при сохранении");
    }
  }


  Future<void> _changeData(String comments, int angle1, int? angle2) async {
    if (!_formKey.currentState!.validate()) {
      ShowMessage.show(context: context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await _post(comments, angle1, angle2);

    setState(() {
      _isLoading = false;
    });
  }


  Future<void> _post(String comments, int angle1, int? angle2) async {
    _patientsId = await readSecureData(SecureKey.patientsId);
    if (_pickedImage == null) {
      debugPrint("Ошибка: изображение не было создано");
      return;
    }
    // Отправляем изображение на сервер
    DataSendFile dataSendFile = await _apiSendFile.sendFile(path: _pickedImage!.path);
    String id = dataSendFile.id;

    DataInspectionsPhoto thisData = DataInspectionsPhoto(
      id: id,
      patientsId: _patientsId,
      jointsId: widget.jointsId,
      inspectionId: widget.inspectionsId,
      date: convertToTimestamp(dateTimeFormat(getMoscowDateTime())),
      comments: comments,
      angle1: angle1,
      angle2: angle2,
      creationDate: convertToTimestamp(dateTimeFormat(getMoscowDateTime())),);
    _api.post(patientsId: _patientsId, thisData: thisData);
  }


  void _showSavePhotoForm() {
    int angle1 = int.tryParse(_calculateAngle(points[0], points[1]).toStringAsFixed(0)) ?? 0;
    int? angle2 = (points.length > 2) ? int.tryParse(_calculateAngle(points[1], points[2]).toStringAsFixed(0)) : null;
    String comments = '';

    showDialog(
      context: context,
      barrierDismissible: false, // Диалог не закроется при клике вне его
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setdialogState) {
            return Form(
              key: _formKey,
              child: AlertDialog(
                title: Text('Сохранить изображение', style: formHeaderStyle,),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_pickedImage != null)
                        Image.file(_pickedImage!, height: 350, width: 350, fit: BoxFit.fitHeight),
                      SizedBox(height: 10),
                      InputText(
                        labelText: 'Угол 1',
                        fieldKey:
                        _keys[Enum.angle1]!,
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
                        fieldKey:
                        _keys[Enum.angle2]!,
                        value: angle2,
                        required: (points.length > 2) ? true : false,
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
                        fieldKey: _keys[
                        Enum.comments]!,
                        value: '',
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
                  SizedBox(height: 10),
                  ButtonWidget(
                    labelText: 'Сохранить',
                    onlyText: true,
                    dialogForm: true,
                    showProgressIndicator: _isLoading,
                    listRoles: Roles.asPatient,
                    role: _role,
                    onPressed: () async {
                      setdialogState(() {
                        _isLoading = true;
                      });
                       await _changeData(comments, angle1, angle2);
                      setdialogState(() {
                        _isLoading = false;
                        if (mounted) {
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                        }
                      });
                    },
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TooltipWidget(
                  richText: _infoIconText
                ),
                ButtonWidget(
                  labelText: '',
                  icon: Icons.close,
                  onlyText: true,
                  listRoles: Roles.asPatient,
                  role: _role,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: Stack(
                children: [
                  Positioned.fill(child: _buildBackgroundImage()),
                  Positioned.fill(
                    child: _buildPoints(),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: ButtonWidget(
                      labelText: '',
                      icon: zoomRegime
                          ? _checkIcon
                          : _zoomIcon,
                      iconColor: _isLoading ? Colors.transparent : zoomRegime ? Colors.green : Colors.white,
                      iconSize: zoomRegime ? 43 : 40,
                      iconAlignment: IconAlignment.start,
                      onlyText: true,
                      listRoles: Roles.asPatient,
                      role: _role,
                      onPressed: () {
                        zoomRegime = !zoomRegime;
                        setState(() {});
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_calculateAngle(points[0], points[1]).toStringAsFixed(0)}°',
                        style: captionTextStyle,
                      ),
                    ),
                  ),
                  if (pointsCount == 3)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_calculateAngle(points[1], points[2]).toStringAsFixed(0)}°',
                          style: captionTextStyle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SwitchWidget(
                  labelTextFirst: '1 угол',
                  labelTextLast: '2 угла',
                  value: twoAngle,
                  listRoles: Roles.asPatient,
                  role: _role,
                  onChanged: (newValue) {
                    setState(() {
                      twoAngle = newValue;
                      pointsCount = twoAngle ? 3 : 2;
                      points = _initializePoints();
                    });
                  },
                ),
                ButtonWidget(
                  labelText: 'Сохранить',
                  icon: Icons.camera_alt,
                    onlyText: true,
                  showProgressIndicator: _isLoading,
                    listRoles: Roles.asPatient,
                    role: _role,
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await Future.delayed(Duration(seconds: 1));
                    _pickedImage = await _captureImage();  // Получаем финальное изображение
                    setState(() {
                      _isLoading = false;
                    });
                    _showSavePhotoForm();
                  }
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final List<Offset> points;

  CirclePainter(this.center, this.radius, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final yellowFillPaint = Paint()
      ..color = Colors.yellow.withAlpha(350)
      ..style = PaintingStyle.fill;

    final blueFillPaint = Paint()
      ..color = Colors.lightBlueAccent.withAlpha(350)
      ..style = PaintingStyle.fill;

    void drawSegment(Canvas canvas, Offset p1, Offset p2, Paint fillPaint) {
      double startAngle = atan2(p1.dy - center.dy, p1.dx - center.dx);
      double endAngle = atan2(p2.dy - center.dy, p2.dx - center.dx);
      double sweepAngle = endAngle - startAngle;
      if (sweepAngle < 0) sweepAngle += 2 * pi;

      Path sectorPath = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(p1.dx, p1.dy)
        ..arcTo(Rect.fromCircle(center: center, radius: radius), startAngle,
            sweepAngle, false)
        ..close();

      canvas.drawPath(sectorPath, fillPaint);
    }

    canvas.drawCircle(center, radius, circlePaint);
    drawSegment(canvas, points[0], points[1], yellowFillPaint);
    if (points.length == 3) {
      drawSegment(canvas, points[1], points[2], blueFillPaint);
    }

    for (var point in points) {
      canvas.drawLine(center, point, circlePaint);
      canvas.drawCircle(center, 6, Paint()..color = Colors.red);
      canvas.drawCircle(point, 20, Paint()..color = Colors.green);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


const IconData _checkIcon = Icons.check_circle_rounded;
const IconData _zoomIcon = Icons.zoom_out_map;

RichText _infoIconText = RichText(
    text: TextSpan(
  children: [
    WidgetSpan(
      child: Icon(
        Icons.looks_one_rounded,
        size: 17,
        color: Colors.green,
      ),
    ),
    const TextSpan(
        text: ' Используйте иконку ',
        style: labelStyle),
    WidgetSpan(
      child: Icon(
        _zoomIcon,
        size: 17,
        color: Colors.deepPurpleAccent,
      ),
    ),
    const TextSpan(
        text:
        ' , чтобы включить режим масштабирования изображения.\n\n',
        style: labelStyle),
    WidgetSpan(
      child: Icon(
        Icons.looks_two_rounded,
        size: 17,
        color: Colors.green,
      ),
    ),
    const TextSpan(
        text:
        ' Нажмите ',
        style: labelStyle),
    WidgetSpan(
      child: Icon(
        _checkIcon,
        size: 22,
        color: Colors.green,
      ),
    ),
    const TextSpan(
        text:
        ' , чтобы вернуться к измерению углов.',
        style: labelStyle),
  ],
),
);