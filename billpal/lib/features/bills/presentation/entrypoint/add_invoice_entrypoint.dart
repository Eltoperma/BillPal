import 'package:billpal/features/bills/presentation/pages/add_invoice_form.dart';
import 'package:billpal/shared/domain/entities.dart';
import 'package:flutter/material.dart';

/// Welche UI soll für die Quellenwahl genutzt werden?
//enum AddInvoiceUI { sheet, menu, adaptive }

/// Ein Entry-Button, der entweder ein Bottom-Sheet öffnet (iOS-Style)
/// oder ein MenuAnchor (Desktop/Web-Style). Umschaltbar per [ui].
class AddInvoiceEntryButton extends StatelessWidget {
  final List<Person> people;
  //final AddInvoiceUI ui;
  final String label;

  const AddInvoiceEntryButton({
    super.key,
    required this.people,
    //this.ui = AddInvoiceUI.adaptive,
    this.label = 'Rechnung teilen',
  });

  bool _useMenu(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _useMenu(context)
        ? _MenuAnchorButton(people: people, label: label)
        : FloatingActionButton.extended(
            onPressed: () => _openChoiceSheet(context, people: people),
            icon: const Icon(Icons.add),
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            label: Text(label),
          );
  }
}

/// Variante 1: Action-Sheet (BottomSheet)
Future<void> _openChoiceSheet(
  BuildContext context, {
  required List<Person> people,
}) async {
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
            title: const Text('Manuell eingeben'),
            onTap: () async {
              Navigator.pop(ctx);
              await openAddInvoice(context, people: people);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Foto aufnehmen'),
            onTap: () {
              Navigator.pop(ctx);
              _comingSoon(context, 'Foto aufnehmen');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Aus Galerie/Dateien importieren'),
            onTap: () {
              Navigator.pop(ctx);
              _comingSoon(context, 'Import aus Galerie/Dateien');
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
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
          onPressed: () {
            _menu.close();
            _comingSoon(context, 'Foto aufnehmen');
          },
          child: const Text('Foto aufnehmen'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.image_outlined),
          onPressed: () {
            _menu.close();
            _comingSoon(context, 'Import aus Galerie/Dateien');
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

/// Einfache „Bald verfügbar“-Info
void _comingSoon(BuildContext context, String feature) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Bald verfügbar'),
      content: Text(
        '$feature wird demnächst ergänzt.\n\n'
        'Hier würdest du eine neue Rechnung automatisch hinzufügen:\n'
        '📷 Foto machen oder auswählen\n'
        '🤖 OCR zum automatischen Auslesen\n'
        '👥 Freunde auswählen\n'
        '💰 Beträge aufteilen\n'
        '📅 Event zuordnen',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
