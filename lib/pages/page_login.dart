import 'package:artrit/api/api_login.dart';
import 'package:artrit/api/base_client.dart';
import 'package:artrit/pages/page_login_recovery.dart';
import 'package:artrit/pages/page_patient_register.dart';
import 'package:artrit/pages/page_questionnaire_edit.dart';
import 'package:artrit/widgets/button_widget.dart';
import 'package:artrit/widgets/notifications_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/data_login.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../routes.dart';
import '../secure_storage.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/chat_provider.dart';
import '../widgets/input_text.dart';
import '../widgets/input_text_obscure.dart';
import '../widgets/show_dialog_confirm.dart';
import 'menu.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => PageLoginState();
}

class PageLoginState extends State<PageLogin> {
  /// API
  final ApiLogin _api = ApiLogin();

  /// Данные
  DataLogin? _thisData;

  /// Параметры
  bool _isLoading = false;
  String _login = '';
  String _password = '';
  late int? _role;
  final bool _isTest = BaseClient().isTest;

  /// Ключи
  final _formKey = GlobalKey<FormState>();
  final Map<Enum, GlobalKey<FormFieldState>> _keys = {
    for (var e in Enum.values) e: GlobalKey<FormFieldState>(),
  };



  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }



  Future<void> _loadData() async {
    if (!_formKey.currentState!.validate()) {
      showBottomBanner(context: context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    DataLogin thisData = DataLogin(
      login: _login,
      password: _password,
    );
    _thisData = await _api.post(thisData: thisData);

    setState(() {
      _isLoading = false;
    });


    if (_thisData != null) {
      // Сохраняем учетные данные
      await _saveCredentials();

      /// Инициализация провайдеров
      Provider.of<ChatProvider>(context, listen: false).reinitialize();
      Provider.of<NotificationsProvider>(context, listen: false).reinitialize();

      _role = _thisData?.role;
      (_role == 1)
          ? Navigator.pushReplacementNamed(
        context,
        AppRoutes.patientMain,
      )
          : (_role == 2)
          ? Navigator.pushReplacementNamed(
        context,
        AppRoutes.doctorMain,
      )
          : showBottomBanner(
          context: context,
          message: 'Нет доступа к системе');
    } else {
      showBottomBanner(
          context: context,
          message:
          'Ошибка авторизации. Проверьте логин или пароль');
    }
  }



  Future<void> _loadSavedCredentials() async {
    try {
      final login = await readSecureData(SecureKey.login);
      final password = await readSecureData(SecureKey.password);
      if (login.isNotEmpty && password.isNotEmpty && mounted) {
        setState(() {
          _login = login;
          _password = password;
          _keys[Enum.login]!.currentState?.didChange(login);
          _keys[Enum.password]!.currentState?.didChange(password);
        });
      }
    } catch (e) {
      debugPrint('Error loading credentials: $e');
    }
  }




  Future<void> _saveCredentials() async {
    await ShowDialogConfirm.show(
        context: context,
        message: 'Хотите сохранить логин и пароль для автоматического входа?',
        onConfirm: () async {
          await saveSecureData(SecureKey.login, _login);
          await saveSecureData(SecureKey.password, _password);
        }
    );
  }




  Future<void> _navigateAndRefresh(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageQuestionnaireEdit(
          title: EnumMenu.questionnaire.displayName,
          isEditForm: false,
          isAnonymous: true,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(
          title: 'Авторизация',
          showMenu: false,
          showChat: false,
          showNotifications: false,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              // Скрываем клавиатуру при касании пустого места
              FocusScope.of(context).unfocus();
            },
            // Указываем, что касания не блокируют другие жесты (например, прокрутку)
            behavior: HitTestBehavior.translucent,
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => navigateToPageMenu(context, EnumMenu.help),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Помощь',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(width: 5,),
                            Icon(Icons.help, color: Colors.orange,)
                          ],
                        ),
                      ),

                      SizedBox(height: 30),
                      InputText(
                        fieldKey: _keys[Enum.login]!,
                        labelText: 'Логин',
                        value: _login,
                        required: true,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        border: OutlineInputBorder(),
                        listRoles: Roles.all,
                        onChanged: (value) {
                          setState(() {
                            _login = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.0),
                      InputTextObscure(
                        fieldKey: _keys[Enum.password]!,
                        labelText: 'Пароль',
                        value: _password,
                        required: true,
                        border: OutlineInputBorder(),
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
                        },
                      ),
                      SizedBox(height: 40),
                      Center(
                        child: ButtonWidget(
                            labelText: 'Войти',
                            showProgressIndicator: _isLoading,
                            listRoles: Roles.all,
                            onPressed: () async {
                              await _loadData();
                            }),
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        child: Text(
                          'Забыли пароль?',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54, // Цвет текста
                            decoration: TextDecoration.none,
                          ),
                        ),
                        onTap: () {
                          navigateToPage(
                            context,
                            PageLoginRecovery(),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        child: Text(
                          'Регистрация',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        onTap: () {
                          navigateToPage(
                            context,
                            PagePatientRegister(
                              title: 'Регистрация',
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () => _navigateAndRefresh(context),
                        child: Text(
                          'Оценить качество жизни',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54, // Цвет текста
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      /// Тестовые кнопки
                      if (_isTest) ...[
                        InkWell(
                          onTap: () {
                            setState(() {
                              _login = 'piepim@mail.ru';
                              _password = '00112299p-';
                              // _login = 'fortest2@nitrosdata.com';
                              // _password = 'aSc47wCU';
                              _keys[Enum.login]!.currentState?.didChange(_login);
                              _keys[Enum.password]!
                                  .currentState
                                  ?.didChange(_password);
                            });
                          },
                          child: Text(
                            'ПАЦИЕНТ',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54, // Цвет текста
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _login = 'angara.pie@mail.ru';
                              _password = '123456';
                              _keys[Enum.login]!.currentState?.didChange(_login);
                              _keys[Enum.password]!
                                  .currentState
                                  ?.didChange(_password);
                            });
                          },
                          child: Text(
                            'ВРАЧ',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54, // Цвет текста
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
