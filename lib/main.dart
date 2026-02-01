import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/config_controller.dart';
import 'views/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigController()),
      ],
      child: const OrcamentoPro(),
    ),
  );
}

class OrcamentoPro extends StatelessWidget {
  const OrcamentoPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orçamento Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const HomeView(),
    );
  }
}