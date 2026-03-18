import 'package:flutter/material.dart';
import '../models/transaction_draft.dart';
import '../models/transaction_item.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String title;
  final bool showIncome;
  final List<String> categories;
  final List<TransactionItem> initialItems;
  final String Function(String) t;
  final String Function(double) formatMoney;
  final String Function(DateTime) formatDate;
  final IconData Function(String) iconForCategory;
  final void Function(TransactionItem oldItem, TransactionDraft draft) onUpdate;
  final void Function(TransactionItem item) onDelete;

  const TransactionHistoryScreen({
    super.key,
    required this.title,
    required this.showIncome,
    required this.categories,
    required this.initialItems,
    required this.t,
    required this.formatMoney,
    required this.formatDate,
    required this.iconForCategory,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late List<TransactionItem> items;

  @override
  void initState() {
    super.initState();
    items = List<TransactionItem>.from(widget.initialItems)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> handleEdit(TransactionItem item) async {
    final draft = await Navigator.push<TransactionDraft>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionEditorPage(
          title: widget.t('edit_transaction'),
          categories: widget.categories,
          t: widget.t,
          formatDate: widget.formatDate,
          initialItem: item,
        ),
      ),
    );
    if (draft == null) return;
    widget.onUpdate(item, draft);
    setState(() {
      final matchesPage = draft.isIncome == widget.showIncome;
      if (!matchesPage) {
        items.removeWhere((e) => e.id == item.id);
      } else {
        final index = items.indexWhere((e) => e.id == item.id);
        if (index != -1) {
          items[index] = TransactionItem(
            id: item.id,
            categoryKey: draft.categoryKey,
            amount: draft.amount,
            isIncome: draft.isIncome,
            note: draft.note,
            date: draft.date,
          );
        }
      }
      items.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void handleDelete(TransactionItem item) {
    widget.onDelete(item);
    setState(() {
      items.removeWhere((e) => e.id == item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: items.isEmpty
            ? Center(child: Text(widget.t('no_transactions')))
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final categoryLabel = widget.t(item.categoryKey) == item.categoryKey
                      ? item.categoryKey.replaceAll('_', ' ')
                      : widget.t(item.categoryKey);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TransactionTile(
                      item: item,
                      title: categoryLabel,
                      subtitle: '${widget.formatDate(item.date)}${item.note.isNotEmpty ? ' • ${item.note}' : ''}',
                      amountText: '${item.isIncome ? '+' : '-'}${widget.formatMoney(item.amount)}',
                      amountColor: item.isIncome ? const Color(0xff27a44b) : const Color(0xffdc4c5a),
                      icon: widget.iconForCategory(item.categoryKey),
                      editLabel: widget.t('edit'),
                      deleteLabel: widget.t('delete'),
                      onEdit: () => handleEdit(item),
                      onDelete: () => handleDelete(item),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
