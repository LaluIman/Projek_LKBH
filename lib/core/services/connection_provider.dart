import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isConnected = true;
  String _connectionType = '';
  late Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool get isConnected => _isConnected;
  String get connectionType => _connectionType;

  ConnectivityProvider() {
    _connectivity = Connectivity();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } on Exception catch (e) {
      print('Could not check connectivity status: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool previouslyConnected = _isConnected;
    
    // Check if any connection is available
    if (results.contains(ConnectivityResult.mobile)) {
      _isConnected = true;
      _connectionType = 'Mobile';
    } else if (results.contains(ConnectivityResult.wifi)) {
      _isConnected = true;
      _connectionType = 'WiFi';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      _isConnected = true;
      _connectionType = 'Ethernet';
    } else {
      _isConnected = false;
      _connectionType = 'No Connection';
    }
    
    if (previouslyConnected != _isConnected) {
      notifyListeners();
    }
  }

  Future<void> checkConnection() async {
    try {
      List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error checking connectivity: $e');
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
