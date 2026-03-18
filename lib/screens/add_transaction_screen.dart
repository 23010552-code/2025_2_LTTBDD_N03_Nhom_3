import 'package:flutter/material.dart';
import '../models/transaction_draft.dart';
import '../models/transaction_item.dart';

class AddTransactionTab extends StatelessWidget {
  final List<String> categories;
  final String Function(String) t;
  final String Function(DateTime) formatDate;
  final void Function(TransactionDraft) onSubmit;

  const AddTransactionTab({
    super.key,
    required this.categories,
    required this.t,
    required this.formatDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('add_hint'),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          TransactionFormView(
            categories: categories,
            t: t,
            formatDate: formatDate,
            clearAfterSubmit: true,
            onSubmit: onSubmit,
          ),
        ],
      ),
    );
  }
}

class TransactionEditorPage extends StatelessWidget {
  final String title;
  final List<String> categories;
  final String Function(String) t;
  final String Function(DateTime) formatDate;
  final TransactionItem? initialItem;
  final String? presetCategoryKey;
  final bool? presetIsIncome;

  const TransactionEditorPage({
    super.key,
    required this.title,
    required this.categories,
    required this.t,
    required this.formatDate,
    this.initialItem,
    this.presetCategoryKey,
    this.presetIsIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TransactionFormView(
          categories: categories,
          t: t,
          formatDate: formatDate,
          initialItem: initialItem,
          presetCategoryKey: presetCategoryKey,
          presetIsIncome: presetIsIncome,
          clearAfterSubmit: false,
          onSubmit: (draft) => Navigator.pop(context, draft),
        ),
      ),
    );
  }
}

class TransactionFormView extends StatefulWidget {
  final List<String> categories;
  final String Function(String) t;
  final String Function(DateTime) formatDate;
  final void Function(TransactionDraft) onSubmit;
  final TransactionItem? initialItem;
  final String? presetCategoryKey;
  final bool? presetIsIncome;
  final bool clearAfterSubmit;

  const TransactionFormView({
    super.key,
    required this.categories,
    required this.t,
    required this.formatDate,
    required this.onSubmit,
    this.initialItem,
    this.presetCategoryKey,
    this.presetIsIncome,
    required this.clearAfterSubmit,
  });

  @override
  State<TransactionFormView> createState() => _TransactionFormViewState();
}

class _TransactionFormViewState extends State<TransactionFormView> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  bool? isIncome;
  String? selectedCategory;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    selectedCategory = item?.categoryKey ?? widget.presetCategoryKey ?? widget.categories.first;
    isIncome = item?.isIncome ?? widget.presetIsIncome;
    selectedDate = item?.date ?? DateTime.now();
    amountController.text = item?.amount.toStringAsFixed(0) ?? '';
    noteController.text = item?.note ?? '';
  }

  @override
  void didUpdateWidget(covariant TransactionFormView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.categories.contains(selectedCategory) && widget.categories.isNotEmpty) {
      selectedCategory = widget.categories.first;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void clearForm() {
    setState(() {
      amountController.clear();
      noteController.clear();
      selectedCategory = widget.presetCategoryKey ?? widget.categories.first;
      isIncome = widget.presetIsIncome;
      selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                value: true,
                groupValue: isIncome,
                title: Text(widget.t('income')),
                onChanged: (value) => setState(() => isIncome = value),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                value: false,
                groupValue: isIncome,
                title: Text(widget.t('expense')),
                onChanged: (value) => setState(() => isIncome = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.t('amount'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: widget.t('amount'),
            suffixText: 'đ',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffd8dfef)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffd8dfef)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.t('category'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffd8dfef)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: widget.categories.map((key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(widget.t(key) == key ? key.replaceAll('_', ' ') : widget.t(key)),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedCategory = value),
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            );
            if (picked != null && mounted) {
              setState(() => selectedDate = picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffd8dfef)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined),
                const SizedBox(width: 8),
                Text(
                  widget.formatDate(selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteController,
          decoration: InputDecoration(
            hintText: widget.t('note'),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffd8dfef)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffd8dfef)),
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (isIncome == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(widget.t('select_type'))),
                );
                return;
              }
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(widget.t('enter_amount'))),
                );
                return;
              }
              widget.onSubmit(
                TransactionDraft(
                  categoryKey: selectedCategory!,
                  amount: amount,
                  isIncome: isIncome!,
                  note: noteController.text.trim(),
                  date: selectedDate,
                ),
              );
              if (widget.clearAfterSubmit) {
                clearForm();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xff4488ff),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.save_outlined),
            label: Text(widget.t('save')),
          ),
        ),
      ],
    );
  }
}
