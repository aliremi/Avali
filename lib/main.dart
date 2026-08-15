import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';

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
  // --- متغیرهای بخش متن به صدا ---
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  // --- متغیرهای بخش صدا به متن ---
  String _fileName = "هیچ فایلی انتخاب نشده";
  String _extractedText = "متن استخراج شده اینجا نمایش داده می‌شود...";
  String? _filePath;
  bool _isProcessing = false;

  // 🔴🔴🔴 کلید API گوگل خود را دقیقاً بین دو کوتیشن زیر قرار دهید 🔴🔴🔴
  final String apiKey = "AQ.Ab8RN6JeMRYz3dFIBSYsjCwx9RBodemNcjRkcJtRDf2bbMUARw"; 

  // تابع تبدیل متن به صدا
  Future<void> _speak() async {
    if (_textController.text.isNotEmpty) {
      await _flutterTts.setLanguage("fa-IR");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(_textController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفاً اول یک متن بنویسید!")),
      );
    }
  }

  // تابع انتخاب فایل
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _fileName = result.files.single.name;
          _filePath = result.files.single.path;
          _extractedText = "فایل آماده است. برای شروع پردازش، دکمه استخراج را بزنید.";
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

  // تابع استخراج متن با هوش مصنوعی گوگل (Gemini 1.5)
  Future<void> _extractTextFromAudio() async {
    if (_filePath == null) return;
    
    if (apiKey == "YOUR_API_KEY_HERE" || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطا: کلید API گوگل را در کد وارد نکرده‌اید!")),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _extractedText = "در حال ارسال فایل به سرورهای گوگل و استخراج متن...\nلطفاً چند ثانیه صبر کنید ⏳";
    });

    try {
      // استفاده از سریع‌ترین مدل برای پردازش صدا
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final bytes = await File(_filePath!).readAsBytes();
      
      // تشخیص فرمت فایل به صورت خودکار (مثلا mp3 یا ogg)
      final mimeType = lookupMimeType(_filePath!) ?? 'audio/mp3';

      // دستور (Prompt) ما به هوش مصنوعی
      final prompt = TextPart("لطفا تمام صحبت های داخل این فایل صوتی را به دقت به متن فارسی تبدیل کن. فقط متن استخراج شده را بنویس و هیچ توضیح اضافه‌ای نده.");
      final audioPart = DataPart(mimeType, bytes);

      final response = await model.generateContent([
        Content.multi([prompt, audioPart])
      ]);

      setState(() {
        _extractedText = response.text ?? "متنی در این فایل صوتی تشخیص داده نشد.";
        _isProcessing = false;
      });

    } catch (e) {
      setState(() {
        _extractedText = "متأسفانه خطایی رخ داد:\n$e";
        _isProcessing = false;
      });
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

            // کارت اول: تبدیل متن به صدا (TTS)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text("تبدیل متن به صدا", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
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

            // کارت دوم: تبدیل صدا به متن (Gemini AI)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text("تبدیل صدا به متن", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    
                    // دکمه انتخاب فایل
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _pickFile,
                      icon: const Icon(Icons.audio_file),
                      label: const Text("انتخاب فایل صوتی"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(_fileName, style: const TextStyle(color: Colors.black54), textAlign: TextAlign.center),
                    
                    // دکمه شروع پردازش هوش مصنوعی (سبز رنگ)
                    if (_filePath != null) ...[
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _extractTextFromAudio,
                        icon: _isProcessing 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.auto_awesome),
                        label: Text(_isProcessing ? "در حال پردازش..." : "استخراج متن با هوش مصنوعی"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],

                    const Divider(height: 30),
                    const Align(alignment: Alignment.centerRight, child: Text("نتیجه پردازش:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 120),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isProcessing ? Colors.green.shade300 : Colors.grey.shade300, width: _isProcessing ? 2 : 1),
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

