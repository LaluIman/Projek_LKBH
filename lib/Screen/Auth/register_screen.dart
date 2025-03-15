import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/Components/error_message_form.dart';
import 'package:aplikasi_lkbh_unmul/error_message.dart';
import 'package:aplikasi_lkbh_unmul/services/auth_service.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegisterScreen extends StatefulWidget {
  static String routeName = "/register";
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  String? errorMessage;
  bool _isPasswordVisible = true;
  bool _isConfirmPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              SizedBox(
                width: 6,
              ),
              Icon(Icons.arrow_back_ios_new, color: KPrimaryColor),
              SizedBox(
                width: 3,
              ),
              Text(
                "Kembali",
                style: TextStyle(
                    fontSize: 16,
                    color: KPrimaryColor,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Daftar di Konsulhukum",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: KPrimaryColor,
                    ),
                  ),
                  Text(
                    "Masukan akun gmail dan password untuk \n mendaftarkan diri anda",
                    style: TextStyle(color: KGray),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        gmailForm(),
                        SizedBox(height: 10),
                        passwordForm(),
                        SizedBox(height: 10),
                        confirmPasswordForm(),
                        if (errorMessage != null) ...[
                          SizedBox(height: 15),
                          ErrorMessageForm(errors: [errorMessage!]),
                        ],
                        SizedBox(height: 30),
                        DefaultButton(
                          text: "Daftar",
                          press: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              if (_pwController.text !=
                                  _confirmPwController.text) {
                                setState(() {
                                  errorMessage =
                                      "Password dan konfirmasi password tidak sama";
                                });
                                return;
                              }

                              try {
                                final _auth = AuthService();

                                // Show loading dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        LoadingAnimationWidget.inkDrop(
                                            color: KPrimaryColor, size: 70),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "Mendaftar akun baru...",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.none),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                await Future.delayed(Duration(seconds: 3));

                                // Register user
                                await _auth.registerWithEmailAndPassword(
                                  _emailController.text,
                                  _pwController.text,
                                );

                                Navigator.pop(context);

                                Navigator.pushReplacementNamed(
                                    context, "/complete_profile");
                              } catch (e) {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }

                                setState(() {
                                  errorMessage = e
                                      .toString()
                                      .replaceAll("Exception:", "")
                                      .trim();
                                });
                              }
                            }
                          },
                          bgcolor: KPrimaryColor,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField gmailForm() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return kEmailNullError;
        } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@gmail\.com$").hasMatch(value)) {
          return "Hanya boleh menggunakan Gmail";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          return kInvalidEmailError;
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.all(10),
          child: SvgPicture.asset("assets/icons/Mail Icon.svg"),
        ),
        labelText: "Akun Gmail",
        hintText: "example@gmail.com",
      ),
    );
  }

  TextFormField passwordForm() {
    return TextFormField(
      controller: _pwController,
      obscureText: _isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return kPassNullError;
        } else if (value.length < 8) {
          return kShortPassError;
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.all(10),
          child: SvgPicture.asset("assets/icons/Lock Icon.svg"),
        ),
        labelText: "Password",
        hintText: "Buat password minimal 8 karakter",
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          icon: _isPasswordVisible
              ? SvgPicture.asset("assets/icons/Eye Open.svg")
              : SvgPicture.asset("assets/icons/Eye Close.svg"),
        ),
      ),
    );
  }

  TextFormField confirmPasswordForm() {
    return TextFormField(
      controller: _confirmPwController,
      obscureText: _isConfirmPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Konfirmasi password tidak boleh kosong";
        } else if (value != _pwController.text) {
          return "Password tidak sama";
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.all(10),
          child: SvgPicture.asset("assets/icons/Lock Icon.svg"),
        ),
        labelText: "Konfirmasi Password",
        hintText: "Masukkan kembali password",
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
          icon: _isConfirmPasswordVisible
              ? SvgPicture.asset("assets/icons/Eye Open.svg")
              : SvgPicture.asset("assets/icons/Eye Close.svg"),
        ),
      ),
    );
  }
}
