import 'dart:convert';
import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../infrastructure/ocr/ocr_service.dart';
import '../../infrastructure/ocr/receipt_data.dart';
import '../../infrastructure/parsing/receipt_parser.dart';
import '../../infrastructure/picking/image_picker_service.dart';
import '../pages/add_invoice_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// Welche UI soll für die Quellenwahl genutzt werden?
//enum AddInvoiceUI { sheet, menu, adaptive }

/// Ein Entry-Button, der entweder ein Bottom-Sheet öffnet (iOS-Style)
/// oder ein MenuAnchor (Desktop/Web-Style). Umschaltbar per [ui].
class AddInvoiceEntryButton extends StatelessWidget {
  final List<Person> people;
  //final AddInvoiceUI ui;
  final String? label;

  const AddInvoiceEntryButton({
    super.key,
    required this.people,
    //this.ui = AddInvoiceUI.adaptive,
    this.label,
  });

  bool _useMenu(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final buttonLabel = label ?? l10n.shareBill;
    return _useMenu(context)
        ? _MenuAnchorButton(people: people, label: buttonLabel)
        : FloatingActionButton.extended(
            onPressed: () => _openChoiceSheet(context, people: people),
            icon: const Icon(Icons.add),
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            label: Text(buttonLabel),
          );
  }
}

/// Variante 1: Action-Sheet (BottomSheet)
Future<void> _openChoiceSheet(
  BuildContext context, {
  required List<Person> people,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.manualEntry),
            onTap: () async {
              Navigator.pop(ctx);
              await openAddInvoice(context, people: people);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.takePhoto),
            onTap: () async {
              Navigator.pop(ctx);
              await _scanReceipt(context, people: people, fromCamera: true);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: Text(l10n.importFromGallery),
            onTap: () async {
              Navigator.pop(ctx);
              await _scanReceipt(context, people: people, fromCamera: false);
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Variante 2: MenuAnchor (Material 3)
class _MenuAnchorButton extends StatefulWidget {
  final List<Person> people;
  final String label;
  const _MenuAnchorButton({required this.people, required this.label});

  @override
  State<_MenuAnchorButton> createState() => _MenuAnchorButtonState();
}

class _MenuAnchorButtonState extends State<_MenuAnchorButton> {
  final _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menu,
      alignmentOffset: const Offset(0, 8),
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.edit_outlined),
          onPressed: () async {
            _menu.close();
            await openAddInvoice(context, people: widget.people);
          },
          child: const Text('Manuell eingeben'),
        ),
        const Divider(height: 1),
        MenuItemButton(
          leadingIcon: const Icon(Icons.photo_camera_outlined),
          onPressed: () async {
            _menu.close();
            await _scanReceipt(
              context,
              people: widget.people,
              fromCamera: true,
            );
          },
          child: const Text('Foto aufnehmen'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.image_outlined),
          onPressed: () async {
            _menu.close();
            await _scanReceipt(
              context,
              people: widget.people,
              fromCamera: false,
            );
          },
          child: const Text('Aus Galerie/Dateien importieren'),
        ),
      ],
      builder: (context, controller, child) {
        return FloatingActionButton.extended(
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
          icon: const Icon(Icons.add),
          label: Text(widget.label),
        );
      },
    );
  }
}

Future<void> _scanReceipt(
  BuildContext context, {
  required List<Person> people,
  required bool fromCamera,
}) async {
  if (kIsWeb) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'OCR wird im Web nicht unterstützt.\n'
            'Bitte auf Android oder iOS ausführen.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
    return;
  }

  final imagePickerService = ImagePickerService();
  final ocrService = OcrService();
  final receiptParser = ReceiptParser();

  try {
    final imageFile = fromCamera
        ? await imagePickerService.pickFromCamera()
        : await imagePickerService.pickFromGallery();

    if (imageFile == null) return;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Beleg wird verarbeitet...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    final rawText = await ocrService.extractText(imageFile);

    if (rawText == null || rawText.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kein Text erkannt. Bitte versuche es erneut.\n'
              'Tipps: Gute Beleuchtung, flacher Beleg, scharf fokussiert.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    // Debug: Print raw OCR text to console
    if (kDebugMode) {
      print('\n');
      print('═══════════════════════════════════════════════════════════');
      print('📄 OCR DETECTED TEXT (Raw Output):');
      print('═══════════════════════════════════════════════════════════');
      print(rawText);
      print('═══════════════════════════════════════════════════════════');
      print('\n');
    }

    final ReceiptData receiptData = receiptParser.parse(rawText);

    // Debug: Print parsed receipt data as JSON to console
    if (kDebugMode) {
      print('\n');
      print('═══════════════════════════════════════════════════════════');
      print('📊 PARSED RECEIPT DATA (JSON):');
      print('═══════════════════════════════════════════════════════════');
      const encoder = JsonEncoder.withIndent('  ');
      print(encoder.convert(receiptData.toJson()));
      print('═══════════════════════════════════════════════════════════');
      print('\n');
    }

    if (!receiptData.hasData) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Konnte keine Rechnungsdaten extrahieren.\n'
              'Öffne das Formular zum manuellen Eingeben.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('OCR Rohtext'),
                    content: SingleChildScrollView(child: Text(rawText)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Schließen'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      await openAddInvoiceWithData(
        context,
        people: people,
        receiptData: receiptData,
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Scannen: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  } finally {
    ocrService.dispose();
  }
}
