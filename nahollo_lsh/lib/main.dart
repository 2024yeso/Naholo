import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nahollo/firebase_options.dart';
import 'package:nahollo/models/user_model.dart';
import 'package:nahollo/providers/emailVerify_static.dart';
import 'package:nahollo/providers/user_provider.dart';
import 'package:nahollo/screens/start_logo_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Firebase 초기화 전에 Flutter 엔진 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase 초기화
  );
  runApp(const MyApp()); // 앱 실행
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ), // UserProvider 등록
      ],
      child: MaterialApp(
        title: 'Nahollo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const StartLogoScreen(),
      ),
    );
  }
}
