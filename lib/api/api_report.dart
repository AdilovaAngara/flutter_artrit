import 'dart:io';
import 'dart:typed_data';
import 'package:artrit/my_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/download_file_widget.dart';
import 'base_client.dart';

enum Enum{
  startDate,
  endDate,
  allTime,
  isDoctor,
  isPatient,
  download
}

var baseClient = BaseClient();

class ApiReport{
  Future<dynamic> post({
    required String patientsId,
    required int startDate,
    required int endDate,
    required bool isDoctor,
    required bool isPatient,
    required bool download,
  }) async {
    var response = await baseClient.postReportData(
      api: '/api/patientsreport/SendReportPDF?',
      patientId: patientsId,
      startDate: startDate,
      endDate: endDate,
      isDoctor: isDoctor,
      isPatient: isPatient,
      download: download,
    );
    return response;
  }
}


