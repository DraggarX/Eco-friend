import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'package:ecobr/screens/learning_screen.dart';
import 'package:ecobr/screens/news_screen.dart';
import 'package:ecobr/screens/map_screen.dart';

class EcoScreen extends StatefulWidget {
  const EcoScreen({super.key});

  @override
  State<EcoScreen> createState() => _EcoScreenState();
}

class _EcoScreenState extends State<EcoScreen> {
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final avatarBase64 = prefs.getString('avatar_base64');
    if (avatarBase64 != null) {
      setState(() {
        _avatarBytes = base64Decode(avatarBase64);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Цвет фона
          Container(
            color: const Color.fromARGB(255, 135, 222, 168),
          ),

          // Фоновое изображение
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/eco_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Содержимое страницы
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Аватар и кнопка
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: SizedBox()),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 70,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: _avatarBytes != null
                                    ? MemoryImage(_avatarBytes!)
                                    : const AssetImage('assets/images/avatar.png') as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              ).then((_) => _loadAvatar()); // Перезагрузка при возврате
                            },
                            child: SvgPicture.asset(
                              'assets/images/eco_settings.svg',
                              width: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Нижние иконки
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRoundedIconButton('assets/images/eco_icon.svg', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EcoScreen()),
                        );
                      }),
                      _buildRoundedIconButton('assets/images/courses_icon.svg', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LearningScreen()),
                        );
                      }),
                      _buildRoundedIconButton('assets/images/news_icon.svg', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NewsScreen()),
                        );
                      }),
                      _buildRoundedIconButton('assets/images/map_icon.svg', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MapScreen()),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedIconButton(
    String assetPath,
    VoidCallback onPressed, {
    double size = 80,
    double iconSize = 140,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              assetPath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
