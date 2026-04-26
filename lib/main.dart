import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'services/gemini_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const BabyCryApp());
}

class BabyCryApp extends StatelessWidget {
  const BabyCryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Cry Interpreter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
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
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String _status = "Press the button to start recording";
  String _result = "";
  
  late GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(
      baseUrl: dotenv.env['AI_BASE_URL'] ?? '',
      apiKey: dotenv.env['AI_API_KEY'] ?? '',
      model: dotenv.env['AI_MODEL'] ?? 'gemini-3-flash',
      oauthKey: dotenv.env['X_OAUTH_KEY'],
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/baby_cry.wav';
        
        await _recorder.start(const RecordConfig(), path: path);
        
        setState(() {
          _isRecording = true;
          _status = "Recording... (Speak or let the baby cry)";
          _result = "";
        });
      }
    } catch (e) {
      setState(() => _status = "Error starting record: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _status = "Analyzing audio...";
      });

      if (path != null) {
        final response = await _geminiService.analyzeCry(File(path));
        setState(() {
          _result = response;
          _status = "Analysis Complete";
        });
      }
    } catch (e) {
      setState(() => _status = "Error stopping record: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Baby Cry Interpreter AI")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Center(
              child: GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: _isRecording ? Colors.red : Colors.blue,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_result.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_result, style: const TextStyle(fontFamily: 'monospace')),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
