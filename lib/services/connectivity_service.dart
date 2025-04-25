// lib/services/connectivity_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../Screen/no_internet.dart';
import '../Screen/splash_screen.dart';

class ConnectivityService {
  late StreamSubscription<List<ConnectivityResult>> subscription;
  final Connectivity _connectivity = Connectivity();
  final GlobalKey<NavigatorState> navigatorKey;
  bool wasOffline = false;

  ConnectivityService({required this.navigatorKey});

  void initialize() {
    checkConnectivity();
    subscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  Future<void> checkConnectivity() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _handleConnectivityChange(results);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // If results list is empty or contains only "none" connection type
    bool hasNoConnection = results.isEmpty || 
        (results.length == 1 && results.first == ConnectivityResult.none);
        
    if (hasNoConnection) {
      _showNoInternetScreen();
      wasOffline = true;
    } else {
      if (wasOffline) {
        _navigateToSplashScreen();
        wasOffline = false;
      } else {
        _hideNoInternetScreen();
      }
    }
  }

  void _showNoInternetScreen() {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator != null) {
      bool isNoInternetScreenShown = false;
      navigator.popUntil((route) {
        if (route.settings.name == NoInternetScreen.routeName) {
          isNoInternetScreenShown = true;
        }
        return true;
      });

      if (!isNoInternetScreenShown) {
        navigator.push(
          PageRouteBuilder(
            settings: RouteSettings(name: NoInternetScreen.routeName),
            pageBuilder: (context, _, __) => NoInternetScreen(
              onRefresh: checkConnectivity,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  void _hideNoInternetScreen() {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.popUntil((route) {
        final bool isNoInternetScreen = route.settings.name == NoInternetScreen.routeName;
        if (isNoInternetScreen) {
          navigator.pop();
        }
        return !isNoInternetScreen;
      });
    }
  }

  void _navigateToSplashScreen() {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator != null) {
      _hideNoInternetScreen();
      
      navigator.pushNamedAndRemoveUntil(
        SplashScreen.routeName,
        (route) => false,
      );
    }
  }

  void dispose() {
    subscription.cancel();
  }
}