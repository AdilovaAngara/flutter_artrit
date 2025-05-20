import 'package:flutter/material.dart';
import '../api/api_doctor.dart';
import '../data/data_doctor.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/input_text.dart';

class PageDoctorEdit extends StatefulWidget {
  final String title;

  const PageDoctorEdit({
    super.key,
    required this.title,
  });

  @override
  State<PageDoctorEdit> createState() => _PageDoctorEditState();
}

class _PageDoctorEditState extends State<PageDoctorEdit> {
  late Future<void> _future;
  /// API
  final ApiDoctor _api = ApiDoctor();

  /// Данные
  late DataDoctor _thisData;

  /// Параметры
  late int _role;
  late String _doctorsId;
  late String? _lastName;
  late String? _firstName;
  late String? _patronymic;
  late String? _email;
  late String? _phone;
  late String? _regionName;
  late String? _hospitalName;

  /// Ключи
  final _formKey = GlobalKey<FormState>();
  final Map<Enum, GlobalKey<FormFieldState>> _keys = {
    for (var e in Enum.values) e: GlobalKey<FormFieldState>(),
  };

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    _doctorsId = await readSecureData(SecureKey.doctorsId);

    final thisData = await _api.get(doctorsId: _doctorsId);
    setState(() {
      _thisData = thisData;
      _lastName = _thisData.lastName ?? '';
      _firstName= _thisData.firstName ?? '';
      _patronymic = _thisData.patronymic ?? '';
      _email = _thisData.email ?? '';
      _phone = _thisData.phone ?? '';
      _regionName = _thisData.regionName ?? '';
      _hospitalName = _thisData.hospitalName ?? '';
    });
  }

  void _saveData() async {
    if (!_formKey.currentState!.validate()) {
      showTopBanner(context: context);
      return;
    }
    await _put();
    if (mounted) {
      Navigator.pop(context);
    }
  }



  Future<void> _put() async {
    DataDoctor thisData = DataDoctor(
      regionName: _regionName ?? '',
      hospitalName: _hospitalName ?? '',
      id: _doctorsId,
      firstName: _firstName ?? '',
      patronymic: _patronymic ?? '',
      lastName: _lastName ?? '',
      email: _email ?? '',
      phone: _phone ?? '',
      regionId: _thisData.regionId,
      hospitalId: _thisData.hospitalId,
      roleId: _thisData.roleId,
    );
    _api.put(doctorsId: _doctorsId, thisData: thisData);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.title,
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

            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.0),
                            _buildForm(),
                            SizedBox(height: 30.0),
                          ],
                        ),
                      ),
                    ),
                    // Container(
                    //   padding: EdgeInsets.all(10.0),
                    //   child: Center(
                    //     child: ButtonWidget(
                    //       labelText: 'Сохранить',
                    //       onPressed: () async {
                    //         bool hasEmptyInputs = hasEmptyInputsInAll([_keys]);
                    //         saveData(hasEmptyInputs);
                    //       },
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          }),
    );
  }






  Widget _buildForm()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputText(
          labelText: 'Фамилия',
          fieldKey: _keys[Enum.lastName]!,
          value: _lastName,
          required: true,
          keyboardType: TextInputType.name,
          listRoles: Roles.asAdmin,
          role: _role,
          onChanged: (value) {
            setState(() {
              _lastName = value;
            });
          },
        ),
        InputText(
          labelText: 'Имя',
          fieldKey: _keys[Enum.firstName]!,
          value: _firstName,
          required: true,
          keyboardType: TextInputType.name,
          listRoles: Roles.asAdmin,
          role: _role,
          onChanged: (value) {
            setState(() {
              _firstName = value;
            });
          },
        ),
        InputText(
          labelText: 'Отчество',
          fieldKey: _keys[Enum.patronymic]!,
          value: _patronymic,
          required: false,
          keyboardType: TextInputType.name,
          listRoles: Roles.asAdmin,
          role: _role,
          onChanged: (value) {
            setState(() {
              _patronymic = value;
            });
          },
        ),
        InputText(
          labelText: 'E-mail',
          fieldKey: _keys[Enum.email]!,
          value: _email,
          required: true,
          keyboardType: TextInputType.emailAddress,
          listRoles: Roles.asAdmin,
          role: _role,
          onChanged: (value) {
            setState(() {
              _email = value;
            });
          },
        ),
        InputText(
          labelText: 'Телефон',
          fieldKey: _keys[Enum.phone]!,
          value: _phone,
          required: true,
          keyboardType: TextInputType.phone,
          listRoles: Roles.asAdmin,
          role: _role,
          onChanged: (value) {
            setState(() {
              _phone = value;
            });
          },
        ),
        InputText(
          labelText: 'Регион',
          fieldKey: _keys[Enum.regionName]!,
          value: _regionName,
          required: true,
          listRoles: Roles.asAdmin,
          role: _role,
          onChanged: (value) {
            setState(() {
              _regionName = value;
            });
          },
        ),
        InputText(
          labelText: 'Организация',
          fieldKey: _keys[Enum.hospitalName]!,
          value: _hospitalName,
          required: true,
          listRoles: Roles.asAdmin,
          role: _role,
          onChanged: (value) {
            setState(() {
              _hospitalName= value;
            });
          },
        ),
      ],
    );
  }





}
