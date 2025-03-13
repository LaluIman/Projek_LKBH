import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/services/auth_service.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  static String routeName = "/account";
  AccountScreen({super.key});
  final _auth = AuthService();

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
                Text(_auth.getCurrentUser()!.email.toString()),
                DefaultButton(
                  text: "Keluar", 
                  press: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Konfirmasi"),
                          content: Text("Apakah Anda ingin keluar?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Batal"),
                            ),
                            TextButton(
                              onPressed: () async{
                                final _auth = AuthService();
                                _auth.signOut();
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
                                Navigator.pushReplacementNamed(context, "/login");
                              },
                              child: Text("Keluar"),
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