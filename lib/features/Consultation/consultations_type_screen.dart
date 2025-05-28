import 'package:aplikasi_lkbh_unmul/core/components/custom_tooltip.dart';
import 'package:aplikasi_lkbh_unmul/core/services/double_tap_exit.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/components/Layanan_button.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/components/consultation_provider.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/model.dart';
import 'package:aplikasi_lkbh_unmul/core/services/token_service.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ConsultationScreen extends StatefulWidget {
  static String routeName = "/consultation";
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final TokenService _tokenService = TokenService();
  int _tokensLeft = 0;
  bool _isLoadingTokens = true;

  @override
  void initState() {
    super.initState();
    _loadTokenData();
  }

  Future<void> _loadTokenData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _tokensLeft = 0;
            _isLoadingTokens = false;
          });
        }
        return;
      }

      Map<String, dynamic>? cachedTokens = _tokenService.getCachedTokens(user.uid);
      if (cachedTokens != null && mounted) {
        setState(() {
          _tokensLeft = cachedTokens['tokensLeft'];
          _isLoadingTokens = false;
        });
      }

      Map<String, dynamic> tokenData = await _tokenService.getUserTokens(user.uid);

      if (mounted) {
        setState(() {
          _tokensLeft = tokenData['tokensLeft'];
          _isLoadingTokens = false;
        });
      }
    } catch (e) {
      print('Error loading token data: $e');
      if (mounted) {
        setState(() {
          _tokensLeft = 0;
          _isLoadingTokens = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoubleTapBackExit(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
              child: SizedBox(
            width: double.infinity,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Jenis Konsultasi",
                                    style: TextTheme.of(context).titleLarge),
                                Text(
                                  "Pilih jenis konsultasi sesuai kebutuhan kamu",
                                  style: TextTheme.of(context).bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          CustomTooltip(
                            message:
                                '⚠️ Anda mendapat 3 token per hari untuk layanan hukum.\nGunakan dengan bijak. Token akan reset setiap hari.',
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: KPrimaryColor,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  _isLoadingTokens
                                      ? SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          "$_tokensLeft",
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white),
                                        ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 40),
                      GridView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 5,
                          ),
                          itemCount: ConsultationType.listConsultationType.length,
                          itemBuilder: (context, index) {
                            final consultationType =
                                ConsultationType.listConsultationType[index];
                            return JenisKonsultasiItem(
                                consultationType: consultationType,
                                tokensLeft: _tokensLeft,
                                onTokenChanged: _loadTokenData);
                          })
                    ],
                  ),
                )),
          ))),
    );
  }
}

class JenisKonsultasiItem extends StatelessWidget {
  const JenisKonsultasiItem({
    super.key,
    required this.consultationType,
    required this.tokensLeft,
    required this.onTokenChanged,
  });

  final ConsultationType consultationType;
  final int tokensLeft;
  final Function() onTokenChanged;

  Future<void> _showTokenWarning(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          titleTextStyle: TextStyle(
              color: KPrimaryColor, fontWeight: FontWeight.w600, fontSize: 20),
          contentTextStyle: TextStyle(
            color: Colors.black,
          ),
          title: Text('Token Habis!'),
          content: Text(
              "Maaf, token harian Anda telah habis! \nToken anda akan di perbarui diesok hari."),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    "Tutup",
                    style: TextStyle(
                        color: KPrimaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTokens = tokensLeft > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () async {
            if (!hasTokens) {
              await _showTokenWarning(context);
              return;
            }
            Provider.of<ConsultationProvider>(context, listen: false)
                .setSelectedConsultation(consultationType);

            showModalBottomSheet(
              context: context,
              isDismissible: true,
              enableDrag: true,
              builder: (BuildContext context) {
                return SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LayananButton(
                          onStartConsultation: () async {
                            final tokenService = TokenService();
                            final user = FirebaseAuth.instance.currentUser;

                            if (user != null) {
                              try {
                                await tokenService.consumeToken(user.uid);
                                onTokenChanged();
                              } catch (e) {
                                print('Error consuming token: $e');
                              }
                            }
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SvgPicture.asset(
                allowDrawingOutsideViewBox: true,
                errorBuilder: (context, error, StackTrace) {
                  print("SVG Loading error: $error");
                  return Icon(
                    Icons.error_outline,
                    color: KPrimaryColor,
                  );
                },
                consultationType.icon,
                fit: BoxFit.contain,
                placeholderBuilder: (context) => Icon(
                  Icons.image,
                  color: KPrimaryColor,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          consultationType.name,
          textAlign: TextAlign.center,
          style: TextTheme.of(context)
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        )
      ],
    );
  }
}
