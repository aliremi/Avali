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
          seedColor: const Color(0xFF7B1FA2),
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

class _TranscriptionPageState extends State<TranscriptionPage> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  bool _speechEnabled = false;
  String _wordsRead = "دکمه میکروفون را بزنید و صحبت کنید...";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: (result) => setState(() => _wordsRead = result.recognizedWords),
        localeId: 'fa-IR',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("مترجم هوشمند شیشه‌ای"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.deepPurple.shade800]),
                  ),
                  child: const Icon(Icons.mic_external_on_rounded, size: 45, color: Colors.white),
                ),
                const SizedBox(height: 25),
                _buildGlassCard(
                  Column(children: [
                    TextField(controller: _textController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "متن بنویسید...")),
                    ElevatedButton(onPressed: () => _flutterTts.speak(_textController.text), child: const Text("پخش صدا")),
                  ]),
                ),
                const SizedBox(height: 20),
                _buildGlassCard(
                  Column(children: [
                    IconButton(
                      icon: Icon(_speechToText.isListening ? Icons.mic : Icons.mic_none, size: 50, color: Colors.white),
                      onPressed: _speechToText.isListening ? () => _speechToText.stop() : _startListening,
                    ),
                    Text(_wordsRead, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), border: Border.all(color: Colors.white.withOpacity(0.2))),
          child: child,
        ),
      ),
    );
  }
}

