import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'home_screen.dart';
import 'news_screen.dart';
import 'learning_screen.dart';
import 'eco_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final WebViewController _controller;
  final String url = 'https://recyclemap.ru/viewer';

  bool _isLoading = true; // состояние загрузки

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      // ..setMediaPlaybackPolicy(AutoMediaPlaybackPolicy.always_allow) // если есть, оставь, если нет - закомментируй
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            _injectOptimizedScript();
            // Ждем полсекунды перед скрытием лоадера
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _injectOptimizedScript() {
  const backgroundColor = '#FAD088';

  const script = '''
    requestAnimationFrame(() => {
      const toHide = [
        'app-header',
        'app-footer',
        'rc-info-panel',
        'rc-about-block',
        'rc-faq',
        'rc-feedback',
        'rc-scroll-up'
      ];

      toHide.forEach(tag => {
        const el = document.querySelector(tag);
        if (el) el.style.display = 'none';
      });

      // Удаление по классам
      const classNamesToRemove = [
        
        'ng-tns-c382938293-0',
      ];

      classNamesToRemove.forEach(className => {
        const elements = document.querySelectorAll('.' + className);
        elements.forEach(el => el.remove());
      });

      // Сброс отступов и высоты
      const html = document.documentElement;
      const body = document.body;

      [html, body].forEach(el => {
        el.style.margin = '0';
        el.style.padding = '0';
        el.style.background = '$backgroundColor';
        el.style.height = '100vh';
        el.style.overflow = 'hidden';
      });

      // Замена белых цветов на цвет фона
      const elements = document.querySelectorAll('*');
      elements.forEach(el => {
        const style = window.getComputedStyle(el);
        if (style.color === 'rgb(255, 255, 255)') {
          el.style.color = '$backgroundColor';
        }
        if (style.backgroundColor === 'rgb(255, 255, 255)') {
          el.style.backgroundColor = '$backgroundColor';
        }
      });
    });
  ''';

  _controller.runJavaScript(script);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Основной фон
          Container(color: const Color(0xFFFAD088)),

          // WebView с RepaintBoundary и отступом сверху и снизу
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            bottom: 0,
            child: RepaintBoundary(
              child: WebViewWidget(controller: _controller),
            ),
          ),

          // Фоновое изображение наложено поверх WebView (полупрозрачно)
          Positioned.fill(
            bottom: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  'assets/images/home_background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Кастомный лоадер (затемнение и индикатор)
          if (_isLoading)
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              bottom: 100,
              child: Container(
                color: const Color(0xFFFAD088),
                child: const Center(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
            ),

          // Нижние кнопки - поверх всего, всегда видны
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRoundedIconButton('assets/images/eco_icon.svg', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const EcoScreen()),
                  );
                }),
                _buildRoundedIconButton('assets/images/courses_icon.svg', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LearningScreen()),
                  );
                }),
                _buildRoundedIconButton('assets/images/news_icon.svg', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const NewsScreen()),
                  );
                }),
                _buildRoundedIconButton('assets/images/map_icon.svg', () {
                  // Текущий экран, можно оставить без действий
                }),
              ],
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
