import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:io';
import 'services/gemini_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const BabyCryApp());
}

class BabyCryApp extends StatelessWidget {
  const BabyCryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Cry Interpreter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String _status = "Tap to listen to your baby";
  String _result = "";
  double _currentDb = -160.0;
  
  late GeminiService _geminiService;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(
      baseUrl: dotenv.env['AI_BASE_URL'] ?? '',
      apiKey: dotenv.env['AI_API_KEY'] ?? '',
      model: dotenv.env['AI_MODEL'] ?? 'gemini-3-flash',
      oauthKey: dotenv.env['X_OAUTH_KEY'],
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/baby_cry.wav';
        
        await _recorder.start(const RecordConfig(), path: path);
        _pulseController.repeat(reverse: true);
        
        setState(() {
          _isRecording = true;
          _status = "Listening carefully...";
          _result = "";
        });

        // Monitor amplitude
        _monitorAmplitude();
      }
    } catch (e) {
      setState(() => _status = "Error: $e");
    }
  }

  void _monitorAmplitude() async {
    while (_isRecording) {
      await Future.delayed(const Duration(milliseconds: 200));
      final amp = await _recorder.getAmplitude();
      if (mounted) {
        setState(() {
          _currentDb = amp.current;
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final amp = await _recorder.getAmplitude();
      final path = await _recorder.stop();
      _pulseController.stop();
      
      setState(() {
        _isRecording = false;
      });

      // Local Pre-filtering: Cek apakah suara cukup keras (tangisan biasanya > -30dB)
      if (amp.max < -45) {
        setState(() {
          _status = "Suara terlalu pelan atau sunyi.";
          _result = "Waduh Bos, suaranya nggak kedengeran. Coba rekam lebih deket ke bayinya ya!";
        });
        return;
      }

      setState(() {
        _status = "Analyzing the cry...";
      });

      if (path != null) {
        final response = await _geminiService.analyzeCry(File(path));
        setState(() {
          _result = response;
          _status = "Analysis Complete";
        });
      }
    } catch (e) {
      setState(() => _status = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                FadeInDown(
                  child: const Text(
                    "Baby Whisperer AI",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isRecording)
                        ScaleTransition(
                          scale: Tween(begin: 1.0, end: 1.5).animate(
                            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                          ),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ZoomIn(
                        child: GestureDetector(
                          onTap: _isRecording ? _stopRecording : _startRecording,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording ? Colors.red : const Color(0xFF6C63FF),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isRecording ? Colors.red : const Color(0xFF6C63FF)).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isRecording)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "Volume: ${_currentDb.toStringAsFixed(1)} dB",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ),
                const Spacer(),
                if (_result.isNotEmpty)
                  FadeInUp(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "AI Analysis",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          const Divider(height: 25),
                          Text(
                            _result,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
