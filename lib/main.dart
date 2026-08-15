import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const TranscriptionPage(),
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
  );
}

class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage({super.key});
  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  String _wordsRead = "دکمه میکروفون را بزنید و صحبت کنید...";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: (result) => setState(() => _wordsRead = result.recognizedWords),
      localeId: 'fa_IR', 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("مترجم هوشمند آفلاین")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(_wordsRead, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            ),
            IconButton(
              icon: Icon(_speechToText.isListening ? Icons.mic : Icons.mic_none, size: 64, color: Colors.deepPurple),
              onPressed: _speechToText.isListening ? () => _speechToText.stop() : _startListening,
            ),
            const Text("برای صحبت کردن لمس کنید"),
          ],
        ),
      ),
    );
  }
}
