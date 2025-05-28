import 'package:aplikasi_lkbh_unmul/core/components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/core/components/error_message_form.dart';
import 'package:aplikasi_lkbh_unmul/features/Auth/register_screen.dart';
import 'package:aplikasi_lkbh_unmul/core/components/error_message.dart';
import 'package:aplikasi_lkbh_unmul/features/Auth/services/auth_service.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
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
  bool _isManualLoading = false;
  bool _isGoogleLoading = false;

  String? image1;

  @override
  void initState() {
    super.initState();
    image1 = "assets/images/login_image.png";
  }

  @override
  void didChangeDependencies() {
    if (image1 != null) {
      precacheImage(Image.asset(image1!).image, context);
    }
    super.didChangeDependencies();
  }

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
                const SizedBox(height: 20),
                Text(
                  "Selamat datang di",
                  style: TextTheme.of(context).titleSmall,
                ),
                Text("HukumUnmul",
                    style: TextTheme.of(context).titleLarge?.copyWith(
                        color: KPrimaryColor, fontWeight: FontWeight.w800)),
                Text(
                  "Lanjut dengan Gmail dan Password \n atau masuk menggunakan Google.",
                  style: TextTheme.of(context).bodyLarge,
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: image1 != null ? Image.asset(image1!) : SizedBox(
                    width: double.infinity,
                    height: 400,
                  ),
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

                                setState(() {
                                  _isManualLoading = true;
                                });

                                try {
                                  final auth0 = AuthService();
                                  await auth0.signInWithEmailAndPassword(
                                    _emailController.text,
                                    _pwController.text,
                                  );

                                  await Future.delayed(
                                      const Duration(seconds: 3));

                                  if (mounted) {
                                    setState(() {
                                      _isManualLoading = false;
                                    });
                                    Navigator.pushReplacementNamed(
                                        context, "/custom_navigation_bar");
                                  }
                                } catch (e) {
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
                            isLoading: _isManualLoading,
                          ),
                          const SizedBox(height: 10),
                          TextDivider(
                              text: Text(
                            "Atau",
                            style: TextTheme.of(context).bodySmall,
                          )),
                          const SizedBox(height: 10),
                          DefaultButton(
                            text: "Masuk dengan Google",
                            press: () async {
                              // Reset error message sebelum login
                              setState(() {
                                _isGoogleLoading = true;
                                errorMessage = null;
                              });

                              try {
                                print("Memulai proses Google Sign In...");
                                final auth = AuthService();
                                final result = await auth.signInWithGoogle();

                                if (result == null) {
                                  // User membatalkan login atau ada masalah
                                  print("Google Sign In dibatalkan atau gagal");
                                  if (mounted) {
                                    setState(() {
                                      _isGoogleLoading = false;
                                      // Tidak perlu menampilkan error jika user membatalkan
                                    });
                                  }
                                  return;
                                }

                                print("Google Sign In berhasil, memproses navigasi...");

                                if (mounted) {
                                  setState(() {
                                    _isGoogleLoading = false;
                                  });
                                }

                                // Cek apakah user berhasil login
                                final user = auth.getCurrentUser();
                                if (user != null) {
                                  print("User berhasil login: ${user.email}");
                                  
                                  // Cek apakah profil user sudah lengkap
                                  bool needsCompletion = await auth.needsProfileCompletion(user.uid);
                                  print("Needs profile completion: $needsCompletion");
                                  
                                  if (needsCompletion) {
                                    print("Navigasi ke complete profile...");
                                    // Jika profil belum lengkap, ke halaman complete profile
                                    Navigator.pushReplacementNamed(
                                        context, "/complete_profile");
                                  } else {
                                    print("Navigasi ke halaman utama...");
                                    // Jika profil sudah lengkap, langsung ke halaman utama
                                    Navigator.pushReplacementNamed(
                                        context, "/custom_navigation_bar");
                                  }
                                } else {
                                  print("Error: User null setelah login");
                                  // Jika user null, ada masalah
                                  setState(() {
                                    errorMessage = "Login gagal. Silakan coba lagi.";
                                  });
                                }

                              } catch (e) {
                                print("Error Google Sign In: $e");
                                if (mounted) {
                                  setState(() {
                                    _isGoogleLoading = false;
                                    errorMessage = e
                                        .toString()
                                        .replaceAll("Exception:", "")
                                        .trim();
                                  });
                                }
                              }
                            },
                            bgcolor: KGoogleButton,
                            textColor: Colors.black,
                            icon: "assets/icons/Google Icon.svg",
                            isLoading: _isGoogleLoading,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Belum ada akun? ",
                                style: TextTheme.of(context).bodyLarge,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, RegisterScreen.routeName);
                                },
                                child: Text(
                                  "Daftar sekarang!",
                                  style: TextTheme.of(context).bodyLarge?.copyWith(
                                    color: KPrimaryColor
                                  ),
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