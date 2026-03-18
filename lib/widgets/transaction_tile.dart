import 'package:flutter/material.dart';
import '../models/transaction_item.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem item;
  final String title;
  final String subtitle;
  final String amountText;
  final Color amountColor;
  final IconData icon;
  final String editLabel;
  final String deleteLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionTile({
    super.key,
    required this.item,
    required this.title,
    required this.subtitle,
    required this.amountText,
    required this.amountColor,
    required this.icon,
    required this.editLabel,
    required this.deleteLabel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xffeef3ff),
        child: Icon(icon, color: const Color(0xff4764b1)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            amountText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(value: 'edit', child: Text(editLabel)),
              PopupMenuItem<String>(value: 'delete', child: Text(deleteLabel)),
            ],
          ),
        ],
      ),
    );
  }
}
