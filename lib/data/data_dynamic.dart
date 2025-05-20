class DataDynamic {
  DateTime? date;
  dynamic value;
  String? visibleValue;
  bool showBothValue;
  String? unit;
  bool? isNorma;
  String? info;

  DataDynamic({
    required this.date,
    required this.value,
    this.visibleValue,
    this.showBothValue = false,
    this.unit,
    this.isNorma,
    this.info
  });
}