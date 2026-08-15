import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const VoiceApp());
}

class VoiceApp extends StatelessWidget {
  const VoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تبدیل صوت و متن',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('fa-IR'); // تنظیم زبان به فارسی
  }

  // تبدیل متن به گفتار (خواندن متن)
  Future<void> _speak() async {
    if (_textController.text.isNotEmpty) {
      await _flutterTts.speak(_textController.text);
    }
  }

  // شروع / توقف ضبط صدا و تبدیل به متن
  Future<void> _toggleListen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'fa_IR',
          onResult: (val) {
            setState(() {
              _textController.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تبدیل صوت و متن هوشمند'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _textController,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText: 'متن خود را اینجا بنویسید یا دکمه میکروفون را بزنید و صحبت کنید...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _speak,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('پخش صدا'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _textController.clear(),
                    icon: const Icon(Icons.clear),
                    label: const Text('پاک کردن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FloatingActionButton.extended(
                onPressed: _toggleListen,
                backgroundColor: _isListening ? Colors.red : Theme.of(context).primaryColor,
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
                label: Text(
                  _isListening ? 'در حال شنیدن... (کلیک برای توقف)' : 'شروع تبدیل صدا به متن',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
