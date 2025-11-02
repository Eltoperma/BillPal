import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// OCR service using Google ML Kit (Android/iOS only)
class OcrService {
  final TextRecognizer _textRecognizer;

  OcrService()
      : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String?> extractText(File imageFile) async {
    if (kIsWeb) return null;

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text.isEmpty ? null : recognizedText.text;
    } catch (e) {
      return null;
    }
  }

  Future<RecognizedText?> extractTextDetailed(File imageFile) async {
    if (kIsWeb) return null;

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text.isEmpty ? null : recognizedText;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
