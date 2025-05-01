import 'package:flutter/material.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/model.dart';

class ConsultationProvider with ChangeNotifier {
  ConsultationType? _selectedConsultation;
  
  ConsultationType? get selectedConsultation => _selectedConsultation;
  
  void setSelectedConsultation(ConsultationType consultationType) {
    _selectedConsultation = consultationType;
    notifyListeners();
  }
  
  void resetSelectedConsultation() {
    _selectedConsultation = null;
    notifyListeners();
  }
}