import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/core/components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/core/components/error_message_form.dart';
import 'package:aplikasi_lkbh_unmul/core/components/error_message.dart';
import 'package:aplikasi_lkbh_unmul/features/Auth/services/auth_service.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
  bool _isRegisterLoading = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 150,
        leading: DefaultBackButton(),
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
                    "Daftar akun",
                    style: TextTheme.of(context).titleLarge?.copyWith(
                      color: KPrimaryColor
                    )
                  ),
                  Text(
                    "Masukan akun gmail dan password untuk \n mendaftarkan diri anda",
                    style: TextTheme.of(context).bodyLarge,
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

                              setState(() {
                                _isRegisterLoading = true;
                              });

                              try {
                                final auth = AuthService();

                                await Future.delayed(Duration(seconds: 3));

                                // Register user
                                await auth.registerWithEmailAndPassword(
                                  _emailController.text,
                                  _pwController.text,
                                );

                                final user = auth.getCurrentUser();
                                if (user != null && !user.emailVerified) {
                                  if (!user.emailVerified) {
                                    if (mounted) {
                                      setState(() {
                                        _isRegisterLoading = false;
                                      });
                                      Navigator.pushReplacementNamed(context, "/verify");
                                    }
                                    return;
                                  }
                                }

                                if (mounted) {
                                  setState(() {
                                    _isRegisterLoading = false;
                                  });
                                  Navigator.pushReplacementNamed(context, "/complete_profile");
                                }
                              } catch (e) {
                                setState(() {
                                  _isRegisterLoading = false;
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
                          isLoading: _isRegisterLoading, 
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