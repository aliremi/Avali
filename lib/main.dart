import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Avali App',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Tahoma',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E2DE2),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainHomePage(),
    );
  }
}

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  bool _isSpeaking = false;

  String _selectedFileName = "هیچ فایلی انتخاب نشده است";
  String _fileExtractedText = "نتیجه پردازش فایل صوتی اینجا نمایش داده می‌شود...";

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("fa-IR");
    await _flutterTts.setSpeechRate(0.5);
    _flutterTts.setStartHandler(() => setState(() => _isSpeaking = true));
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _flutterTts.setErrorHandler((msg) => setState(() => _isSpeaking = false));
  }

  Future<void> _speakText() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً ابتدا متنی برای پخش وارد کنید!")),
      );
      return;
    }
    await _flutterTts.speak(_textController.text);
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        String fileName = result.files.single.name;
        setState(() {
          _selectedFileName = fileName;
          _fileExtractedText = "فایل '$fileName' با موفقیت انتخاب شد.\n(آماده پردازش هوش مصنوعی)";
        });
      }
    } catch (e) {
      setState(() => _fileExtractedText = "خطا در انتخاب فایل: $e");
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("آوالی - مترجم صوتی هوشمند", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // لوگوی درخشان بالای صفحه
                Container(
                  width: 85, height: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
                    boxShadow: [
                      BoxShadow(color: Colors.purple.withOpacity(0.6), blurRadius: 20, spreadRadius: 5),
                    ],
                  ),
                  child: const Icon(Icons.mic_external_on_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 25),

                // کارت اول: تبدیل متن به صوت
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("تبدیل متن به صوت (TTS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _textController,
                        maxLines: 2,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "متن خود را اینجا بنویسید...",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSpeaking ? null : _speakText,
                          icon: Icon(_isSpeaking ? Icons.hourglass_top : Icons.volume_up),
                          label: Text(_isSpeaking ? "در حال پخش صوت..." : "پخش صوت"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // کارت دوم: فایل صوتی به متن
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text("تبدیل فایل صوتی به متن", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.right),
                      const SizedBox(height: 15),
                      OutlinedButton.icon(
                        onPressed: _pickAudioFile,
                        icon: const Icon(Icons.audio_file, color: Colors.amberAccent),
                        label: const Text("انتخاب فایل صوتی از حافظه", style: TextStyle(color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFileName,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Divider(height: 30, color: Colors.white24),
                      const Text("نتیجه پردازش فایل:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.right),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(minHeight: 90),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          _fileExtractedText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.white),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

