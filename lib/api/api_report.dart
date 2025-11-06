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


