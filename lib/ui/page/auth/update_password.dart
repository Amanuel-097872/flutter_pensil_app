import 'package:flutter/material.dart';
import 'package:flutter_pensil_app/config/config.dart';
import 'package:flutter_pensil_app/helper/shared_prefrence_helper.dart';
import 'package:flutter_pensil_app/helper/utility.dart';
import 'package:flutter_pensil_app/states/auth/auth_state.dart';
import 'package:flutter_pensil_app/ui/kit/alert.dart';
import 'package:flutter_pensil_app/ui/page/auth/login.dart';
import 'package:flutter_pensil_app/ui/theme/theme.dart';
import 'package:flutter_pensil_app/ui/widget/form/p_textfield.dart';
import 'package:flutter_pensil_app/ui/widget/p_button.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class UpdatePasswordPage extends StatefulWidget {
  UpdatePasswordPage({Key key}) : super(key: key);

  static MaterialPageRoute getRoute() {
    return MaterialPageRoute(
      builder: (_) => UpdatePasswordPage(),
    );
  }

  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController confirmPassword;
  TextEditingController password;

  ValueNotifier<bool> passwordVisibility = ValueNotifier<bool>(true);
  ValueNotifier<bool> confirmPasswordVisibility = ValueNotifier<bool>(true);

  @override
  void initState() {
    confirmPassword = TextEditingController();
    password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    isLoading.dispose();
    password.dispose();
    confirmPassword.dispose();
    passwordVisibility.dispose();
    confirmPasswordVisibility.dispose();
    super.dispose();
  }

  Widget _title(String text) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            .copyWith(fontSize: 26, color: Colors.white),
      ),
    );
  }

  Positioned _background(BuildContext context) {
    return Positioned(
      top: -AppTheme.fullHeight(context) * .5,
      left: -AppTheme.fullWidth(context) * .55,
      child: Container(
        height: AppTheme.fullHeight(context),
        width: AppTheme.fullHeight(context),
        decoration: BoxDecoration(
            color: PColors.secondary,
            borderRadius: BorderRadius.circular(500),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Theme.of(context).dividerColor,
                  offset: Offset(0, 4),
                  blurRadius: 5)
            ]),
      ),
    );
  }

  void _submit(BuildContext context) async {
    try {
      final isValidate = _formKey.currentState.validate();
      if (!isValidate) {
        return;
      }
      if (password.text != confirmPassword.text) {
        Utility.displaySnackbar(context,
            msg: "Confirm password and password did not match",
            key: scaffoldKey);
        return;
      }
      FocusManager.instance.primaryFocus.unfocus();
      final state = Provider.of<AuthState>(context, listen: false);
      state.setPassword = password.text;
      isLoading.value = true;
      final isSucess = await state.updateUser();
      checkPasswordStatus(isSucess);
    } catch (error) {
      print("SCreen ${error.message}");
      Utility.displaySnackbar(context, msg: error.message, key: scaffoldKey);
    }
    isLoading.value = false;
  }

  void checkPasswordStatus(bool isSucess) async {
    if (isSucess) {
      final getIt = GetIt.instance;
      final prefs = getIt<SharedPrefrenceHelper>();
      final isStudent = await prefs.isStudent();
      Alert.sucess(context,
          message: "Your password is updated. Please login to continue",
          title: "Message",
          height: 170, onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          // isStudent ? StudentHomePage.getRoute() : TeacherHomePage.getRoute(),
          LoginPage.getRoute(),
          (_) => false,
        );
      });
    } else {
      Alert.sucess(context,
          message: "Some error occured. Please try again in some time!!",
          title: "Message",
          height: 170);
    }
  }

  Widget _form(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: AppTheme.fullWidth(context) - 32,
      margin: EdgeInsets.symmetric(vertical: 32) + EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0xffeaeaea),
            offset: Offset(4, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SizedBox(height: 30),
            Image.asset(AppConfig.of(context).config.appIcon, height: 150),
            // Image.asset(Images.logoText, height: 30),
            SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: passwordVisibility,
              builder: (context, value, child) {
                return PTextField(
                    type: Type.password,
                    controller: password,
                    label: "New password",
                    hintText: "Enter new password",
                    height: null,
                    obscureText: value,
                    suffixIcon: IconButton(
                      onPressed: () {
                        passwordVisibility.value = !passwordVisibility.value;
                      },
                      icon:
                          Icon(value ? Icons.visibility_off : Icons.visibility),
                    )).hP16;
              },
            ),
            SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: confirmPasswordVisibility,
              builder: (context, value, child) {
                return PTextField(
                    type: Type.password,
                    controller: confirmPassword,
                    label: "Confirm password",
                    hintText: "Enter confirm password here",
                    height: null,
                    obscureText: value,
                    suffixIcon: IconButton(
                      onPressed: () {
                        confirmPasswordVisibility.value =
                            !confirmPasswordVisibility.value;
                      },
                      icon:
                          Icon(value ? Icons.visibility_off : Icons.visibility),
                    )).hP16;
              },
            ),

            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: PFlatButton(
                label: "Update",
                color: PColors.secondary,
                isLoading: isLoading,
                onPressed: () {
                  _submit(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        height: AppTheme.fullHeight(context),
        child: SafeArea(
          top: false,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _background(context),
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 120),
                      _title("Update Password"),
                      _form(context),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
