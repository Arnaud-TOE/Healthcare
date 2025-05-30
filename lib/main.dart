import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:healtcare/Screens/Home/homePage.dart';
import 'package:healtcare/Screens/Welcome/welcome_screen.dart';
import 'package:healtcare/Screens/displayHealthData/display_health_data.dart';
import 'package:healtcare/components/userModel.dart';
import 'package:healtcare/components/userRegistrationService.dart';
import 'package:healtcare/components/usersData.dart';
import 'package:healtcare/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ajoute la configuration Android
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {},
  );
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
    },
  );
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  UserRegistrationService _userService = UserRegistrationService();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel>.value(
        value: UserRegistrationService().user,
        initialData: null,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Auth',
          theme: ThemeData(
              primaryColor: kPrimaryColor,
              scaffoldBackgroundColor: Colors.white),
          home: StreamBuilder(
            stream: _userService.user,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  return HomePage();
                }
                return WelcomeScreen();
              }
              //return WelcomeScreen();
              return SafeArea(
                // TODO : Page de chargement d'application avec un delai de 3 secondes
                child: Scaffold(
                  body: Center(
                    child: Text("CHARGEMENT DE L'APPLICATION..."),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
