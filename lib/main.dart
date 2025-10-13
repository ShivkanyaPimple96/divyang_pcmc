import 'dart:io';

import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/Home_Screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/DeviceInfoProvider.dart';
import 'provider/SettingProvider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: DeviceInfoProvider(),
        ),
        ChangeNotifierProvider.value(
          value: SettingProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Marvis Auth',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
      )));
}

// import 'dart:io';

// import 'package:divyang_pimpri_chinchwad_municipal_corporation/KYC_Screens/Home_Screen.dart';
// import 'package:flutter/material.dart';

// void main() {
//   HttpOverrides.global = MyHttpOverrides();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '',
//       debugShowCheckedModeBanner: false,
//       home: const HomeScreen(),
//     );
//   }
// }

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
