import 'package:artrit/pages/page_doctor_main.dart';
import 'package:artrit/pages/page_first.dart';
import 'package:artrit/pages/page_login.dart';
import 'package:artrit/pages/page_patient_main.dart';





class AppRoutes {
  static const String first = '/';
  static const String login = '/login';
  static const String patientMain = '/patientMain';
  static const String doctorMain = '/doctorMain';
  // static const String patients= '/patients';
  // static const String patient = '/patient';
  // static const String doctor = '/doctor';
  //static const String inspections = '/inspections';
  // static const String questionnaire = '/questionnaire';
  // static const String tests = '/tests';
  // static const String testsClinical = '/testsClinical';
  // static const String testsBiochemical = '/testsBiochemical';
  // static const String testsImmunology = '/testsImmunology';
  // static const String testsOther = '/testsOther';
  // static const String researches = '/researches';
  // static const String treatment = '/treatment';
  // static const String tuberculosis = '/tuberculosis';


}

final routes =
{
  AppRoutes.first: (context) => PageFirst(),
  AppRoutes.login: (context) => PageLogin(),
  AppRoutes.patientMain: (context) => PagePatientMain(),
  AppRoutes.doctorMain: (context) => PageDoctorMain(),
  // AppRoutes.patients: (context) => PagePatients(),
  // AppRoutes.patient: (context) => PagePatient(),
  // AppRoutes.doctor: (context) => PageDoctor(),
  //AppRoutes.inspections: (context) => PageInspectionsMain(),
  // AppRoutes.questionnaire: (context) => PageQuestionnaire(),
  // AppRoutes.tests: (context) => PageTests(),
  // AppRoutes.testsClinical: (context) => PageTestsClinical(),
  // AppRoutes.testsBiochemical: (context) => PageTestsBiochemical(),
  // AppRoutes.testsImmunology: (context) => PageTestsImmunology(),
  // AppRoutes.testsOther: (context) => PageTestsOther(),
  // AppRoutes.researches: (context) => PageResearches(),
  // AppRoutes.treatment: (context) => PageTreatment(),
  // AppRoutes.tuberculosis: (context) => PageTuberculosis(),

};


