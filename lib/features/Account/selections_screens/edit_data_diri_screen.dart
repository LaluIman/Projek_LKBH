import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditDataDiriScreen extends StatefulWidget {
  final String documentId;
  static String routeName = "/editData";

  const EditDataDiriScreen({super.key, required this.documentId});

  @override
  _EditDataDiriScreenState createState() => _EditDataDiriScreenState();
}

class _EditDataDiriScreenState extends State<EditDataDiriScreen> {
  String? selectedProfesi;
  Map<String, dynamic> initialData = {};
  bool isDataChanged = false;
  final _namaController = TextEditingController();
  final _dateController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _alamatDomisiliController = TextEditingController();
  final _nikController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void checkDataChanged() {
    setState(() {
      isDataChanged = _namaController.text != initialData['nama'] ||
          _dateController.text != initialData['tanggal_lahir'] ||
          selectedProfesi != initialData['profesi'] ||
          _teleponController.text != initialData['telepon'] ||
          _alamatController.text != initialData['alamat'] ||
          _alamatDomisiliController.text != initialData['alamat_domisili'] ||
          _nikController.text != initialData['nik'];
    });
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.documentId)
        .get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        _namaController.text = data['nama'] ?? '';
        _dateController.text = data['tanggal_lahir'] ?? '';
        selectedProfesi = data['profesi'] ?? 'Profesi';
        _teleponController.text = data['telepon'] ?? '';
        _alamatController.text = data['alamat'] ?? '';
        _alamatDomisiliController.text = data['alamat_domisili'] ?? '';
        _nikController.text = data['nik'] ?? '';

        initialData = {
          'nama': _namaController.text,
          'tanggal_lahir': _dateController.text,
          'profesi': selectedProfesi,
          'telepon': _teleponController.text,
          'alamat': _alamatController.text,
          'alamat_domisili': _alamatDomisiliController.text,
          'nik': _nikController.text,
        };
      });
      // Tambahkan listener setelah data dimuat
      [
        _namaController,
        _dateController,
        _teleponController,
        _alamatController,
        _alamatDomisiliController,
        _nikController
      ].forEach((controller) {
        controller.addListener(checkDataChanged);
      });
    }
  }

  Future<void> showConfirmationDialog() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            color: KPrimaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          contentTextStyle: const TextStyle(
            color: Colors.black,
          ),
          title: const Text("Konfirmasi"),
          content: const Text("Apakah Anda ingin mengedit data Anda?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Edit",
                  style: TextStyle(
                    color: KPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.documentId)
          .update({
        'nama': _namaController.text,
        'tanggal_lahir': _dateController.text,
        'profesi': selectedProfesi,
        'telepon': _teleponController.text,
        'alamat': _alamatController.text,
        'alamat_domisili': _alamatDomisiliController.text,
        'nik': _nikController.text,
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.inkDrop(color: KPrimaryColor, size: 70),
              SizedBox(
                height: 30,
              ),
              Text(
                "Tunggu sebentar...",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none),
              ),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 3));

      // Tutup loading dan navigasi ke halaman berikutnya
      Navigator.pop(context);

      // Pindah ke halaman '/datadiri' setelah data berhasil di-update
      Navigator.pop(context, true);
      Navigator.pushReplacementNamed(context, '/datadiri');
    }
  }

  @override
  void dispose() {
    [
      _namaController,
      _dateController,
      _teleponController,
      _alamatController,
      _alamatDomisiliController,
      _nikController
    ].forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 150,
        leading: DefaultBackButton(),
        actionsPadding: EdgeInsets.only(right: 20),
        actions: [
          Text(
            'Edit Data Diri',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Personal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Form fields
                  buildTextFormField(
                    controller: _namaController,
                    label: "Nama Lengkap",
                    icon: "assets/icons/User Icon.svg",
                  ),
                  
                  buildDatePicker(),
                  
                  buildTextFormField(
                    controller: _teleponController,
                    label: "Nomor Telepon",
                    icon: "assets/icons/Telepon Icon.svg",
                    keyboardType: TextInputType.phone,
                  ),
                  
                  buildTextFormField(
                    controller: _alamatController,
                    label: "Alamat KTP",
                    icon: "assets/icons/Address Icon.svg",
                  ),
                  
                  buildTextFormField(
                    controller: _alamatDomisiliController,
                    label: "Alamat Domisili",
                    icon: "assets/icons/Domisili Icon.svg",
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Informasi Tambahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  buildProfesiDropdown(),
                  
                  buildTextFormField(
                    controller: _nikController,
                    label: "NIK",
                    icon: "assets/icons/KTP Icon.svg",
                    keyboardType: TextInputType.number,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Batal button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Batal Edit",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: KPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Simpan button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isDataChanged
                              ? () => showConfirmationDialog()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDataChanged ? KPrimaryColor : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Simpan Data",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfesiDropdown() {
    List<String> profesiList = [
      "Profesi",
      "Guru",
      "Dokter",
      "Perawat",
      "Insinyur",
      "Akuntan",
      "Pengacara",
      "Polisi",
      "Tentara",
      "PNS",
      "Arsitek",
      "Sales/Marketing",
      "Petani",
      "Nelayan",
      "Chef/Koki",
      "Pengusaha",
      "Customer Service",
      "Ahli IT (Information Technology)",
      "Tukang Bangunan",
      "Pekerjaan lain"
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Profesi",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedProfesi,
              isExpanded: true,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset("assets/icons/Profesi Icon.svg"),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              items: profesiList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedProfesi = newValue;
                });
                checkDataChanged();
              },
              validator: (value) =>
                  value == "Profesi" ? "Pilih profesi yang sesuai" : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(icon),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              keyboardType: keyboardType,
              validator: (value) =>
                  value == null || value.isEmpty ? "$label tidak boleh kosong" : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tanggal Lahir",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset("assets/icons/Calendar Icon.svg"),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  checkDataChanged();
                }
              },
              validator: (value) => value == null || value.isEmpty
                  ? "Tanggal lahir tidak boleh kosong"
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}