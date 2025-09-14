import 'dart:convert';
import 'dart:typed_data';
import 'package:ecobr/screens/Learning/courses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'eco_screen.dart';
import 'news_screen.dart';
import 'map_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});
 
  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
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
          Container(
            color: const Color.fromARGB(255, 189, 156, 234),
          ),
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Аватар и кнопка профиля
                  // Заголовок "Обучение" и аватар
// Заголовок "Обучение" и аватар с отступами
Padding(
  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Надпись "Обучение"
      const Text(
        'Обучение',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 8, 5, 5),
        ),
      ),

      // Аватар с кнопкой настроек
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
              );
            },
            child: SvgPicture.asset(
              'assets/images/courses_settings.svg',
              width: 32,
            ),
          ),
        ],
      ),
    ],
  ),
),



                  const SizedBox(height: 20),

                  // Новые карточки
                  _buildCourseCard(
                    title: 'Основные курсы',
                    subtitle: 'Обучение заботе о природе',
                    icon: Icons.school,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CoursesScreen()),
                        );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCourseCard(
                    title: 'Доп. курсы',
                    subtitle: 'Особенности борьбы за экологию',
                    icon: Icons.extension,
                    onTap: () {
                      // TODO: переход к дополнительным курсам
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  _buildCourseCard2(
                    title: 'Экофильмы',
                    subtitle: 'Свалки и прочие беды современного мира',
                    iconPath: 'assets/images/play_icon.svg',
                    onTap: () {
                      // TODO: переход к экофильмам
                    },
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

  Widget _buildCourseCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    
    child: Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Линия посередине
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: Colors.black,
            ),
          ),

          // Содержимое карточки
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Текстовая часть
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      // Заголовок
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Подзаголовок
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Встроенная иконка Flutter
              Container(
  width: 60,
  height: 60,
  decoration: BoxDecoration(
    color: const Color.fromARGB(255, 189, 156, 234),
    shape: BoxShape.circle,
    border: Border.all(color: Colors.black, width: 3.5),
  ),
  child: Icon(
    icon,
    size: 30,
    color: const Color.fromARGB(255, 255, 255, 255),
  ),
),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildCourseCard2({
  required String title,
  required String subtitle,
  required String iconPath,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 140, // чуть больше высота для воздуха
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Линия посередине
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: Colors.black,
            ),
          ),

          // Содержимое карточки
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Текстовая часть
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      // Заголовок в верхней части
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Подзаголовок в нижней части с отступом от линии
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5), // отступ от линии
                            child: Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Иконка
              SvgPicture.asset(
                iconPath,
                width: 44,
                height: 44,
              ),
            ],
          ),
        ],
      ),
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
