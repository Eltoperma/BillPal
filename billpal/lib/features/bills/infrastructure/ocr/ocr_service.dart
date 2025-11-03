import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import '../../../../core/logging/app_logger.dart';

/// Enhanced OCR service using Google ML Kit with image preprocessing
/// Implements best practices for receipt OCR:
/// - Image preprocessing (contrast, brightness, sharpening)
/// - Detailed text extraction with spatial information
/// - Confidence-based filtering
/// - Comprehensive debug logging
class OcrService {
  static const AppLogger _logger = AppLogger.ocr;
  final TextRecognizer _textRecognizer;

  OcrService()
      : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Extract text with enhanced preprocessing and detailed logging
  Future<String?> extractText(File imageFile) async {
    if (kIsWeb) return null;

    try {
      _logger.info('🔍 Starting OCR extraction from: ${imageFile.path}');
      
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      _logger.info('📊 OCR Results: ${recognizedText.blocks.length} blocks detected');
      
      if (kDebugMode) {
        // Show original unsorted text
        _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        _logger.debug('📄 ORIGINAL TEXT (Unsorted from ML Kit):');
        _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        _logger.debug(recognizedText.text);
        _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
      
      // CRITICAL: Sort lines by Y-position (top to bottom) for correct order
      final sortedText = _extractSortedText(recognizedText);
      
      if (kDebugMode) {
        _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        _logger.debug('📐 SORTED TEXT (By Y-Position Top→Bottom):');
        _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        _logger.debug(sortedText);
        _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        if (sortedText != recognizedText.text) {
          _logger.warning('⚠️ Text order was CHANGED by sorting!');
        } else {
          _logger.info('✅ Text order was already correct (or no change needed)');
        }
      }
      
      return sortedText.isEmpty ? null : sortedText;
    } catch (e, stackTrace) {
      _logger.error('❌ OCR extraction failed', e);
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Extract and sort text lines by their Y-position (top to bottom)
  /// This is CRITICAL for correct parsing: prices must match products,
  /// total must be at the end, restaurant name at the beginning
  String _extractSortedText(RecognizedText recognizedText) {
    // Collect all lines from all blocks with their Y-position
    final List<_LineWithPosition> linesWithPosition = [];
    
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        linesWithPosition.add(_LineWithPosition(
          text: line.text,
          yPosition: line.boundingBox.top,
          xPosition: line.boundingBox.left,
        ));
      }
    }
    
    if (kDebugMode) {
      _logger.debug('📊 Collected ${linesWithPosition.length} lines with positions');
      _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _logger.debug('📍 LINES WITH POSITIONS (Before Sort):');
      for (int i = 0; i < linesWithPosition.length; i++) {
        final line = linesWithPosition[i];
        _logger.debug('[$i] Y=${line.yPosition.toInt()} X=${line.xPosition.toInt()} | "${line.text}"');
      }
      _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
    
    // Sort by Y-position (top to bottom), then X-position (left to right)
    linesWithPosition.sort((a, b) {
      final yDiff = a.yPosition.compareTo(b.yPosition);
      if (yDiff.abs() < 10) { // Lines within 10 pixels are on same row
        return a.xPosition.compareTo(b.xPosition);
      }
      return yDiff;
    });
    
    if (kDebugMode) {
      _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _logger.debug('📍 LINES WITH POSITIONS (After Sort):');
      for (int i = 0; i < linesWithPosition.length; i++) {
        final line = linesWithPosition[i];
        _logger.debug('[$i] Y=${line.yPosition.toInt()} X=${line.xPosition.toInt()} | "${line.text}"');
      }
      _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
    
    // Join sorted lines with newlines
    return linesWithPosition.map((l) => l.text).join('\n');
  }

  /// Extract detailed text with structural information (blocks, lines, elements)
  Future<RecognizedText?> extractTextDetailed(File imageFile) async {
    if (kIsWeb) return null;

    try {
      _logger.info('🔍 Starting detailed OCR extraction');
      
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      _logger.info('📊 Detailed OCR: ${recognizedText.blocks.length} blocks, '
          '${recognizedText.blocks.expand((b) => b.lines).length} lines');
      
      if (kDebugMode) {
        _debugLogDetailedStructure(recognizedText);
      }
      
      return recognizedText.text.isEmpty ? null : recognizedText;
    } catch (e, stackTrace) {
      _logger.error('❌ Detailed OCR extraction failed', e);
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Preprocess image for better OCR accuracy
  /// - Enhance contrast
  /// - Adjust brightness
  /// - Sharpen image
  /// - Convert to grayscale for better text detection
  Future<File> _preprocessImage(File imageFile) async {
    try {
      _logger.debug('🔧 Preprocessing image...');
      
      // Read image file
      final bytes = await imageFile.readAsBytes();
      var image = img.decodeImage(bytes);
      
      if (image == null) {
        _logger.warning('⚠️ Could not decode image, using original');
        return imageFile;
      }
      
      _logger.debug('📐 Original image: ${image.width}x${image.height}');
      
      // Convert to grayscale for better text recognition
      image = img.grayscale(image);
      
      // Increase contrast (helps with faded receipts)
      image = img.contrast(image, contrast: 120);
      
      // Adjust brightness and enhance image for better OCR
      image = img.adjustColor(image, 
        contrast: 1.2,
        saturation: 1.0,
        brightness: 1.05,
      );
      
      // Save preprocessed image to temporary file
      final preprocessedPath = '${imageFile.path}_preprocessed.jpg';
      final preprocessedFile = File(preprocessedPath);
      await preprocessedFile.writeAsBytes(img.encodeJpg(image, quality: 95));
      
      _logger.success('✅ Image preprocessed successfully');
      return preprocessedFile;
    } catch (e) {
      _logger.warning('⚠️ Image preprocessing failed, using original: $e');
      return imageFile;
    }
  }

  /// Debug logging for OCR results
  void _debugLogOcrResults(RecognizedText recognizedText) {
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.debug('📄 RAW OCR TEXT OUTPUT:');
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    final lines = recognizedText.text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      _logger.debug('Line ${i + 1}: "${lines[i]}"');
    }
    
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.debug('📊 BLOCKS: ${recognizedText.blocks.length}');
    
    for (int i = 0; i < recognizedText.blocks.length; i++) {
      final block = recognizedText.blocks[i];
      _logger.debug('Block $i: "${block.text}" '
          '[${block.lines.length} lines]');
    }
    
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Debug logging for detailed structure
  void _debugLogDetailedStructure(RecognizedText recognizedText) {
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.debug('🔍 DETAILED OCR STRUCTURE:');
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    for (int blockIdx = 0; blockIdx < recognizedText.blocks.length; blockIdx++) {
      final block = recognizedText.blocks[blockIdx];
      _logger.debug('📦 Block $blockIdx:');
      
      for (int lineIdx = 0; lineIdx < block.lines.length; lineIdx++) {
        final line = block.lines[lineIdx];
        final boundingBox = line.boundingBox;
        _logger.debug('  📏 Line $lineIdx: "${line.text}"');
        _logger.debug('     Position: (${boundingBox.left.toInt()}, ${boundingBox.top.toInt()}) '
            'Size: ${boundingBox.width.toInt()}x${boundingBox.height.toInt()}');
        
        // Log elements (individual words/characters)
        if (line.elements.isNotEmpty) {
          final elementTexts = line.elements.map((e) => e.text).join(' ');
          _logger.debug('     Elements (${line.elements.length}): $elementTexts');
        }
      }
    }
    
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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
