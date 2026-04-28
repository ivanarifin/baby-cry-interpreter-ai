import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'services/gemini_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const InfantCryDiagnosticApp());
}

class InfantCryDiagnosticApp extends StatelessWidget {
  const InfantCryDiagnosticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infant Cry Diagnostic System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D3E50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const DiagnosticScreen(),
    );
  }
}

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen>
    with SingleTickerProviderStateMixin {
  Widget _buildDiagnosticItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7F8C8D),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF34495E),
            ),
          ),
        ],
      ),
    );
  }

  final AudioRecorder _recorder = AudioRecorder();
  late RecorderController _recorderController;

  bool _isRecording = false;
  String _status = "Ready for Diagnostic Input";
  String _result = "";
  Map<String, dynamic>? _parsedResult;
  int _validAudioSeconds = 0;
  Timer? _timer;

  late GeminiService _geminiService;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(
      baseUrl: dotenv.env['AI_BASE_URL'] ?? '',
      apiKey: dotenv.env['AI_API_KEY'] ?? '',
      model: dotenv.env['AI_MODEL'] ?? 'gemini-3-flash',
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  @override
  void dispose() {
    _recorder.dispose();
    _pulseController.dispose();
    _recorderController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/diagnostic_sample.wav';

        await _recorder.start(const RecordConfig(), path: path);
        await _recorderController.record();

        _pulseController.repeat(reverse: true);

        setState(() {
          _isRecording = true;
          _status = "Acquiring Acoustic Data...";
          _result = "";
          _parsedResult = null;
          _validAudioSeconds = 0;
        });

        _startDiagnosticMonitor();
      }
    } catch (e) {
      setState(() => _status = "Hardware Error: $e");
    }
  }

  void _startDiagnosticMonitor() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!_isRecording) {
        timer.cancel();
        return;
      }

      final amp = await _recorder.getAmplitude();
      if (mounted) {
        if (amp.current > -35) {
          _validAudioSeconds++;
        }

        if (_validAudioSeconds >= 12) {
          timer.cancel();
          _stopRecording();
        }
      }
    });
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      final amp = await _recorder.getAmplitude();
      final path = await _recorder.stop();
      await _recorderController.stop();
      _pulseController.stop();

      if (!mounted) return;

      setState(() {
        _isRecording = false;
      });

      if (amp.max < -45) {
        setState(() {
          _status = "Insufficient Signal Strength";
          _result =
              "Error: No clear acoustic signal detected. Please ensure the device is positioned correctly.";
          _parsedResult = null;
        });
        return;
      }

      setState(() {
        _status = "Processing Diagnostic Data...";
      });

      if (path != null) {
        final response = await _geminiService.analyzeCry(File(path));
        if (mounted) {
          setState(() {
            _result = response;
            try {
              // Clean the response from markdown code blocks or extra text if present
              String cleanedResponse = response.trim();
              
              // Find the first '{' and last '}' to extract the JSON object
              final int startIndex = cleanedResponse.indexOf('{');
              final int endIndex = cleanedResponse.lastIndexOf('}');
              
              if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
                cleanedResponse = cleanedResponse.substring(startIndex, endIndex + 1);
              }
              
              _parsedResult = jsonDecode(cleanedResponse);
            } catch (e) {
              _parsedResult = null;
            }
            _status = "Diagnostic Analysis Complete";
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _status = "System Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              FadeInDown(
                child: const Text(
                  "Infant Cry Diagnostic System",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3E50),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ),
              const Spacer(),
              if (_isRecording)
                FadeIn(
                  child: AudioWaveforms(
                    size: Size(MediaQuery.of(context).size.width, 80.0),
                    recorderController: _recorderController,
                    enableGesture: false,
                    waveStyle: const WaveStyle(
                      waveColor: Color(0xFF3498DB),
                      showMiddleLine: false,
                      spacing: 6.0,
                      extendWaveform: true,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isRecording)
                      ScaleTransition(
                        scale: Tween(begin: 1.0, end: 1.4).animate(
                          CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeInOut),
                        ),
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                const Color(0xFFE74C3C).withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: _isRecording
                          ? () => _stopRecording()
                          : _startRecording,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording
                              ? const Color(0xFFE74C3C)
                              : const Color(0xFF2D3E50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording
                              ? Icons.stop_rounded
                              : Icons.mic_none_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isRecording)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: 150,
                    child: LinearProgressIndicator(
                      value: _validAudioSeconds / 12,
                      backgroundColor: const Color(0xFFBDC3C7),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFE74C3C)),
                    ),
                  ),
                ),
              const Spacer(),
              if (_result.isNotEmpty)
                Expanded(
                  child: FadeInUp(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: (_parsedResult?['is_emergency'] == true)
                            ? Border.all(
                                color: const Color(0xFFE74C3C), width: 2)
                            : Border.all(
                                color: const Color(0xFFDCDDE1), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                  (_parsedResult?['is_emergency'] == true)
                                      ? Icons.report_problem_rounded
                                      : Icons.analytics_outlined,
                                  color:
                                      (_parsedResult?['is_emergency'] == true)
                                          ? const Color(0xFFE74C3C)
                                          : const Color(0xFF3498DB),
                                  size: 20),
                              const SizedBox(width: 10),
                              Text(
                                (_parsedResult?['is_emergency'] == true)
                                    ? "CRITICAL ALERT"
                                    : "Diagnostic Report",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color:
                                        (_parsedResult?['is_emergency'] == true)
                                            ? const Color(0xFFE74C3C)
                                            : const Color(0xFF2D3E50)),
                              ),
                            ],
                          ),
                          const Divider(height: 25),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_parsedResult != null) ...[
                                    _buildDiagnosticItem(
                                        "Classification",
                                        _parsedResult!['reason']?.toString() ??
                                            "Unknown"),
                                    _buildDiagnosticItem("Confidence",
                                        "${((_parsedResult!['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%"),
                                    _buildDiagnosticItem(
                                        "Acoustic Analysis",
                                        _parsedResult!['acoustic_analysis']
                                                ?.toString() ??
                                            "N/A"),
                                    _buildDiagnosticItem(
                                        "Explanation",
                                        _parsedResult!['explanation']
                                                ?.toString() ??
                                            "N/A"),
                                    _buildDiagnosticItem(
                                        "Advice",
                                        _parsedResult!['advice']?.toString() ??
                                            "N/A"),
                                  ] else
                                    Text(
                                      _result,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                          color: Color(0xFF34495E)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "DISCLAIMER: This system is for informational purposes only and does not constitute medical advice. Consult a healthcare professional for clinical concerns.",
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF95A5A6)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
