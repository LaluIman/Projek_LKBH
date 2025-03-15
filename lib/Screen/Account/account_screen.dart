import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/services/auth_service.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AccountScreen extends StatelessWidget {
  static String routeName = "/account";
  AccountScreen({super.key});
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(auth.getCurrentUser()!.email.toString()),
                SizedBox(height: 15,),
                DefaultButton(
                  icon: "assets/icons/Log out.svg",
                  text: "Keluar dari akun ini", 
                  press: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          titleTextStyle: TextStyle(
                            color: KPrimaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 20
                          ),
                          contentTextStyle: TextStyle(
                            color: Colors.black,
                          ),
                          title: Text("Konfirmasi"),
                          content: Text("Apakah Anda ingin keluar?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Batal", style: TextStyle(
                                color: Colors.black
                              ),),
                            ),
                            TextButton(
                              onPressed: () async{
                                final auth = AuthService();
                                auth.signOut();
                                // Tampilkan loading selama 3 detik
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          LoadingAnimationWidget.inkDrop(
                                            color: KPrimaryColor,
                                            size: 70
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            "Keluar dari akun...",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                decoration:
                                                    TextDecoration.none),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                  await Future.delayed(const Duration(seconds: 3));

                                  Navigator.pop(context);
                                Navigator.pushReplacementNamed(context, "/login");
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text("Keluar", style: TextStyle(
                                  color: KPrimaryColor,
                                  fontWeight: FontWeight.w600
                                ),),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }, 
                  bgcolor: KPrimaryColor, 
                  textColor: Colors.white
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}