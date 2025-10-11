import 'package:flutter/material.dart';

class AddBillFab extends StatelessWidget {
  final VoidCallback onPressed;
  const AddBillFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Rechnung teilen'),
    );
  }
}
