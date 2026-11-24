import 'package:flutter/material.dart';
import 'services/pro_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final proService = await ProService.load();
  runApp(LazyMediaApp(proService: proService));
}

class LazyMediaApp extends StatelessWidget {
  final ProService proService;

  const LazyMediaApp({super.key, required this.proService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LazyMedia Deluxe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(proService: proService),
    );
  }
}
