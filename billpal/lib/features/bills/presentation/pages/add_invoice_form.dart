import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- simple models just for the form (kannst du später in domain/models ziehen) ---
class Person {
  final String id;
  final String name;
  const Person({required this.id, required this.name});
}

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

class AddInvoiceForm extends StatefulWidget {
  final List<Person> people;
  final void Function(InvoiceData data)? onSubmit;
  const AddInvoiceForm({super.key, required this.people, this.onSubmit});

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
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _dateTime,
      locale: const Locale('de', 'DE'),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null) return;
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

  void _submit() {
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
    final data = InvoiceData(
      title: _titleCtrl.text.trim(),
      dateTime: _dateTime,
      items: List.unmodifiable(_items),
    );
    widget.onSubmit?.call(data);
    Navigator.of(context).maybePop();
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
              child: DropdownButtonFormField<Person>(
                value: _assignee,
                items: widget.people
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
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
}
