import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../../core/logging/app_logger.dart';

class OcrService {
  static const AppLogger _logger = AppLogger.ocr;
  final TextRecognizer _textRecognizer;

  OcrService()
    : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String?> extractText(File imageFile) async {
    if (kIsWeb)
      return null; //this is needed as web is not supported by the google ml kit

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final sortedText = _extractSortedText(recognizedText);

      return sortedText.isEmpty ? null : sortedText;
    } catch (e, stackTrace) {
      _logger.error('❌ OCR extraction failed', e);
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  String _extractSortedText(RecognizedText recognizedText) {
    final List<_LineWithPosition> linesWithPosition = [];

    //extract the text from the blocks and lines with their position
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        linesWithPosition.add(
          _LineWithPosition(
            text: line.text,
            yPosition: line.boundingBox.top,
            xPosition: line.boundingBox.left,
          ),
        );
      }
    }

    //sort the text
    linesWithPosition.sort((a, b) {
      final yDiff = (a.yPosition - b.yPosition).abs();
      if (yDiff < 10) {
        // Lines within 10 pixels are on same row, maybe needs to be adjusted
        return a.xPosition.compareTo(b.xPosition);
      }
      return a.yPosition.compareTo(b.yPosition);
    });

    // Group lines with similar Y positions together
    final List<String> groupedLines = [];
    if (linesWithPosition.isEmpty) return '';

    List<_LineWithPosition> currentGroup = [linesWithPosition.first];

    for (int i = 1; i < linesWithPosition.length; i++) {
      final current = linesWithPosition[i];
      final previous = linesWithPosition[i - 1];
      final yDiff = (current.yPosition - previous.yPosition).abs();

      if (yDiff < 10) {
        // Same line - add to current group
        currentGroup.add(current);
      } else {
        // New line - join current group and start a new one
        groupedLines.add(currentGroup.map((l) => l.text).join(' '));
        currentGroup = [current];
      }
    }

    // Add the last group
    if (currentGroup.isNotEmpty) {
      groupedLines.add(currentGroup.map((l) => l.text).join(' '));
    }

    return groupedLines.join('\n');
  }

  Future<RecognizedText?> extractTextDetailed(File imageFile) async {
    if (kIsWeb) return null;

    try {
      _logger.info('🔍 Starting detailed OCR extraction');

      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return recognizedText.text.isEmpty ? null : recognizedText;
    } catch (e, stackTrace) {
      _logger.error('❌ Detailed OCR extraction failed', e);
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}

/// Helper class to store text line with its position
class _LineWithPosition {
  final String text;
  final double yPosition;
  final double xPosition;

  _LineWithPosition({
    required this.text,
    required this.yPosition,
    required this.xPosition,
  });
}
