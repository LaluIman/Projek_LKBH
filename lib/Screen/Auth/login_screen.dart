import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/Components/error_message_form.dart';
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
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Konsulhukum",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: KPrimaryColor,
                    height: 0,
                  ),
                ),
                const Text(
                  "Lanjut dengan Gmail dan Password \n atau masuk menggunakan Google.",
                  style: TextStyle(color: KGray),
                ),
                const SizedBox(height: 20),
                Image.asset("assets/images/Justice masbro.png", fit: BoxFit.cover),
                Container(
                  padding: const EdgeInsets.only(bottom: 70),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
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
                                try {
                                  final _auth = AuthService();
                                  await _auth.signInWithEmailAndPassword(
                                    _emailController.text,
                                    _pwController.text,
                                  );
                                  // Tampilkan loading selama 3 detik
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              color: KPrimaryColor,
                                              strokeWidth: 5,
                                              strokeAlign: 2,
                                            ),
                                            SizedBox(height: 20,),
                                            Text(
                                              "Sedang diproses...",
                                              style: TextStyle(
                                                color: KPrimaryColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                decoration: TextDecoration.none
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                  await Future.delayed(const Duration(seconds: 3));

                                  // Tutup loading dan navigasi ke halaman berikutnya
                                  Navigator.pop(context);
                                  // Jika login berhasil, arahkan ke halaman berikutnya
                                  Navigator.pushReplacementNamed(context, "/custom_navigation_bar");
                                } catch (e) {
                                  setState(() {
                                    errorMessage = e.toString().replaceAll("Exception:", "").trim();
                                  });
                                }
                              }
                            },
                            bgcolor: KPrimaryColor,
                            textColor: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          const TextDivider(text: Text("Atau")),
                          const SizedBox(height: 10),
                          DefaultButton(
                            text: "Masuk dengan Google",
                            press: () async {
                              final _auth = AuthService();
                              await _auth.signInWithGoogle();

                              // Tampilkan loading selama 3 detik
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              color: KPrimaryColor,
                                              strokeWidth: 5,
                                              strokeAlign: 2,
                                            ),
                                            SizedBox(height: 20,),
                                            Text(
                                              "Sedang Progres...",
                                              style: TextStyle(
                                                color: KPrimaryColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                decoration: TextDecoration.none
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                  await Future.delayed(const Duration(seconds: 3));
                                  // Tutup loading dan navigasi ke halaman berikutnya
                                  Navigator.pop(context);
                              
                              Navigator.pushReplacementNamed(context, "/complete_profile");
                            },
                            bgcolor: KGoogleButton,
                            textColor: Colors.black,
                            icon: "assets/icons/Google Icon.svg",
                          ),
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
        hintText: "Berikan password yang rumit",
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
