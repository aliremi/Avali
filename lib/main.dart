import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vosk_flutter/vosk_flutter.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';

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
  final FlutterTts _flutterTts = FlutterTts();
  String _extractedText = "آماده دریافت فایل صوتی (MP3/WAV)...";
  bool _isProcessing = false;
  Model? _voskModel;
  Recognizer? _recognizer;

  @override
  void initState() {
    super.initState();
    _initOfflineAI();
  }

  Future<void> _initOfflineAI() async {
    final modelPath = await ModelLoader().loadFromAssets('assets/model');
    _voskModel = await VoskFlutterPlugin.instance().createModel(modelPath);
    _recognizer = await VoskFlutterPlugin.instance().createRecognizer(model: _voskModel!, sampleRate: 16000);
    setState(() => _extractedText = "هوش مصنوعی آماده است!");
  }

  Future<void> _pickAndProcessFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _isProcessing = true;
      _extractedText = "در حال تبدیل و پردازش فایل... لطفاً صبر کنید ⏳";
    });

    final inputPath = result.files.single.path!;
    final tempDir = await getTemporaryDirectory();
    final outputPath = "${tempDir.path}/converted.wav";

    // جادوی تبدیل با FFMPEG: تبدیل هر فرمتی به WAV استانداردِ مورد نیاز Vosk
    await FFmpegKit.execute("-y -i $inputPath -ar 16000 -ac 1 $outputPath").then((session) async {
      final state = await session.getState();
      if (state == 8) { // 8 یعنی با موفقیت انجام شد
        _processWav(outputPath);
      } else {
        setState(() => _extractedText = "خطا در تبدیل فایل!");
      }
    });
  }

  Future<void> _processWav(String path) async {
    final bytes = await File(path).readAsBytes();
    if (bytes.length > 44) {
      final pcmBytes = Uint8List.fromList(bytes.sublist(44));
      await _recognizer!.acceptWaveformBytes(pcmBytes);
      final result = await _recognizer!.getFinalResult();
      setState(() {
        _extractedText = jsonDecode(result)['text'] ?? "متنی یافت نشد.";
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("مترجم هوشمند آفلاین")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _isProcessing ? null : _pickAndProcessFile, child: const Text("انتخاب فایل (MP3/WAV)")),
            const SizedBox(height: 20),
            Padding(padding: const EdgeInsets.all(20), child: Text(_extractedText, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
