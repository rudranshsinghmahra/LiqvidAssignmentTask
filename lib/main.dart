import 'package:flutter/material.dart';
import 'package:liqvid_assignment_rudransh/router/app_router.dart';
import 'home/view/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.routes,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
