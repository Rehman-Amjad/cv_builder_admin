import 'package:cv_builder_admin/provider/data_provider.dart';
import 'package:cv_builder_admin/provider/image_provider.dart';
import 'package:cv_builder_admin/provider/save_data_provider.dart';
import 'package:cv_builder_admin/provider/text_color_provider.dart';
import 'package:cv_builder_admin/provider/value_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'admin/controller/MenuAppController.dart';
import 'admin/home_screen/main_screen.dart';
import 'constants.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => ValueProvider()),
        ChangeNotifierProvider(create: (_) => TextColorProvider()),
        ChangeNotifierProvider(create: (_) => MenuAppController()),
        ChangeNotifierProvider(create: (_) => MyImageProvider()),
        ChangeNotifierProvider(create: (_) => SaveDataProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hotel Booking',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          useMaterial3: true,
        ),
        // home:  UserWaitingScreen(id: "M8vHYgam3S2ZPjoWn7Xf",),
        // home:  UserFormScreen(),
        home:  MainScreen(),
      ),
    );
  }
}
