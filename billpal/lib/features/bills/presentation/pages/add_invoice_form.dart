import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../infrastructure/ocr/receipt_data.dart';
import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/shared/application/services.dart';
import '../../bill_service.dart';
import '../../../../core/logging/app_logger.dart';

class LineItem {
  String description;
  double? amount;
  Person? assignee;
  LineItem({this.description = '', this.amount, this.assignee});
}

class InvoiceData {
  final String title;
  final DateTime dateTime;
  final List<LineItem> items;
  double get total => items.fold(0.0, (s, i) => s + (i.amount ?? 0));
  InvoiceData({
    required this.title,
    required this.dateTime,
    required this.items,
  });
}

Future<void> openAddInvoice(
  BuildContext context, {
  required List<Person> people,
  void Function(InvoiceData data)? onSubmit,
}) async {
  final width = MediaQuery.of(context).size.width;
  final child = AddInvoiceForm(people: people, onSubmit: onSubmit);

  if (width < 700) {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          initialChildSize: 0.85,
          builder: (_, scrollController) =>
              SingleChildScrollView(controller: scrollController, child: child),
        ),
      ),
    );
  } else {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }
}

Future<void> openAddInvoiceWithData(
  BuildContext context, {
  required List<Person> people,
  required ReceiptData receiptData,
  void Function(InvoiceData data)? onSubmit,
}) async {
  final width = MediaQuery.of(context).size.width;
  final child = AddInvoiceForm(
    people: people,
    onSubmit: onSubmit,
    initialReceiptData: receiptData,
  );

  if (width < 700) {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          initialChildSize: 0.85,
          builder: (_, scrollController) =>
              SingleChildScrollView(controller: scrollController, child: child),
        ),
      ),
    );
  } else {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }
}

class AddInvoiceForm extends StatefulWidget {
  final List<Person> people;
  final void Function(InvoiceData data)? onSubmit;
  final ReceiptData? initialReceiptData;

  const AddInvoiceForm({
    super.key,
    required this.people,
    this.onSubmit,
    this.initialReceiptData,
  });

  @override
  State<AddInvoiceForm> createState() => _AddInvoiceFormState();
}

