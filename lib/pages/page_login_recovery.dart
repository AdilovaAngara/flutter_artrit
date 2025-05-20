import 'package:artrit/api/api_login.dart';
import 'package:artrit/data/data_login_recovery.dart';
import 'package:artrit/theme.dart';
import 'package:flutter/material.dart';
import '../data/data_result.dart';
import '../roles.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_text.dart';
import '../widgets/input_text_obscure.dart';
import '../widgets/show_message.dart';

class PageLoginRecovery extends StatefulWidget {
  const PageLoginRecovery({super.key});

  @override
  State<PageLoginRecovery> createState() => _PageLoginRecoveryState();
}

class _PageLoginRecoveryState extends State<PageLoginRecovery> {
  /// API
  final ApiLogin _api = ApiLogin();

  /// Параметры
  bool _isLoading = false;
  String _login = '';
  String _code = '';
  String _password = '';
  String _repeatPassword = '';
  bool _showCodeForm = false;
  bool _showNewPasswordForm = false;
  bool _showSuccessForm = false;

  /// Ключи
  final _formKey = GlobalKey<FormState>();
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyCode = GlobalKey<FormState>();
  final _formKeyNewPassword = GlobalKey<FormState>();
  final Map<Enum, GlobalKey<FormFieldState>> _keys = {
    for (var e in Enum.values) e: GlobalKey<FormFieldState>(),
  };

  void _sendEmail(bool hasEmptyInputs) async {
    if (hasEmptyInputs) {
      showTopBanner(context: context);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    DataResult2 result = await _requestEmail();
    setState(() {
      _isLoading = false;
    });
    if (!result.success) {
      ShowMessage.show(context: context, message: result.message ?? 'Неизвестная ошибка');
    } else {
      _showCodeForm = true;
    }
  }

  void _sendCode(bool hasEmptyInputs) async {
    if (hasEmptyInputs) {
      showTopBanner(context: context);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    DataResult2 result = await _requestCode();
    setState(() {
      _isLoading = false;
    });
    if (!result.success) {
      ShowMessage.show(context: context, message: result.message ?? 'Неизвестная ошибка');
    } else {
      _showNewPasswordForm = true;
    }
  }

  void _sendNewPassword(bool hasEmptyInputs) async {
    if (hasEmptyInputs) {
      showTopBanner(context: context);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    DataResult2 result = await _requestNewPassword();
    setState(() {
      _isLoading = false;
    });
    if (!result.success) {
      ShowMessage.show(context: context, message: result.message ?? 'Неизвестная ошибка');
    } else {
      _showSuccessForm = true;
    }
  }

  Future<DataResult2> _requestEmail() async {
    DataLoginRecovery thisData = DataLoginRecovery(email: _login);
    return await _api.putEmail(thisData: thisData);
  }

  Future<DataResult2> _requestCode() async {
    DataLoginCode thisData = DataLoginCode(token: _code);
    return await _api.putCode(thisData: thisData);
  }

  Future<DataResult2> _requestNewPassword() async {
    DataLoginNewPassword thisData = DataLoginNewPassword(
        token: _code, pswd: _password, pswdRepeat: _repeatPassword);
    return await _api.putNewPassword(thisData: thisData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Восстановление пароля',
        showMenu: false,
        showChat: false,
        showNotifications: false,
      ),
      body: _showSuccessForm
          ? Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Восстановление пароля прошло успешно!',
                        style: inputTextStyle,
                        maxLines: 3,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_showNewPasswordForm) _buildEmailForm(),
                        if (_showCodeForm && !_showNewPasswordForm)
                          _buildCodeForm(),
                        if (_showNewPasswordForm) _buildPasswordForm(),
                      ]),
                ),
              ),
            ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKeyEmail,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          InputText(
            fieldKey: _keys[Enum.login]!,
            labelText: !_showCodeForm
                ? 'Введите e-mail, указанный при регистрации'
                : 'Введите код подтверждения, отправленный на почту',
            value: _login,
            required: true,
            readOnly: _showCodeForm,
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
          if (!_showCodeForm) SizedBox(height: 20),
          if (!_showCodeForm)
            Container(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: ButtonWidget(
                  labelText: 'Продолжить',
                  showProgressIndicator: _isLoading,
                  listRoles: Roles.all,
                  onPressed: () {
                    _sendEmail(!_formKeyEmail.currentState!.validate());
                  },
                ),
              ),
            ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCodeForm() {
    return Form(
      key: _formKeyCode,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          InputText(
            fieldKey: _keys[Enum.code]!,
            labelText: 'Код подтверждения',
            value: _code,
            required: true,
            border: OutlineInputBorder(),
            listRoles: Roles.all,
            onChanged: (value) {
              setState(() {
                _code = value;
              });
            },
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: ButtonWidget(
                labelText: 'Продолжить',
                showProgressIndicator: _isLoading,
                listRoles: Roles.all,
                onPressed: () {
                  _sendCode(!_formKeyCode.currentState!.validate());
                },
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _formKeyNewPassword,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          InputTextObscure(
            fieldKey: _keys[Enum.password]!,
            labelText: 'Введите новый пароль',
            value: _password,
            required: true,
            border: OutlineInputBorder(),
            onChanged: (value) {
              setState(() {
                _password = value;
              });
            },
          ),
          SizedBox(
            height: 20,
          ),
          InputTextObscure(
            fieldKey: _keys[Enum.repeatPassword]!,
            labelText: 'Подтвердите новый пароль',
            value: _repeatPassword,
            required: true,
            border: OutlineInputBorder(),
            onChanged: (value) {
              setState(() {
                _repeatPassword = value;
              });
            },
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: ButtonWidget(
                labelText: 'Сохранить новый пароль',
                showProgressIndicator: _isLoading,
                listRoles: Roles.all,
                onPressed: () {
                  if (_password != _repeatPassword) {
                    ShowMessage.show(context: context, message: 'Пароли не совпадают');
                  } else {
                    _sendNewPassword(
                        !_formKeyNewPassword.currentState!.validate());
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
