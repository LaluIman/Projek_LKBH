import 'package:flutter/material.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/model.dart';

class ConsultationProvider with ChangeNotifier {
  ConsultationType? _selectedConsultation;

  ConsultationType? get selectedConsultation => _selectedConsultation;

  void setSelectedConsultation(ConsultationType consultation) {
    _selectedConsultation = consultation;
    notifyListeners();
  }

  void clearSelectedConsultation() {
    _selectedConsultation = null;
    notifyListeners();
  }
}
