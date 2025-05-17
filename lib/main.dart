import 'package:aplikasi_lkbh_unmul/core/services/connection_provider.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/components/consultation_provider.dart';
import 'package:aplikasi_lkbh_unmul/core/screens/no_internet.dart';
import 'package:aplikasi_lkbh_unmul/core/screens/splash_screen.dart';
import 'package:aplikasi_lkbh_unmul/core/routes.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ConsultationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ConnectivityProvider(),
        ),
      ],
      child: Consumer<ConnectivityProvider>(
        builder: (context, connectivity, child) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: themeData(),
            initialRoute: SplashScreen.routeName,
            routes: routes,
            builder: (context, child) {
              if (!connectivity.isConnected) {
                return const NoInternetScreen();
              }
              return child ?? const SizedBox();
            },
          );
        },
      ),
    );
  }
}

