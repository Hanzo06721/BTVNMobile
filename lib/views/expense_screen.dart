import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';
import '../models/expense.dart';
import 'login_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _controller = ExpenseController();
  final _searchCtrl = TextEditingController();
  final _money = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final _dateFmt = DateFormat('dd/MM/yyyy');

  List<Expense> _expenses = [];
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final q = _searchCtrl.text.trim();
    final list = q.isEmpty
        ? await _controller.fetchExpenses()
        : await _controller.searchExpenses(q);
    final total = await _controller.totalAmount();
    if (!mounted) return;
    setState(() {
      _expenses = list;
      _total = total;
    });
  }

  // Dùng chung cho Thêm (expense == null) và Sửa
  Future<void> _showForm({Expense? expense}) async {
    final contentCtrl = TextEditingController(text: expense?.content ?? '');
    final amountCtrl = TextEditingController(
        text: expense == null ? '' : expense.amount.toStringAsFixed(0));
    final noteCtrl = TextEditingController(text: expense?.note ?? '');
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(expense == null ? 'Thêm khoản chi' : 'Sửa khoản chi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(labelText: 'Nội dung chi tiêu'),
                ),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số tiền (₫)'),
                ),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error!,
                        style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            FilledButton(
              onPressed: () async {
                final content = contentCtrl.text.trim();
                final amount = double.tryParse(amountCtrl.text.trim());
                if (content.isEmpty || amount == null || amount <= 0) {
                  setLocal(() => error = 'Nhập nội dung và số tiền lớn hơn 0');
                  return;
                }
                if (expense == null) {
                  await _controller.insertExpense(Expense(
                      content: content, amount: amount, note: noteCtrl.text.trim()));
                } else {
                  expense.content = content;
                  expense.amount = amount;
                  expense.note = noteCtrl.text.trim();
                  await _controller.updateExpense(expense);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Expense e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa khoản chi?'),
        content: Text('"${e.content}" sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      await _controller.deleteExpense(e.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiêu cá nhân'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng chi tiêu'),
                Text(_money.format(_total),
                    style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Tìm theo nội dung hoặc ghi chú...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _load();
                        },
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text('Chưa có khoản chi nào. Nhấn + để thêm.'))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, i) {
                      final e = _expenses[i];
                      final date = _dateFmt.format(DateTime.parse(e.date));
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          title: Text(e.content),
                          subtitle: Text(e.note.isEmpty ? date : '${e.note}\n$date'),
                          isThreeLine: e.note.isNotEmpty,
                          onTap: () => _showForm(expense: e),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_money.format(e.amount),
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              IconButton(
                                icon: Icon(Icons.delete, color: scheme.error),
                                onPressed: () => _confirmDelete(e),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
