
class Roles {

  static const int admin = 0;
  static const int patient = 1;
  static const int doctor = 2;
  static const int superVisor = 3;
  static const int anonymous = 100;


  static List<int> asPatient = [patient, superVisor, anonymous];
  static List<int> asDoctor = [doctor, superVisor];
  static List<int> asAdmin = [admin];
  static List<int> all = [admin, patient, doctor, superVisor];

}
