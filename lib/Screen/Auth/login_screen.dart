import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/Components/error_message_form.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Auth/register_screen.dart';
import 'package:aplikasi_lkbh_unmul/error_message.dart';
import 'package:aplikasi_lkbh_unmul/services/auth_service.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_divider/text_divider.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/login";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  String? errorMessage;
  bool _isPasswordVisible = true;
  bool _isManualLoading = false; // Track loading for manual login
  bool _isGoogleLoading = false; // Track loading for Google login

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Selamat datang di",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Konsulhukum",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: KPrimaryColor,
                    height: 0,
                  ),
                ),
                const Text(
                  "Lanjut dengan Gmail dan Password \n atau masuk menggunakan Google.",
                  style: TextStyle(color: KGray),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("assets/images/login_image.png",fit: BoxFit.cover),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 70),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          gmailForm(),
                          const SizedBox(height: 10),
                          passwordForm(),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 10),
                            ErrorMessageForm(errors: [errorMessage!]),
                          ],
                          const SizedBox(height: 30),
                          DefaultButton(
                            text: "Masuk",
                            press: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                
                                // Set manual loading state to true
                                setState(() {
                                  _isManualLoading = true;
                                });
                                
                                try {
                                  final _auth = AuthService();
                                  await _auth.signInWithEmailAndPassword(
                                    _emailController.text,
                                    _pwController.text,
                                  );
                                  
                                  // Wait for 3 seconds before navigating
                                  await Future.delayed(const Duration(seconds: 3));
                                  
                                  // Reset loading state and navigate
                                  if (mounted) {
                                    setState(() {
                                      _isManualLoading = false;
                                    });
                                    Navigator.pushReplacementNamed(
                                        context, "/custom_navigation_bar");
                                  }
                                } catch (e) {
                                  // Reset loading state and show error
                                  setState(() {
                                    _isManualLoading = false;
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
                            isLoading: _isManualLoading, // Only use manual loading state
                          ),
                          const SizedBox(height: 10),
                          const TextDivider(text: Text("Atau")),
                          const SizedBox(height: 10),
                          DefaultButton(
                            text: "Masuk dengan Google",
                            press: () async {
                              // Set Google loading state to true
                              setState(() {
                                _isGoogleLoading = true;
                              });
                              
                              final _auth = AuthService();
                              final result = await _auth.signInWithGoogle();

                              if (result == null) {
                                setState(() {
                                  _isGoogleLoading = false;
                                });
                                return;
                              }

                              // Wait for 3 seconds before navigating
                              await Future.delayed(const Duration(seconds: 3));
                              
                              // Reset loading state
                              if (mounted) {
                                setState(() {
                                  _isGoogleLoading = false;
                                });
                              }

                              final user = _auth.getCurrentUser();
                              // Cek apakah user login dengan Google dan emailnya belum diverifikasi
                              if (user != null && !user.emailVerified) {
                                if (!user.emailVerified) {
                                  Navigator.pushReplacementNamed(context, "/verify");
                                  return;
                                }
                              }

                              Navigator.pushReplacementNamed(context, "/complete_profile");
                            },
                            bgcolor: KGoogleButton,
                            textColor: Colors.black,
                            icon: "assets/icons/Google Icon.svg",
                            isLoading: _isGoogleLoading, // Only use Google loading state
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Belum ada akun? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, RegisterScreen.routeName);
                                },
                                child: Text(
                                  "Daftar sekarang!",
                                  style: TextStyle(
                                      color: KPrimaryColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
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
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset("assets/icons/Lock Icon.svg"),
        ),
        labelText: "Password",
        hintText: "Masukan password",
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

  TextFormField gmailForm() {
    return TextFormField(
      controller: _emailController,
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
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset("assets/icons/Mail Icon.svg"),
        ),
        labelText: "Akun Gmail",
        hintText: "example@gmail.com",
      ),
    );
  }
}