import 'package:billpal/models/financial_data.dart';
import 'package:flutter/material.dart';

class EventSuggestionsList extends StatelessWidget {
  final List<EventSuggestion> suggestions;
  const EventSuggestionsList({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event-Vorschläge',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, i) => _SuggestionCard(s: suggestions[i]),
          ),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final EventSuggestion s;
  const _SuggestionCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(s.icon, size: 20, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.eventName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            s.formattedDate,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const Spacer(),
          Text(
            s.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
