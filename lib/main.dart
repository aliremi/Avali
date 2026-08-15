import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const TVVTApp());
}

class TVVTApp extends StatelessWidget {
  const TVVTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TV / VT',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1016),
      ),
      home: const SplashScreen(),
    );
  }
}

// ---------------- صفحه خوش‌آمدگویی (Splash Screen) ----------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // انتقال خودکار به صفحه اصلی پس از ۲.۵ ثانیه
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const MainScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1016), Color(0xFF1E1233)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE94057).withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'TV',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'VT',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'تبدیل هوشمند صوت و متن',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سریع • دقیق • یکپارچه',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- صفحه اصلی ----------------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _ttsController = TextEditingController();
  final TextEditingController _sttController = TextEditingController();

  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isPlayingVoice = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('fa-IR');

    _flutterTts.setCompletionHandler(() {
      setState(() => _isPlayingVoice = false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ttsController.dispose();
    _sttController.dispose();
    super.dispose();
  }

  // پخش صدا از متن
  Future<void> _speak() async {
    if (_ttsController.text.trim().isNotEmpty) {
      setState(() => _isPlayingVoice = true);
      await _flutterTts.speak(_ttsController.text);
    }
  }

  // توقف پخش صدا
  Future<void> _stopSpeak() async {
    await _flutterTts.stop();
    setState(() => _isPlayingVoice = false);
  }

  // تبدیل صدا به متن
  Future<void> _toggleListen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'fa_IR',
          onResult: (val) {
            setState(() {
              _sttController.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // کپی در حافظه
  void _copyToClipboard(String text) {
    if (text.trim().isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Directionality(
            textDirection: TextDirection.rtl,
            child: Text('متن کپی شد! ✨'),
          ),
          backgroundColor: const Color(0xFF6C63FF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // صفحه درباره ما
  void _showAboutDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFF6C63FF),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 15),
                const Text(
                  'درباره سازنده و برنامه',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'این اپلیکیشن با نام TV / VT ابزاری سریع و قدرتمند برای تبدیل متن به گفتار و تبدیل گفتار به متن است که با بهره‌گیری از آخرین فناوری‌ها طراحی شده است.\n\nتوسعه‌داده شده توسط Aliremi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), height: 1.6),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('بستن', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF13141F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70),
            onPressed: _showAboutDialog,
          ),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TV',
                style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6C63FF), fontSize: 20),
              ),
              Text(
                ' / ',
                style: TextStyle(color: Colors.white38),
              ),
              Text(
                'VT',
                style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFF6584), fontSize: 20),
              ),
            ],
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF6C63FF),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            tabs: const [
              Tab(icon: Icon(Icons.record_voice_over), text: 'متن به صوت (TV)'),
              Tab(icon: Icon(Icons.mic), text: 'صوت به متن (VT)'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // تب ۱: متن به گفتار
            _buildTextToSpeechTab(),
            // تب ۲: گفتار به متن
            _buildSpeechToTextTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextToSpeechTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF191A26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _ttsController,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'متن خود را اینجا بنویسید یا الصاق کنید تا خوانده شود...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isPlayingVoice ? _stopSpeak : _speak,
                  icon: Icon(_isPlayingVoice ? Icons.stop : Icons.play_arrow),
                  label: Text(_isPlayingVoice ? 'توقف پخش' : 'پخش صدا'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () => _ttsController.clear(),
                icon: const Icon(Icons.clear_all),
                tooltip: 'پاک کردن',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.08),
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSpeechToTextTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF191A26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _sttController,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                decoration: InputDecoration(
                  hintText: _isListening
                      ? 'در حال گوش دادن... لطفاً صحبت کنید...'
                      : 'برای شروع ضبط، دکمه میکروفون پایین را بزنید...',
                  hintStyle: TextStyle(
                    color: _isListening ? const Color(0xFFFF6584) : Colors.white.withOpacity(0.3),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: () => _copyToClipboard(_sttController.text),
                icon: const Icon(Icons.copy),
                tooltip: 'کپی متن',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.08),
                  padding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: _toggleListen,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [const Color(0xFFFF416C), const Color(0xFFFF4B2B)]
                          : [const Color(0xFF6C63FF), const Color(0xFF3F3D56)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? const Color(0xFFFF416C) : const Color(0xFF6C63FF))
                            .withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: _isListening ? 4 : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              IconButton.filledTonal(
                onPressed: () => _sttController.clear(),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'حذف',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.08),
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
