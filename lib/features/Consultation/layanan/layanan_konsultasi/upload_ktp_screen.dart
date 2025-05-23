import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:aplikasi_lkbh_unmul/core/components/custom_alertdialog.dart';
import 'package:aplikasi_lkbh_unmul/core/components/custom_snackbar.dart';
import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/core/components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/components/consultation_provider.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/layanan/layanan_konsultasi/services/consultation_service.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';

class UploadKTPScreen extends StatefulWidget {
  static String routeName = "/uploadKtp";
  const UploadKTPScreen({super.key});

  @override
  _UploadKTPScreenState createState() => _UploadKTPScreenState();
}

class _UploadKTPScreenState extends State<UploadKTPScreen> {
  XFile? _ktpImage;
  final ConsultationService _consultationService = ConsultationService();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<Uint8List> compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 600,
        minHeight: 600,
        quality: 40,
      );
      return result ?? await file.readAsBytes();
    } catch (e) {
      return await file.readAsBytes();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _ktpImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> _uploadKTP() async {
    if (_ktpImage == null) {
      DefaultCustomSnackbar.buildSnackbar(
          context, "Silakan pilih gambar KTP terlebih dahulu", KError);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final compressedImage = await compressImage(File(_ktpImage!.path));
      final base64Image = base64Encode(compressedImage);

      final consultationType =
          Provider.of<ConsultationProvider>(context, listen: false)
              .selectedConsultation!;

      if (consultationType.name.isEmpty) {
        throw Exception("Jenis konsultasi tidak valid");
      }

      final consultationId = await _consultationService
          .createConsultation(
        consultationType,
        base64Image,
      )
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception("Koneksi timeout, coba lagi nanti");
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            consultationId: consultationId,
            consultationType: consultationType.name,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        DefaultCustomSnackbar.buildSnackbar(
            context,
            "Gagal mengupload KTP: ${e.toString().contains("cloud_firestore") ? "Data tidak valid, periksa kembali informasi Anda" : e}",
            KError);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertdialog(
            title: "Batalkan Proses",
            content:
                "Apakah Anda yakin ingin keluar? Proses pengiriman laporan akan dibatalkan.",
            actions: [
              AlertDialogAction(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    "Batal",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              AlertDialogAction(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "Keluar",
                      style: TextStyle(
                          color: KPrimaryColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )
            ]);
      },
    );

    return shouldPop ?? false;
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    bool? exitConfirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertdialog(
            title: "Keluar?",
            content:
                "Apakah Anda yakin ingin keluar dari halaman ini? Data yang belum disimpan akan hilang.",
            actions: [
              AlertDialogAction(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    "Batal",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              AlertDialogAction(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "Keluar",
                      style: TextStyle(
                          color: KPrimaryColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )
            ]);
      },
    );

    return exitConfirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final consultationProvider = Provider.of<ConsultationProvider>(context);
    final consultationType = consultationProvider.selectedConsultation;

    if (consultationType == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return Container();
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 150,
          leading: _isSubmitting
              ? SizedBox()
              : DefaultBackButton(
                  onPressed: () async {
                    final shouldPop = await _showExitDialog(context);
                    if (shouldPop && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Layanan konsultasi hukum',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: KPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Jenis konsultasi: ",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        consultationType.name,
                        style: TextStyle(
                          fontSize: 18,
                          color: KPrimaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    "Sebelum kamu bisa lanjut ke tahap konsultasi, Upload KTP dan jelaskan permasalahanmu dulu ya",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    "Upload KTP",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                          color: KGray,
                          borderRadius: BorderRadius.circular(10)),
                      child: _ktpImage == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/Upload KTP.svg",
                                    width: 100,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Format png, jpg, jpeg(Maks 1MB)",
                                    style: TextTheme.of(context)
                                        .bodyMedium
                                        ?.copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/KTP Upload.svg",
                                    width: 100,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Foto telah diupload!",
                                    style: TextTheme.of(context)
                                        .bodySmall
                                        ?.copyWith(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    "Upload ulang?",
                                    style: TextTheme.of(context)
                                        .bodyMedium
                                        ?.copyWith(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 40),
                  DefaultButton(
                    text: "Lanjutkan",
                    press: _uploadKTP,
                    bgcolor: KPrimaryColor,
                    textColor: Colors.white,
                    isLoading: _isSubmitting,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
