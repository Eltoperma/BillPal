import 'package:flutter/material.dart';

class PreviewTile extends StatelessWidget {
  const PreviewTile._(this.light, this.dark, this.split, this.text);
  final Color light;
  final Color dark;
  final bool split;
  final String text;

  factory PreviewTile.light() =>
      const PreviewTile._(Colors.white, Color(0xFFEDEFF2), false, 'Aa');
  factory PreviewTile.dark() =>
      const PreviewTile._(Color(0xFF1E1F22), Color(0xFFEDEFF2), false, 'Aa');
  factory PreviewTile.system() =>
      const PreviewTile._(Colors.white, Color(0xFF2A2B2E), true, 'Aa');

  factory PreviewTile.localeSystem() =>
      const PreviewTile._(Colors.white, Color(0xFFEDEFF2), false, '🌐');
  factory PreviewTile.localeDe() =>
      const PreviewTile._(Colors.white, Color(0xFFEDEFF2), false, 'DE');
  factory PreviewTile.localeEn() =>
      const PreviewTile._(Colors.white, Color(0xFFEDEFF2), false, 'EN');

  @override
  Widget build(BuildContext context) {
    if (split) {
      return Row(
        children: [
          Expanded(child: Container(color: light)),
          Expanded(child: Container(color: dark)),
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: light,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
