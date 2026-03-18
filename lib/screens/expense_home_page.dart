import 'package:flutter/material.dart';
import '../data/app_strings.dart';
import '../models/transaction_draft.dart';
import '../models/transaction_item.dart';
import '../widgets/balance_card.dart';
import '../widgets/info_tile.dart';
import '../widgets/section_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'category_detail_screen.dart';
import 'transaction_history_screen.dart';

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  int currentIndex = 0;
  int nextId = 100;
  String language = 'vi';

  final List<String> categories = <String>[
    'food',
    'transport',
    'entertainment',
    'shopping',
    'rent',
    'salary',
    'other',
  ];

  late List<TransactionItem> transactions = <TransactionItem>[
    TransactionItem(
      id: 1,
      categoryKey: 'salary',
      amount: 5000000,
      isIncome: true,
      note: 'Lương tháng',
      date: DateTime(2026, 3, 20),
    ),
    TransactionItem(
      id: 2,
      categoryKey: 'food',
      amount: 120000,
      isIncome: false,
      note: 'Bữa trưa',
      date: DateTime(2026, 3, 20),
    ),
    TransactionItem(
      id: 3,
      categoryKey: 'transport',
      amount: 50000,
      isIncome: false,
      note: 'Đi xe buýt',
      date: DateTime(2026, 3, 20),
    ),
    TransactionItem(
      id: 4,
      categoryKey: 'entertainment',
      amount: 80000,
      isIncome: false,
      note: 'Xem phim',
      date: DateTime(2026, 3, 19),
    ),
    TransactionItem(
      id: 5,
      categoryKey: 'other',
      amount: 80000,
      isIncome: false,
      note: 'Chi khác',
      date: DateTime(2026, 3, 19),
    ),
  ];

  String t(String key) => AppStrings.data[language]?[key] ?? key;

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void switchLanguage() {
    setState(() {
      language = language == 'vi' ? 'en' : 'vi';
    });
    showMessage(t('language_saved'));
  }

  String normalizeCategoryKey(String raw) {
    return raw.trim().toLowerCase().replaceAll(' ', '_');
  }

  String labelForCategory(String key) {
    final translated = t(key);
    if (translated != key) return translated;
    return key.replaceAll('_', ' ');
  }

  IconData iconForCategory(String key) {
    switch (key) {
      case 'food':
        return Icons.lunch_dining;
      case 'transport':
        return Icons.directions_bus;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'rent':
        return Icons.house;
      case 'salary':
        return Icons.payments;
      default:
        return Icons.category;
    }
  }

  double get totalIncome => transactions
      .where((e) => e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpense => transactions
      .where((e) => !e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get balance => totalIncome - totalExpense;

  List<TransactionItem> transactionsByCategory(String categoryKey) {
    return transactions.where((t) => t.categoryKey == categoryKey).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double categoryTotal(String categoryKey) {
    return transactionsByCategory(categoryKey).fold(0.0, (sum, item) {
      return sum + (item.isIncome ? item.amount : -item.amount);
    });
  }

  String formatMoney(double value) {
    final text = value.toStringAsFixed(0);
    final chars = text.split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(chars[i]);
    }
    return '${buffer.toString().split('').reversed.join()} đ';
  }

  String formatSignedMoney(double value) {
    final prefix = value >= 0 ? '+' : '-';
    return '$prefix${formatMoney(value.abs())}';
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  TransactionItem itemFromDraft(TransactionDraft draft, {int? keepId}) {
    return TransactionItem(
      id: keepId ?? nextId++,
      categoryKey: draft.categoryKey,
      amount: draft.amount,
      isIncome: draft.isIncome,
      note: draft.note,
      date: draft.date,
    );
  }

  void addCategory(String raw) {
    final key = normalizeCategoryKey(raw);
    if (key.isEmpty || categories.contains(key)) return;
    setState(() {
      categories.add(key);
    });
    showMessage(t('category_added'));
  }

  void renameCategory(String oldKey, String raw) {
    final newKey = normalizeCategoryKey(raw);
    if (newKey.isEmpty) return;
    if (oldKey == newKey) return;
    if (categories.contains(newKey)) return;

    setState(() {
      final categoryIndex = categories.indexOf(oldKey);
      if (categoryIndex != -1) {
        categories[categoryIndex] = newKey;
      }
      transactions = transactions
          .map((item) => item.categoryKey == oldKey
              ? TransactionItem(
                  id: item.id,
                  categoryKey: newKey,
                  amount: item.amount,
                  isIncome: item.isIncome,
                  note: item.note,
                  date: item.date,
                )
              : item)
          .toList();
    });
    showMessage(t('category_updated'));
  }

  void deleteCategory(String key) {
    if (categories.length <= 1) {
      showMessage(t('cannot_delete_last_category'));
      return;
    }
    setState(() {
      categories.remove(key);
      transactions.removeWhere((item) => item.categoryKey == key);
    });
    showMessage(t('category_deleted'));
  }

  void addTransaction(TransactionDraft draft) {
    setState(() {
      transactions.insert(0, itemFromDraft(draft));
      currentIndex = 0;
    });
    showMessage(t('transaction_saved'));
  }

  void updateTransaction(TransactionItem oldItem, TransactionDraft draft) {
    final index = transactions.indexWhere((e) => e.id == oldItem.id);
    if (index == -1) return;
    setState(() {
      transactions[index] = itemFromDraft(draft, keepId: oldItem.id);
      currentIndex = 0;
    });
    showMessage(t('transaction_updated'));
  }

  void deleteTransaction(TransactionItem item) {
    setState(() {
      transactions.removeWhere((e) => e.id == item.id);
    });
    showMessage(t('transaction_deleted'));
  }

  Future<void> openEditEditor(TransactionItem item) async {
    final draft = await Navigator.push<TransactionDraft>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionEditorPage(
          title: t('edit_transaction'),
          categories: categories,
          t: t,
          formatDate: formatDate,
          initialItem: item,
        ),
      ),
    );
    if (draft != null) {
      updateTransaction(item, draft);
    }
  }

  Widget buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff3d89ff), Color(0xff2e4ab9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: switchLanguage,
            child: Row(
              children: [
                Text(
                  language.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('🇻🇳 🇬🇧', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHomeTab() {
    final recent = List<TransactionItem>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          BalanceCard(
            title: t('balance'),
            amount: formatSignedMoney(balance),
          ),
          const SizedBox(height: 14),
          InfoTile(
            title: t('income'),
            value: '+${formatMoney(totalIncome)}',
            color: const Color(0xff27a44b),
          ),
          const SizedBox(height: 10),
          InfoTile(
            title: t('expense'),
            value: '-${formatMoney(totalExpense)}',
            color: const Color(0xffdc4c5a),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => currentIndex = 2),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xff4488ff),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_box_outlined),
              label: Text(t('add_transaction')),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: t('recent_transactions'),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionHistoryScreen(
                            title: t('history'),
                            showIncome: true,
                            categories: categories,
                            initialItems: recent,
                            t: t,
                            formatMoney: formatMoney,
                            formatDate: formatDate,
                            iconForCategory: iconForCategory,
                            onUpdate: updateTransaction,
                            onDelete: deleteTransaction,
                          ),
                        ),
                      );
                    },
                    child: Text(t('view_all')),
                  ),
                ),
                ...recent.take(8).map((item) {
                  return TransactionTile(
                    item: item,
                    title: labelForCategory(item.categoryKey),
                    subtitle: '${formatDate(item.date)}${item.note.isNotEmpty ? ' • ${item.note}' : ''}',
                    amountText: '${item.isIncome ? '+' : '-'}${formatMoney(item.amount)}',
                    amountColor: item.isIncome ? const Color(0xff27a44b) : const Color(0xffdc4c5a),
                    icon: iconForCategory(item.categoryKey),
                    editLabel: t('edit'),
                    deleteLabel: t('delete'),
                    onEdit: () => openEditEditor(item),
                    onDelete: () => deleteTransaction(item),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoriesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final key = categories[index];
                final total = categoryTotal(key);
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryDetailScreen(
                          categoryKey: key,
                          title: labelForCategory(key),
                          categories: categories,
                          initialItems: transactionsByCategory(key),
                          t: t,
                          formatMoney: formatMoney,
                          formatSignedMoney: formatSignedMoney,
                          formatDate: formatDate,
                          iconForCategory: iconForCategory,
                          onAdd: addTransaction,
                          onUpdate: updateTransaction,
                          onDelete: deleteTransaction,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xffeef3ff),
                          child: Icon(iconForCategory(key), color: const Color(0xff4764b1)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            labelForCategory(key),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          formatSignedMoney(total),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: total >= 0 ? const Color(0xff27a44b) : const Color(0xffdc4c5a),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              showEditCategoryDialog(key);
                            } else if (value == 'delete') {
                              showDeleteCategoryDialog(key);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'edit', child: Text(t('edit_category'))),
                            PopupMenuItem(value: 'delete', child: Text(t('delete_category'))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: showAddCategoryDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4488ff),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add),
              label: Text(t('add_category')),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('tap_income'),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionHistoryScreen(
                    title: t('income_history'),
                    showIncome: true,
                    categories: categories,
                    initialItems: transactions.where((e) => e.isIncome).toList(),
                    t: t,
                    formatMoney: formatMoney,
                    formatDate: formatDate,
                    iconForCategory: iconForCategory,
                    onUpdate: updateTransaction,
                    onDelete: deleteTransaction,
                  ),
                ),
              );
            },
            child: InfoTile(
              title: t('income'),
              value: '+${formatMoney(totalIncome)}',
              color: const Color(0xff27a44b),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t('tap_expense'),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionHistoryScreen(
                    title: t('expense_history'),
                    showIncome: false,
                    categories: categories,
                    initialItems: transactions.where((e) => !e.isIncome).toList(),
                    t: t,
                    formatMoney: formatMoney,
                    formatDate: formatDate,
                    iconForCategory: iconForCategory,
                    onUpdate: updateTransaction,
                    onDelete: deleteTransaction,
                  ),
                ),
              );
            },
            child: InfoTile(
              title: t('expense'),
              value: '-${formatMoney(totalExpense)}',
              color: const Color(0xffdc4c5a),
            ),
          ),
          const SizedBox(height: 16),
          InfoTile(
            title: t('balance'),
            value: formatSignedMoney(balance),
            color: const Color(0xff4488ff),
          ),
        ],
      ),
    );
  }

  Widget buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SectionCard(
            title: t('team_name'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('group_members'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text('Nguyễn Tiến Dũng - 23010552'),
                const SizedBox(height: 14),
                Text(
                  t('topic'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(t('topic_value')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: t('university'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('university_value'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                Text(
                  t('course'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  t('course_value'),
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('add_category')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: t('category_name')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              addCategory(controller.text);
              Navigator.pop(context);
            },
            child: Text(t('ok')),
          ),
        ],
      ),
    );
  }

  void showEditCategoryDialog(String categoryKey) {
    final controller = TextEditingController(text: labelForCategory(categoryKey));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('edit_category')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: t('category_name')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              renameCategory(categoryKey, controller.text);
              Navigator.pop(context);
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  void showDeleteCategoryDialog(String categoryKey) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('delete_category')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('delete_category_confirm')),
            const SizedBox(height: 8),
            Text(
              labelForCategory(categoryKey),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (transactionsByCategory(categoryKey).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(t('delete_category_with_items')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              deleteCategory(categoryKey);
              Navigator.pop(context);
            },
            child: Text(t('delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      buildHomeTab(),
      buildCategoriesTab(),
      AddTransactionTab(
        categories: categories,
        t: t,
        formatDate: formatDate,
        onSubmit: addTransaction,
      ),
      buildReportsTab(),
      buildAboutTab(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(
              currentIndex == 0
                  ? t('app_name')
                  : currentIndex == 1
                      ? t('categories')
                      : currentIndex == 2
                          ? t('add_transaction')
                          : currentIndex == 3
                              ? t('reports')
                              : t('about_us'),
            ),
            Expanded(child: tabs[currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff1f3163), Color(0xff3e6ee9)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: t('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.wallet),
              label: t('categories'),
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff4b8dff),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              label: t('add'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.insert_chart_outlined),
              label: t('reports'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              label: t('about'),
            ),
          ],
        ),
      ),
    );
  }
}
