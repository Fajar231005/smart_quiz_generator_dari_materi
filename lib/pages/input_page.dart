import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'quiz_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';
import '../services/gemini_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController materiController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  bool isLoading = false;
  bool isRecording = false;

  // PICK IMAGE
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      
      String mime = 'image/jpeg';
      String name = pickedFile.name.toLowerCase();
      if (name.endsWith('.png')) mime = 'image/png';
      else if (name.endsWith('.webp')) mime = 'image/webp';
      else if (name.endsWith('.heic')) mime = 'image/heic';
      else if (name.endsWith('.heif')) mime = 'image/heif';

      _processMedia(bytes, mime);
    }
  }

  // PICK DOCUMENT
  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'], // Hapus doc/docx karena Gemini butuh penanganan khusus
      withData: true, // Wajib di Web
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      String ext = result.files.single.extension?.toLowerCase() ?? '';
      
      if (ext == 'txt') {
        try {
          String text = String.fromCharCodes(bytes);
          setState(() {
            materiController.text = materiController.text.isEmpty 
                ? text 
                : "${materiController.text}\n\n$text";
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Teks berhasil dimuat!')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal membaca txt: $e')),
            );
          }
        }
      } else if (ext == 'pdf') {
        try {
          setState(() { isLoading = true; });
          // Membaca teks langsung dari PDF secara lokal! (Sangat cepat & tanpa error API)
          final PdfDocument document = PdfDocument(inputBytes: bytes);
          String text = PdfTextExtractor(document).extractText();
          document.dispose();
          
          setState(() {
            materiController.text = materiController.text.isEmpty 
                ? text 
                : "${materiController.text}\n\n$text";
            isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Teks dari PDF berhasil dimuat!')),
            );
          }
        } catch (e) {
          setState(() { isLoading = false; });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal mengekstrak teks PDF: $e')),
            );
          }
        }
      }
    }
  }

  // RECORD AUDIO
  Future<void> _toggleRecording() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rekaman audio belum didukung di Web. Gunakan Gambar/Dokumen.')),
      );
      return;
    }

    if (isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      setState(() {
        isRecording = false;
      });
      if (path != null) {
        final file = File(path);
        final bytes = await file.readAsBytes();
        _processMedia(bytes, 'audio/mp4');
      }
    } else {
      // Check permissions
      if (await Permission.microphone.request().isGranted) {
        // Start recording
        Directory tempDir = await getTemporaryDirectory();
        String path = '${tempDir.path}/audio_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        
        setState(() {
          isRecording = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin mikrofon diperlukan')),
          );
        }
      }
    }
  }

  // PROCESS MEDIA WITH GEMINI
  Future<void> _processMedia(Uint8List bytes, String mimeType) async {
    setState(() {
      isLoading = true;
    });

    try {
      String text = await GeminiService.extractTextFromMedia(bytes, mimeType);
      setState(() {
        materiController.text = materiController.text.isEmpty 
            ? text 
            : "${materiController.text}\n\n$text";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teks berhasil diekstrak!')),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Detail Error Gemini'),
            content: SingleChildScrollView(child: Text(e.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              )
            ],
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionBtn(Icons.image, "Galeri", () {
                  Navigator.pop(ctx);
                  _pickImage();
                }),
                _buildOptionBtn(Icons.picture_as_pdf, "Dokumen", () {
                  Navigator.pop(ctx);
                  _pickDocument();
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFE59C4C).withOpacity(0.15),
              child: Icon(icon, size: 30, color: const Color(0xFFE59C4C)),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF220E04),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER TEXT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Jadikan momen\nbelajar Anda\nmenjadi makin seru!",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Ketik materi atau ketuk tombol + untuk melampirkan dokumen dan membuat kuis interaktif secara otomatis.",
                      style: TextStyle(
                        fontSize: 16, 
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // BOTTOM INPUT BAR (Antigravity/Chat Style)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ]
              ),
              child: Column(
                children: [
                  // TEXT FIELD ROW
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // ATTACHMENT BUTTON
                        IconButton(
                          padding: const EdgeInsets.all(14),
                          icon: const Icon(Icons.add_circle, color: Colors.grey, size: 28),
                          onPressed: isLoading ? null : _showAttachmentOptions,
                        ),
                        // TEXT FIELD
                        Expanded(
                          child: TextField(
                            controller: materiController,
                            maxLines: 5,
                            minLines: 1,
                            decoration: const InputDecoration(
                              hintText: "Ketik materi di sini...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        // MIC BUTTON
                        IconButton(
                          padding: const EdgeInsets.all(14),
                          icon: Icon(isRecording ? Icons.stop_circle : Icons.mic, size: 28),
                          color: isRecording ? Colors.red : Colors.grey,
                          onPressed: isLoading ? null : _toggleRecording,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE59C4C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : () {
                        if (materiController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Materi tidak boleh kosong")),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizPage(materi: materiController.text),
                          ),
                        );
                      },
                      child: isLoading 
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text("Buat Kuis", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
