import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Tahoma',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E2DE2),
          brightness: Brightness.dark,
        ),
      ),
      home: const TranscriptionPage(),
    );
  }
}

class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage({super.key});

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  
  bool _speechEnabled = false;
  bool _isSpeaking = false;
  String _wordsRead = "آماده دریافت صدا... روی میکروفون بزنید.";

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) => setState(() => _wordsRead = "خطا در تشخیص: ${val.errorMsg}"),
      onStatus: (val) => setState(() {}),
    );
    setState(() {});
  }

  void _initTts() {
    _flutterTts.setStartHandler(() => setState(() => _isSpeaking = true));
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _flutterTts.setErrorHandler((msg) => setState(() => _isSpeaking = false));
  }

  void _startListening() async {
    if (_speechEnabled) {
      setState(() => _wordsRead = "گوش می‌دهم... صحبت کنید 🎤");
      await _speechToText.listen(
        onResult: (result) => setState(() {
          _wordsRead = result.recognizedWords.isEmpty ? "صدایی تشخیص داده نشد..." : result.recognizedWords;
        }),
        localeId: 'fa-IR',
        cancelOnError: true,
        partialResults: true,
      );
      setState(() {});
    } else {
      _initSpeech();
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  Future<void> _speakText() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً ابتدا متنی برای پخش وارد کنید!")),
      );
      return;
    }
    await _flutterTts.setLanguage("fa-IR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(_textController.text);
  }

  @override
  void dispose() {
    _animController.dispose();
    _textController.dispose();
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isListening = _speechToText.isListening;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("مترجم هوشمند آوالی", style: TextStyle(fontWeight: FontWeight.bold)),
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
                // لوگو با افکت پالس زنده
                ScaleTransition(
                  scale: isListening || _isSpeaking 
                      ? Tween(begin: 1.0, end: 1.08).animate(_animController)
                      : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    width: 85, height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
                      boxShadow: [
                        BoxShadow(
                          color: (isListening ? Colors.red : Colors.purple).withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      isListening ? Icons.mic : (_isSpeaking ? Icons.volume_up : Icons.mic_external_on_rounded),
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // کارت اول: تبدیل متن به صدا
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("تبدیل متن به صدا (TTS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                          label: Text(_isSpeaking ? "در حال پخش صدا..." : "پخش صوت"),
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

                // کارت دوم: تبدیل صوت به متن
                _buildGlassCard(
                  child: Column(
                    children: [
                      const Text("تبدیل گفتار به متن (Speech-to-Text)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: isListening ? _stopListening : _startListening,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isListening ? Colors.red.shade600 : Colors.purple.shade700,
                            boxShadow: [
                              BoxShadow(
                                color: (isListening ? Colors.red : Colors.purple).withOpacity(0.5),
                                blurRadius: isListening ? 25 : 10,
                                spreadRadius: isListening ? 8 : 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isListening ? "🔴 در حال گوش دادن... حرف بزنید" : "برای ضبط لمس کنید",
                        style: TextStyle(color: isListening ? Colors.redAccent.shade100 : Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 80),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          _wordsRead,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.white),
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
