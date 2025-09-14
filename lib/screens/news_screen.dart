import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'learning_screen.dart';
import 'eco_screen.dart';
import 'map_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String? _avatarPath;
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('avatar_path');
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      setState(() {
        _avatarPath = path;
      });
    } else {
      // Если пути нет, пытаемся загрузить аватар из base64 (если у тебя так хранится)
      final avatarBase64 = prefs.getString('avatar_base64');
      if (avatarBase64 != null) {
        setState(() {
          _avatarBytes = base64Decode(avatarBase64);
        });
      }
    }
  }

  Future<List<dynamic>> _loadNews() async {
    final String response = await rootBundle.loadString('assets/news.json');
    return json.decode(response);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color.fromARGB(255, 237, 142, 140)),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 10),
                  Expanded(child: _buildNewsList(screenHeight)),
                  const SizedBox(height: 10),
                  _buildBottomNav(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Новости',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 70,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: _avatarPath != null
                      ? FileImage(File(_avatarPath!))
                      : _avatarBytes != null
                          ? MemoryImage(_avatarBytes!)
                          : const AssetImage('assets/images/avatar.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
                _loadAvatar();
              },
              child: SvgPicture.asset(
                'assets/images/news_settings.svg',
                width: 32,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewsList(double cardHeight) {
    return FutureBuilder<List<dynamic>>(
      future: _loadNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Нет новостей'));
        }

        return Scrollbar(
          thumbVisibility: true,
          radius: const Radius.circular(10),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final news = snapshot.data![index];
              return _buildNewsCard(news, cardHeight * 0.25);
            },
          ),
        );
      },
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news, double height) {
    return GestureDetector(
      onTap: () => _showFullNewsDialog(news),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.9),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            if (news['imageUrl'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                child: Image.network(
                  news['imageUrl'],
                  width: height/1.6,
                  height: height,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        _stripSubtitles(news['text']),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      news['date'],
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullNewsDialog(Map<String, dynamic> news) {
    final imageRegex = RegExp(r'(https?:\/\/[^\s]+?\.(?:png|jpe?g|gif|webp))');
    final subtitleRegex = RegExp(r'<subtitle>(.*?)<\/subtitle>', caseSensitive: false);

    final lines = news['text'].toString().split('\n');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(10),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(  
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news['title'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (news['imageUrl'] != null && news['imageUrl'].toString().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        news['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ...lines.map((line) {
                    if (imageRegex.hasMatch(line.trim())) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            line.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                        ),
                      );
                    }

                    final subtitleMatch = subtitleRegex.firstMatch(line);
                    if (subtitleMatch != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          subtitleMatch.group(1) ?? '',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        line.trim(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRoundedIconButton('assets/images/eco_icon.svg', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EcoScreen()));
        }),
        _buildRoundedIconButton('assets/images/courses_icon.svg', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen()));
        }),
        _buildRoundedIconButton('assets/images/news_icon.svg', () {}), // Текущий экран
        _buildRoundedIconButton('assets/images/map_icon.svg', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
        }),
      ],
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

  String _stripSubtitles(String text) {
    final subtitleRegex = RegExp(r'<subtitle>.*?<\/subtitle>', caseSensitive: false, dotAll: true);
    return text.replaceAll(subtitleRegex, '').trim();
  }
}
