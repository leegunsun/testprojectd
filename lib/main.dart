import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projectd/amplify_manager.dart';
import 'package:projectd/init_view.dart';
import 'package:projectd/login_view.dart';
import 'package:projectd/navigation_manager.dart';

import 'amplifyconfiguration.dart';
import 'home.dart';

// 1 2

final AmplifyLogger customLogger = AmplifyLogger('MyStorageApp');

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AmplifyLogger().logLevel = LogLevel.debug;
  runApp(
    const MyApp(
      title: 'Amplify Storage Example',
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.title});

  final String title;

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AmplifyManager.configureAmplify();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay() {
    final overlayState = NavigationManager.navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint("❌ navigatorKey.currentState가 null 입니다! 다이얼로그를 띄울 수 없습니다.");
      return;
    }

    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.white,
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
  }


  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _showOverlay();
    } else if (state == AppLifecycleState.resumed) {
      _removeOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      preferPrivateSession: true,
      child: MaterialApp.router(
        title: 'Flutter Demo',
        builder: Authenticator.builder(),
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        routerConfig: NavigationManager.router,
      ),
    );
  }
}
