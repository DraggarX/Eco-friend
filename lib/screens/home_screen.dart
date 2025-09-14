import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ecobr/screens/learning_screen.dart';
import 'package:ecobr/screens/news_screen.dart';
import 'package:ecobr/screens/map_screen.dart';
import 'package:ecobr/screens/eco_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String email = '';
  String nickname = '';
  String password = '';
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? 'Не указан';
      nickname = prefs.getString('nickname') ?? 'Не указан';
      password = prefs.getString('password') ?? 'Не указан';

      final avatarBase64 = prefs.getString('avatar_base64');
      if (avatarBase64 != null) {
        _avatarBytes = base64Decode(avatarBase64);
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите источник изображения'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Камера'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Галерея'),
          ),
        ],
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('avatar_base64', base64Encode(bytes));

        setState(() {
          _avatarBytes = bytes;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF70D6F9)),
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nickname,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      image: DecorationImage(
                                        image: _avatarBytes != null
                                            ? MemoryImage(_avatarBytes!)
                                            : const AssetImage('assets/images/avatar.png') as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/images/edit_icon.svg',
                                        width: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _EditbuildRoundedIconButton(
                            'assets/images/Change_the_name.svg',
                            () => debugPrint('Изменить имя clicked'),
                          ),
                          _EditbuildRoundedIconButton(
                            'assets/images/Change_your_email_address.svg',
                            () => debugPrint('Изменить емейл clicked'),
                          ),
                          _EditbuildRoundedIconButton(
                            'assets/images/Change_the_password.svg',
                            () => debugPrint('Изменить пароль clicked'),
                          ),
                          const SizedBox(height: 20),
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: 'Вы прошли все '),
                                TextSpan(
                                  text: 'основные и\nдополнительные курсы ',
                                  style: TextStyle(color: Colors.purple),
                                ),
                                TextSpan(
                                  text: 'и поучаствовали в 3 экопоходах',
                                ),
                              ],
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildIconButton('Достижения', Icons.school, Colors.purpleAccent, () {
                                debugPrint('Достижения clicked');
                              }),
                              const SizedBox(width: 10),
                              _buildIconButton('Звания', Icons.star, Colors.green, () {
                                debugPrint('Звания clicked');
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.6),
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
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

  Widget _EditbuildRoundedIconButton(
    String assetPath,
    VoidCallback onPressed, {
    double size = 70,
    double iconSize = 120,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: size * 3,
            height: size,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              assetPath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 1),
        ],
      ),
    );
  }
}
