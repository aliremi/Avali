import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart'; // پکیج تبدیل متن به صدا اضافه شد

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TV/VT Transcriptor',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EA), 
          brightness: Brightness.light,
        ),
        fontFamily: 'Tahoma', 
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
  // --- متغیرهای بخش صدا به متن ---
  String _fileName = "هیچ فایلی انتخاب نشده";
  String _extractedText = "متن استخراج شده اینجا نمایش داده می‌شود...";

  // --- متغیرهای بخش متن به صدا ---
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  // تابع انتخاب فایل
  Future<void> _pickFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.audio,
      );

      if (file != null) {
        setState(() {
          _fileName = file.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطا در انتخاب فایل: $e")),
        );
      }
    }
  }

  // تابع تبدیل متن به صدا
  Future<void> _speak() async {
    if (_textController.text.isNotEmpty) {
      // تنظیم زبان به فارسی (در صورت پشتیبانی گوشی)
      await _flutterTts.setLanguage("fa-IR");
      await _flutterTts.setPitch(1.0); // تنظیم زیر و بمی صدا
      await _flutterTts.setSpeechRate(0.5); // تنظیم سرعت خواندن
      await _flutterTts.speak(_textController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً اول یک متن بنویسید!")),
      );
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("مترجم هوشمند صدا و متن", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بخش لوگو موقت
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: const ClipOval(
                  child: Icon(Icons.mic_external_on_rounded, size: 50, color: Color(0xFF6200EA)),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // -----------------------------------------
            // کارت اول: تبدیل متن به صدا (Text to Speech)
            // -----------------------------------------
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "تبدیل متن به صدا",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: "متن خود را اینجا تایپ کنید...",
                        hintTextDirection: TextDirection.rtl,
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _speak,
                      icon: const Icon(Icons.volume_up),
                      label: const Text("پخش صدا"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade50,
                        foregroundColor: const Color(0xFF6200EA),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // -----------------------------------------
            // کارت دوم: تبدیل صدا به متن (Voice to Text)
            // -----------------------------------------
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      "تبدیل صدا به متن",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.audio_file),
                      label: const Text("انتخاب فایل صوتی"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _fileName,
                      style: const TextStyle(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 30),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "نتیجه پردازش:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 120),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        _extractedText,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                        textDirection: TextDirection.rtl,
                      ),
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
}