class _AddInvoiceFormState extends State<AddInvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  DateTime _dateTime = DateTime.now();
  final _items = <LineItem>[LineItem()];

  final _currencyFmt = NumberFormat.currency(locale: 'de_DE', symbol: '€');

  @override
  void initState() {
    super.initState();
    if (widget.initialReceiptData != null) {
      _populateFormFromReceipt(widget.initialReceiptData!);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  /// Sichere Konvertierung der User-ID zu int - kritischer Fix für Demo-Mode
  int _getUserIdSafely(String userId) {
    // Demo-Mode User IDs sicher zu int konvertieren
    switch (userId) {
      case 'user_me':
      case 'current_user':
        return 1; // App-User ist immer ID 1
      case 'friend_1':
        return 2;
      case 'friend_2':
        return 3;
      case 'friend_3':
        return 4;
      case 'friend_4':
        return 5;
      case 'friend_5':
        return 6;
      case 'friend_6':
        return 7;
      default:
        // Versuche int.parse, fallback zu 1 bei Fehlern
        try {
          return int.parse(userId);
        } catch (e) {
          AppLogger.bills.warning(
            '⚠️ User-ID "$userId" nicht parsebar, verwende Fallback ID 1',
          );
          return 1;
        }
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _dateTime,
      locale: const Locale('de', 'DE'),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;
    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _addItem() => setState(() => _items.add(LineItem()));
  void _removeItem(int index) => setState(() => _items.removeAt(index));

  double get _total => _items.fold(0.0, (s, i) => s + (i.amount ?? 0.0));

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final hasValidItem = _items.any(
      (i) =>
          i.description.trim().isNotEmpty &&
          (i.amount != null && i.amount! > 0) &&
          i.assignee != null,
    );
    if (!hasValidItem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte mindestens eine gültige Position angeben.'),
        ),
      );
      return;
    }

    // InvoiceData für Callback erstellen
    final data = InvoiceData(
      title: _titleCtrl.text.trim(),
      dateTime: _dateTime,
      items: List.unmodifiable(_items),
    );

    // BillService aufrufen um in DB zu speichern
    try {
      AppLogger.bills.info('🟡 Starte Speichervorgang...');
      final billService = BillService();

      // LineItems zu LineItemData konvertieren
      AppLogger.bills.debug('🟡 Konvertiere ${_items.length} Items...');
      final lineItemsData = <LineItemData>[];

      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];
        AppLogger.bills.debug(
          '🟡 Item ${i + 1}: "${item.description}" - Amount: ${item.amount} - Assignee: ${item.assignee?.name} (ID: ${item.assignee?.id})',
        );

        // Validierung
        if (item.description.trim().isEmpty ||
            item.amount == null ||
            item.amount! <= 0 ||
            item.assignee == null) {
          AppLogger.bills.debug('⚠️ Item ${i + 1} übersprungen (ungültig)');
          continue;
        }

        // Person ID zu int konvertieren
        int? assigneeUserId;
        try {
          assigneeUserId = int.parse(item.assignee!.id);
          AppLogger.bills.debug(
            '✅ Person ID "${item.assignee!.id}" → $assigneeUserId',
          );
        } catch (e) {
          AppLogger.bills.error(
            '❌ Fehler bei Person ID Konvertierung: "${item.assignee!.id}" → $e',
          );
          // Fallback: Verwende Hash-Code oder feste ID
          assigneeUserId = item.assignee!.id.hashCode.abs() % 10000;
          AppLogger.bills.debug('🔧 Fallback Person ID: $assigneeUserId');
        }

        lineItemsData.add(
          LineItemData(
            description: item.description,
            amount: item.amount!,
            assigneeUserId: assigneeUserId,
          ),
        );
      }

      AppLogger.bills.debug('🟡 Gültige Items: ${lineItemsData.length}');
      AppLogger.bills.debug('🟡 Titel: "${_titleCtrl.text.trim()}"');
      AppLogger.bills.debug('🟡 Datum: $_dateTime');

      // In DB speichern
      AppLogger.bills.info('🟡 Rufe BillService.saveInvoiceData auf...');
      final currentUser = await UserService().getCurrentUser();
      final billId = await billService.saveInvoiceData(
        title: _titleCtrl.text.trim(),
        dateTime: _dateTime,
        userId: _getUserIdSafely(currentUser.id),
        lineItems: lineItemsData,
      );

      AppLogger.bills.success('✅ Rechnung gespeichert! Bill-ID: $billId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rechnung erfolgreich gespeichert! ID: $billId'),
            backgroundColor: Colors.green,
          ),
        );

        // Callback aufrufen falls gesetzt
        widget.onSubmit?.call(data);
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat(
      'EEE, dd.MM.yyyy – HH:mm',
      'de_DE',
    ).format(_dateTime);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Rechnung hinzufügen',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: 'Schließen',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Titel *',
                hintText: 'z. B. Pizzaabend, Airbnb, Tanken',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Titel erforderlich' : null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Datum & Zeit *',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event),
                    const SizedBox(width: 12),
                    Expanded(child: Text(dateLabel)),
                    const Icon(Icons.schedule),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Positionen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Position hinzufügen'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < _items.length; i++) ...[
              _LineItemRow(
                key: ValueKey('line-$i'),
                item: _items[i],
                people: widget.people,
                onChanged: (updated) => setState(() => _items[i] = updated),
                onRemove: _items.length > 1 ? () => _removeItem(i) : null,
              ),
              const SizedBox(height: 8),
            ],
            const Divider(height: 24),
            Row(
              children: [
                const Text(
                  'Summe',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(_currencyFmt.format(_total)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Abbrechen'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: const Text('Speichern'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LineItemRow extends StatefulWidget {
  final LineItem item;
  final List<Person> people;
  final void Function(LineItem) onChanged;
  final VoidCallback? onRemove;
  const _LineItemRow({
    super.key,
    required this.item,
    required this.people,
    required this.onChanged,
    this.onRemove,
  });

  @override
  State<_LineItemRow> createState() => _LineItemRowState();
}

class _LineItemRowState extends State<_LineItemRow> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;
  Person? _assignee;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.item.description);
    _amountCtrl = TextEditingController(
      text: widget.item.amount?.toStringAsFixed(2) ?? '',
    );
    _assignee = widget.item.assignee;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final parsed = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    widget.onChanged(
      LineItem(
        description: _descCtrl.text,
        amount: parsed,
        assignee: _assignee,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bezeichnung',
                  hintText: 'z. B. Margherita, Maut',
                ),
                onChanged: (_) => _emit(),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Erforderlich' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Betrag (Brutto)',
                  prefixText: '€ ',
                ),
                onChanged: (_) => _emit(),
                validator: (v) {
                  final val = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (val == null) return 'Ungültig';
                  if (val <= 0) return 'Muss > 0 sein';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: widget.people.isEmpty
                  ? _buildAddFriendButton()
                  : DropdownButtonFormField<Person>(
                      initialValue: _assignee,
                      items: widget.people
                          .map(
                            (p) =>
                                DropdownMenuItem(value: p, child: Text(p.name)),
                          )
                          .toList(),
                      onChanged: (p) {
                        setState(() => _assignee = p);
                        _emit();
                      },
                      decoration: const InputDecoration(labelText: 'Person'),
                      validator: (v) => v == null ? 'Bitte wählen' : null,
                    ),
            ),
            if (widget.onRemove != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Position entfernen',
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddFriendButton() {
    return OutlinedButton.icon(
      onPressed: () => _showAddFriendQuickDialog(),
      icon: Icon(Icons.person_add, size: 16),
      label: Text('Freund hinzufügen'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Future<void> _showAddFriendQuickDialog() async {
    final userService = UserService();

    final result = await showDialog<Person>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schnell Freund hinzufügen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Du hast noch keine Freunde hinzugefügt.'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Name des Freundes',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (name) async {
                if (name.trim().isNotEmpty) {
                  try {
                    final newFriend = await userService.addFriend(
                      name: name.trim(),
                    );
                    Navigator.pop(context, newFriend);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to full friends management
              Navigator.pop(context);
              Navigator.pushNamed(context, '/friends');
            },
            child: Text('Freunde verwalten'),
          ),
        ],
      ),
    );

    if (result != null) {
      // Refresh parent widget to show new friend
      // (This is a quick solution - in real app you'd use state management)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.name} wurde hinzugefügt! Bitte Form neu öffnen.',
          ),
        ),
      );
    }
  }
}
