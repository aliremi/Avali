import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
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
  String _status = "آماده دریافت فایل";

  Future<void> _pickFile() async {
    // کلمه platform از اینجا حذف شد چون در نسخه‌های جدید منسوخ شده
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() => _status = "در حال پردازش: ${result.files.single.name}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TV/VT Transcriptor")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _pickFile, child: const Text("انتخاب فایل صوتی")),
            const SizedBox(height: 20),
            Text(_status, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
