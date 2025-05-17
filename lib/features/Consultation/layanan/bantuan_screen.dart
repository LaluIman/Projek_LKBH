import 'dart:convert';
import 'dart:io';
import 'package:aplikasi_lkbh_unmul/core/components/custom_alertdialog.dart';
import 'package:aplikasi_lkbh_unmul/core/components/custom_snackbar.dart';
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
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class BantuanScreen extends StatefulWidget {
  static String routeName = "/bantuanHukumScreen";
  const BantuanScreen({
    super.key,
  });

  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  XFile? _ktpImage;
  File? _sktmFile;
  String? _sktmFileName;
  String? _days;
  String? _times;
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoadingUserData = true;
  bool _isAgreedCheckBox = false;

  List<Map<String, dynamic>> _availableDays = [];
  final Map<String, String> workDaysMap = {
    'Senin': 'Senin',
    'Selasa': 'Selasa',
    'Rabu': 'Rabu',
    'Kamis': 'Kamis',
    "Jum'at": "Jum'at",
  };

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _generateAvailableDays();
  }

  void _generateAvailableDays() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final workDays = ['Senin', 'Selasa', 'Rabu', 'Kamis', "Jum'at"];
    _availableDays = [];

    for (int i = 0; i < 5; i++) {
      final currentDate = firstDayOfWeek.add(Duration(days: i));

      if (currentDate.isAfter(now.subtract(Duration(days: 1)))) {
        final dayName = workDays[i];
        final formattedDate = DateFormat('dd/MM/yyyy').format(currentDate);

        _availableDays.add({
          'name': '$dayName, $formattedDate',
          'date': currentDate,
          'value': workDaysMap[dayName],
        });
      }
    }

    if (_availableDays.isEmpty) {
      _availableDays.add({
        'name': 'Tidak ada jadwal tersedia minggu ini',
        'date': now,
        'value': null,
      });
    }
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
              _namaController.text = doc['nama'] ?? '';
              _teleponController.text = doc['telepon'] ?? '';
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
                "Apakah Anda yakin ingin keluar? Proses pengajuan akan dibatalkan.",
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

  bool _isFormValid() {
    return _namaController.text.isNotEmpty &&
        _teleponController.text.isNotEmpty &&
        _ktpImage != null &&
        _sktmFile != null &&
        _days != null &&
        _times != null &&
        _isAgreedCheckBox;
  }

  Future<void> _pickImage(bool isKTP) async {
    if (isKTP) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        // Changed to 1MB for KTP images
        if (fileSize > 1 * 1024 * 1024) {
          if (mounted) {
            DefaultCustomSnackbar.buildSnackbar(context,
                "Ukuran foto KTP terlalu besar. Maksimal 1MB.", KError);
          }
          return;
        }

        setState(() {
          _ktpImage = XFile(pickedFile.path);
        });
      }
    } else {
      // Pick file for SKTM with 1MB limit
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Changed to 1MB limit for SKTM
        if (fileSize > 1 * 1024 * 1024) {
          if (mounted) {
            DefaultCustomSnackbar.buildSnackbar(
                context,
                "Ukuran file SKTM terlalu besar. Maksimal 1MB. Silakan kompres file Anda terlebih dahulu.",
                KError);
          }
          return;
        }

        setState(() {
          _sktmFile = File(result.files.single.path!);
          _sktmFileName = result.files.single.name;
        });
      }
    }
  }

  Future<Uint8List> compressImage(File file) async {
    try {
      final fileSize = await file.length();
      print("Original image size: ${fileSize / 1024}KB");

      // Very aggressive compression for large files
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 600,
        minHeight: 600,
        quality:
            fileSize > 1024 * 1024 ? 20 : 40, // Lower quality for larger files
        rotate: 0,
      );

      if (result != null) {
        print("Compressed image size: ${result.length / 1024}KB");
        return result;
      }

      return await file.readAsBytes();
    } catch (e) {
      print("Compression error: $e");
      return await file.readAsBytes();
    }
  }

  bool isImageFile(String filename) {
    final extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];
    final lowercaseName = filename.toLowerCase();
    return extensions.any((ext) => lowercaseName.endsWith(ext));
  }

  Future<void> _submitData() async {
    final user = FirebaseAuth.instance.currentUser;
    final selected = Provider.of<ConsultationProvider>(context, listen: false)
        .selectedConsultation;

    if (user == null || _ktpImage == null || _sktmFile == null) {
      DefaultCustomSnackbar.buildSnackbar(
          context, "Mohon lengkapi semua data dan upload dokumen.", KError);
      return;
    }

    if (_days == null || _times == null) {
      DefaultCustomSnackbar.buildSnackbar(
          context, "Silakan pilih hari dan waktu janji temu!", KError);
      return;
    }

    if (_namaController.text.isEmpty || _teleponController.text.isEmpty) {
      DefaultCustomSnackbar.buildSnackbar(
          context, "Nama dan nomor telepon wajib diisi.", KError);
      return;
    }

    if (selected == null) {
      DefaultCustomSnackbar.buildSnackbar(
          context, "Layanan belum dipilih.", KError);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Check file sizes before processing
      final ktpSize = await File(_ktpImage!.path).length();
      final sktmSize = await _sktmFile!.length();

      print("KTP file size: ${ktpSize / 1024}KB");
      print("SKTM file size: ${sktmSize / 1024}KB");

      // Compress KTP image
      final ktpCompressed = await compressImage(File(_ktpImage!.path));
      print("KTP compressed size: ${ktpCompressed.length / 1024}KB");

      // Process SKTM file
      Uint8List sktmBytes;
      if (isImageFile(_sktmFile!.path)) {
        // If SKTM is an image, compress it
        print("Compressing SKTM image...");
        sktmBytes = await compressImage(_sktmFile!);
        print("SKTM compressed size: ${sktmBytes.length / 1024}KB");
      } else {
        // If SKTM is a document, read as is
        sktmBytes = await _sktmFile!.readAsBytes();
        print("SKTM document size: ${sktmBytes.length / 1024}KB");
      }

      // Convert to base64
      final ktpBase64 = base64Encode(ktpCompressed);
      final sktmBase64 = base64Encode(sktmBytes);

      // Calculate estimated document size
      final estimatedSize = ktpBase64.length +
          sktmBase64.length +
          1024; // Add 1KB for other fields
      print("Estimated document size: ${estimatedSize / 1024}KB");

      // Strict check for document size (Firestore limit is ~1MB)
      if (estimatedSize > 800 * 1024) {
        // 800KB safety limit
        if (mounted) {
          DefaultCustomSnackbar.buildSnackbar(
              context,
              "Total ukuran file terlalu besar (${(estimatedSize / 1024).toStringAsFixed(1)}KB). "
              "Silakan gunakan file dengan ukuran lebih kecil (maksimal 1MB per file).",
              KError);
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
      }

      final selectedDayInfo = _availableDays.firstWhere(
        (day) => day['value'] == _days,
        orElse: () => {'date': DateTime.now()},
      );
      final selectedDate =
          DateFormat('yyyy-MM-dd').format(selectedDayInfo['date']);

      // Submit to Firestore
      await FirebaseFirestore.instance.collection('bantuan_hukum').add({
        'uid': user.uid,
        'nama': _namaController.text.trim(),
        'telepon': _teleponController.text.trim(),
        'hari': _days,
        'waktu': _times,
        'tanggal': selectedDate,
        'layanan': selected.name,
        'ktp_image': ktpBase64,
        'sktm_file': sktmBase64,
        'sktm_filename': _sktmFileName ?? 'sktm_file',
        'created_at': FieldValue.serverTimestamp(),
        'status': 'pending'
      });

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        Navigator.pushNamed(context, "/terjadwalkan");
      }
    } catch (e) {
      print("🔥 DETAILED ERROR: $e");

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        String errorMessage = "Gagal menjadwalkan silahkan coba lagi";
        if (e.toString().contains('invalid-argument')) {
          errorMessage =
              "Data yang dikirim tidak valid. File terlalu besar atau format tidak sesuai.";
        } else if (e.toString().contains('deadline-exceeded')) {
          errorMessage = "Koneksi timeout. Periksa koneksi internet Anda.";
        }

        DefaultCustomSnackbar.buildSnackbar(context, errorMessage, KError);
      }
    }
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
            padding: const EdgeInsets.symmetric(
              horizontal: 17,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Layanan bantuan hukum",
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
                      style: TextTheme.of(context)
                          .titleSmall
                          ?.copyWith(color: KPrimaryColor),
                    ),
                  ],
                ),
                SizedBox(
                  height: 7,
                ),
                Text(
                  "Untuk melanjutkan ke layanan bantuan hukum, silahkan upload KTP dan SKTM (Surat Keterangan Tidak Mampu) dalam bentuk file PDF.",
                  style: TextTheme.of(context).bodyLarge,
                ),
                SizedBox(
                  height: 40,
                ),
                buildTextFormField(
                    controller: _namaController,
                    label: "Nama Lengkap",
                    icon: "assets/icons/User Icon.svg",
                    isLoading: _isLoadingUserData),
                SizedBox(
                  height: 7,
                ),
                buildTextFormField(
                    controller: _teleponController,
                    label: "Nomor Telepon",
                    icon: "assets/icons/Telepon Icon.svg",
                    keyboardType: TextInputType.phone,
                    isLoading: _isLoadingUserData),
                SizedBox(
                  height: 12,
                ),
                uploadFile(
                  uploadName: "Upload KTP",
                  img: "assets/icons/Upload KTP.svg",
                  imgTrue: 'assets/icons/KTP Upload.svg',
                  isKTP: true,
                ),
                SizedBox(
                  height: 16,
                ),
                uploadFile(
                    uploadName: "Upload SKTM",
                    img: "assets/icons/Upload SKTM.svg",
                    imgTrue: 'assets/icons/SKTM Upload.svg',
                    isKTP: false),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Jadwalkan Janji Temu",
                  style: TextTheme.of(context)
                      .titleLarge
                      ?.copyWith(color: KPrimaryColor),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Pilih hari dan waktu untuk janji temu bantuan hukum.",
                  style: TextTheme.of(context).bodyLarge,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: KPrimaryColor,
                      size: 20,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Jadwal hanya tersedia untuk minggu ini",
                      style: TextTheme.of(context).bodyLarge?.copyWith(
                          color: KPrimaryColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(10),
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: "Hari",
                          contentPadding: EdgeInsets.only(left: 5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        elevation: 1,
                        items: _availableDays
                            .map((day) => DropdownMenuItem<String?>(
                                  value: day['value'] as String?,
                                  enabled: day['value'] != null,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text(
                                      day['name'],
                                      style: TextTheme.of(context)
                                          .bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (String? day) {
                          setState(() {
                            _days = day;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(10),
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: "Waktu",
                          contentPadding: EdgeInsets.only(left: 5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        elevation: 1,
                        items: ['09.00 - 11.00', '14.00 - 15.00']
                            .map((time) => DropdownMenuItem<String?>(
                                value: time,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text(
                                    time,
                                    style: TextTheme.of(context)
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )))
                            .toList(),
                        onChanged: (String? time) {
                          setState(() {
                            _times = time;
                          });
                        },
                      ),
                    )
                  ],
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
                        "Layanan bantuan hukum hanya berlaku untuk orang dengan domisili Kalimantan Timur.",
                        style: TextTheme.of(context)
                            .bodyMedium
                            ?.copyWith(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                DefaultButton(
                  text: "Jadwalkan",
                  press: _isFormValid() ? () => _submitData() : null,
                  bgcolor:
                      _isFormValid() ? KPrimaryColor : Colors.grey.shade400,
                  textColor: Colors.white,
                  isLoading: _isSubmitting,
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget uploadFile(
      {required String uploadName,
      required String img,
      required String imgTrue,
      required bool isKTP}) {
    if (isKTP) {
      // KTP menggunakan gambar
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            uploadName,
            style: TextStyle(
                fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 12,
          ),
          GestureDetector(
            onTap: () => _pickImage(isKTP),
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
                            SvgPicture.asset(
                              img,
                              width: 80,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Format png, jpg, jpeg",
                                style: TextTheme.of(context)
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              imgTrue,
                              width: 80,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Foto telah diupload!",
                                style: TextTheme.of(context)
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600)),
                            SizedBox(
                              height: 3,
                            ),
                            Text("Upload ulang?",
                                style: TextTheme.of(context)
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            uploadName,
            style: TextStyle(
                fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 12,
          ),
          GestureDetector(
            onTap: () => _pickImage(isKTP),
            child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                    color: KGray, borderRadius: BorderRadius.circular(10)),
                child: _sktmFile == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/Upload SKTM.svg",
                              width: 80,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Format pdf, doc, docx, jpg, png",
                              style: TextTheme.of(context).bodyMedium?.copyWith(
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
                              "assets/icons/SKTM Upload.svg",
                              width: 80,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "File telah diupload!",
                                style: TextTheme.of(context)
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text("Tap untuk mengganti file",
                                style: TextTheme.of(context)
                                    .bodyMedium
                                    ?.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )),
          ),
        ],
      );
    }
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String icon,
    TextInputType keyboardType = TextInputType.text,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: isLoading
          ? TextFormField(
              enabled: false,
              decoration: InputDecoration(
                labelText: label,
                hintText: "Memuat data...",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(icon),
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
                        valueColor:
                            AlwaysStoppedAnimation<Color>(KPrimaryColor),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(icon),
                ),
              ),
              keyboardType: keyboardType,
              validator: (value) => value == null || value.isEmpty
                  ? "$label tidak boleh kosong"
                  : null,
            ),
    );
  }
}
