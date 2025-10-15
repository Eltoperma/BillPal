import 'package:billpal/features/settings/presentation/widgets/selection_card.dart';
import 'package:flutter/material.dart';

class OptionItem<T> {
  OptionItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.isSelected,
    required this.onSelect,
  });

  final T id;
  final String title;
  final Widget preview;
  final bool Function() isSelected;
  final VoidCallback onSelect;
}

/// Rendert bis zu 3 Optionen in **einer** Zeile.
/// Hinweis: Wenn du später >3 Optionen hast, kannst du unten die
/// Wrap-Variante aktivieren (auskommentierter Code).
class OptionsRow<T> extends StatelessWidget {
  const OptionsRow({super.key, required this.options});
  final List<OptionItem<T>> options;

  @override
  Widget build(BuildContext context) {
    final items = options.take(3).toList(); // Sicherheitsnetz
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(
            child: SelectionCard(
              title: items[i].title,
              preview: items[i].preview,
              selected: items[i].isSelected(),
              onTap: items[i].onSelect,
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
