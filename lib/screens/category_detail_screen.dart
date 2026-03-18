import 'package:flutter/material.dart';
import '../models/transaction_draft.dart';
import '../models/transaction_item.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryKey;
  final String title;
  final List<String> categories;
  final List<TransactionItem> initialItems;
  final String Function(String) t;
  final String Function(double) formatMoney;
  final String Function(double) formatSignedMoney;
  final String Function(DateTime) formatDate;
  final IconData Function(String) iconForCategory;
  final void Function(TransactionDraft) onAdd;
  final void Function(TransactionItem oldItem, TransactionDraft draft) onUpdate;
  final void Function(TransactionItem item) onDelete;

  const CategoryDetailScreen({
    super.key,
    required this.categoryKey,
    required this.title,
    required this.categories,
    required this.initialItems,
    required this.t,
    required this.formatMoney,
    required this.formatSignedMoney,
    required this.formatDate,
    required this.iconForCategory,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late List<TransactionItem> items;

  @override
  void initState() {
    super.initState();
    items = List<TransactionItem>.from(widget.initialItems)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double get total => items.fold(0.0, (sum, item) {
        return sum + (item.isIncome ? item.amount : -item.amount);
      });

  Future<void> handleAdd() async {
    final draft = await Navigator.push<TransactionDraft>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionEditorPage(
          title: widget.t('add_transaction'),
          categories: widget.categories,
          t: widget.t,
          formatDate: widget.formatDate,
          presetCategoryKey: widget.categoryKey,
          presetIsIncome: widget.categoryKey == 'salary',
        ),
      ),
    );
    if (draft == null) return;
    widget.onAdd(draft);
    if (draft.categoryKey == widget.categoryKey) {
      setState(() {
        items.insert(
          0,
          TransactionItem(
            id: DateTime.now().microsecondsSinceEpoch,
            categoryKey: draft.categoryKey,
            amount: draft.amount,
            isIncome: draft.isIncome,
            note: draft.note,
            date: draft.date,
          ),
        );
      });
    }
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
      if (draft.categoryKey != widget.categoryKey) {
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
      appBar: AppBar(title: Text('${widget.t('category_detail')} - ${widget.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.t('total')}: ${widget.formatSignedMoney(total)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: total >= 0 ? const Color(0xff27a44b) : const Color(0xffdc4c5a),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: handleAdd,
                      icon: const Icon(Icons.add),
                      label: Text(widget.t('add_for_category')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text(widget.t('no_transactions')))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TransactionTile(
                            item: item,
                            title: widget.title,
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
          ],
        ),
      ),
    );
  }
}
