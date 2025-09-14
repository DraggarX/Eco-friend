import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/personal_data_form.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
 

  
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Персональные данные',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StartScreen(),
      routes: {
        '/personal': (context) => const PersonalDataForm(),
        '/main': (context) => const ProfileScreen(),
      },
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  Future<void> _checkFirstLaunch(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasData = prefs.getString('email') != null;
    
    if (!context.mounted) return;
    
    Navigator.pushReplacementNamed(
      context,
      hasData ? '/main' : '/personal',
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_background.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: InkWell(
              onTap: () => _checkFirstLaunch(context),
              child: Image.asset(
                'assets/images/start_button.png',
                width: 223,
                height: 76,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}