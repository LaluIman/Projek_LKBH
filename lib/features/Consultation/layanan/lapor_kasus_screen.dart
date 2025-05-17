import 'dart:convert';
import 'dart:io';
import 'package:aplikasi_lkbh_unmul/core/components/custom_snackbar.dart';
import 'package:aplikasi_lkbh_unmul/core/components/custom_alertdialog.dart';
import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/core/components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/components/consultation_provider.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class LaporScreen extends StatefulWidget {
  static String routeName = "/laporKasusScreen";
  const LaporScreen({super.key});

  @override
  State<LaporScreen> createState() => _LaporScreenState();
}

class _LaporScreenState extends State<LaporScreen> {
  final TextEditingController _reporterController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reportedController = TextEditingController();
  final TextEditingController _reportController = TextEditingController();

  XFile? _ktpImage;
  bool _isSubmitting = false;
  bool _isLoadingUserData = true;
  bool _isAgreedCheckBox = false;
  bool _isAgreedFromKaltim = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    setState(() {
      _isLoadingUserData = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          if (mounted) {
            setState(() {
              _reporterController.text = doc['nama'] ?? '';
              _numberController.text = doc['telepon'] ?? '';
              _addressController.text = doc['alamat'] ?? '';
              _isLoadingUserData = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoadingUserData = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingUserData = false;
          });
          print("Error fetching user data: $e");
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
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

  // Added showExitDialog function
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

  // Added form validation function
  bool _isFormValid() {
    return _reporterController.text.isNotEmpty &&
        _numberController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _reportedController.text.isNotEmpty &&
        _reportController.text.isNotEmpty &&
        _ktpImage != null &&
        _isAgreedCheckBox &&
        _isAgreedFromKaltim;
  }

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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _ktpImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> _submitReport() async {
    final user = FirebaseAuth.instance.currentUser;
    final selected = Provider.of<ConsultationProvider>(context, listen: false)
        .selectedConsultation;

    if (user == null || _ktpImage == null) {
      DefaultCustomSnackbar.buildSnackbar(
          context, "Mohon lengkapi semua data dan upload KTP!", KError);
      return;
    }

    if (_reporterController.text.isEmpty ||
        _numberController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _reportedController.text.isEmpty ||
        _reportController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mohon lengkapi semua data formulir.")));
      return;
    }

    if (selected == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Layanan belum dipilih.")));
      return;
    }

    if (!_isAgreedCheckBox) {
      DefaultCustomSnackbar.buildSnackbar(
          context, "Silakan centang persetujuan terlebih dahulu.", KError);
      return;
    }

    if (!_isAgreedFromKaltim) {
      DefaultCustomSnackbar.buildSnackbar(
          context,
          "Silakan centang kotak bahwa anda tinggal di provinsi Kalimantan Timur",
          KError);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ktpCompressed = await compressImage(File(_ktpImage!.path));
      final ktpBase64 = base64Encode(ktpCompressed);

      await FirebaseFirestore.instance.collection('laporan_kasus').add({
        'uid': user.uid,
        'nama_pelapor': _reporterController.text,
        'telepon': _numberController.text,
        'alamat': _addressController.text,
        'layanan': selected.name,
        'nama_terlapor': _reportedController.text,
        'isi_laporan': _reportController.text,
        'ktp_image': ktpBase64,
        'timestamp': FieldValue.serverTimestamp()
      });

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        Navigator.pushNamed(context, "/terlaporkan");
      }
    } catch (e) {
      print("🔥 ERROR: $e");

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        DefaultCustomSnackbar.buildSnackbar(
            context, "Gagal mengirim laporan. Silakan coba lagi.", KError);
      }
    }
  }

  Widget buildLoadingTextField({
    required TextEditingController controller,
    required String label,
    required String iconPath,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return _isLoadingUserData
        ? TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: label,
              hintText: "Memuat data...",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(iconPath),
              ),
              suffixIcon: SizedBox(
                width: 20,
                height: 20,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(KPrimaryColor),
                    ),
                  ),
                ),
              ),
            ),
          )
        : TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              labelText: label,
              hintStyle: TextStyle(fontWeight: FontWeight.w500),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(iconPath),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final selected =
        Provider.of<ConsultationProvider>(context).selectedConsultation;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
            leadingWidth: 150,
            automaticallyImplyLeading: false,
            leading: _isSubmitting
                ? SizedBox()
                : DefaultBackButton(
                    onPressed: () async {
                      // Custom logic before going back
                      final shouldPop = await _showExitDialog(context);
                      if (shouldPop && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  )),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Laporan Kasus Hukum",
                  style: TextTheme.of(context)
                      .titleLarge
                      ?.copyWith(color: KPrimaryColor),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "Jenis konsultasi: ",
                      style: TextTheme.of(context)
                          .titleSmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                    Text(
                      selected!.name,
                      style: TextTheme.of(context).titleSmall?.copyWith(
                          color: KPrimaryColor, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Text(
                  "Isi semua formulir dibawah ini sepeti yang di minta.",
                  style: TextTheme.of(context).bodyLarge,
                ),
                SizedBox(
                  height: 40,
                ),
                buildLoadingTextField(
                    controller: _reporterController,
                    label: "Nama Lengkap Pelapor",
                    iconPath: "assets/icons/User Icon.svg"),
                SizedBox(
                  height: 7,
                ),
                buildLoadingTextField(
                    controller: _numberController,
                    label: "Nomor Telepon",
                    iconPath: "assets/icons/Telepon Icon.svg",
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                SizedBox(
                  height: 7,
                ),
                buildLoadingTextField(
                    controller: _addressController,
                    label: "Alamat",
                    iconPath: "assets/icons/Address Icon.svg"),
                SizedBox(
                  height: 20,
                ),
                Text("Upload KTP",
                    style: TextTheme.of(context)
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                SizedBox(
                  height: 12,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                        color: KGray, borderRadius: BorderRadius.circular(10)),
                    child: _ktpImage == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/icons/Upload KTP.svg", width: 80,),
                                SizedBox(height: 10),
                                Text(
                                  "Format png, jpg, jpeg",
                                  style:  TextTheme.of(context)
                                    .bodyMedium?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500
                                    )
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/icons/KTP Upload.svg", width: 80,),
                                SizedBox(height: 10),
                                Text(
                                  "Foto telah diupload!",
                                  style: TextTheme.of(context)
                                    .bodySmall?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500
                                    )
                                ),
                                SizedBox(height: 3),
                                Text(
                                  "Upload ulang?",
                                  style: TextTheme.of(context)
                                    .bodyMedium?.copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500
                                    )
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                TextFormField(
                    controller: _reportedController,
                    decoration: InputDecoration(
                      labelText: "Nama lengkap pihak yang dilaporkan",
                      hintText: "perorangan/badan usaha/badan hukum/instansi",
                      hintStyle: TextStyle(fontWeight: FontWeight.w500),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset("assets/icons/User Icon.svg"),
                      ),
                    )),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Masukkan laporan",
                  style: TextTheme.of(context)
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 12,
                ),
                TextField(
                  controller: _reportController,
                  maxLines: 10,
                  decoration: InputDecoration(
                      hintText:
                          "Sampaikan hal yang ingin Anda laporkan",
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700),
                      contentPadding: EdgeInsets.all(10)),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isAgreedCheckBox,
                      activeColor: KPrimaryColor,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreedCheckBox = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                          "Dengan ini saya menyatakan bahwa informasi yang saya berikan adalah benar dan dapat dipertanggungjawabkan.",
                          style: TextTheme.of(context)
                              .bodyMedium
                              ?.copyWith(color: Colors.black)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isAgreedFromKaltim,
                      activeColor: KPrimaryColor,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreedFromKaltim = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                          "Layanan Lapor kasus hanya berlaku untuk warga dengan domisili Kalimantan Timur.",
                          style: TextTheme.of(context)
                              .bodyMedium
                              ?.copyWith(color: Colors.black)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                DefaultButton(
                  text: "Kirim Laporan",
                  press: _isFormValid() ? () => _submitReport() : null,
                  bgcolor:
                      _isFormValid() ? KPrimaryColor : Colors.grey.shade400,
                  textColor: Colors.white,
                  isLoading: _isSubmitting,
                ),
                SizedBox(
                  height: 70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
