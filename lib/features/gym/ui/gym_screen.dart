import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:fourteen_november/theme/app_colors.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _date(dynamic value) => DateTime.parse(value as String);
bool _within(DateTime d, DateTime start, DateTime end) =>
    !d.isBefore(start) && !d.isAfter(end);

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});
  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  final box = Hive.box(HiveService.gymBoxKey);
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  List<Map> get terms =>
      box.values.whereType<Map>().where((e) => e['type'] == 'term').toList()
        ..sort((a, b) => _date(b['start']).compareTo(_date(a['start'])));
  List<Map> get logs =>
      box.values.whereType<Map>().where((e) => e['type'] == 'log').toList()
        ..sort((a, b) => _date(b['date']).compareTo(_date(a['date'])));
  Map? get current {
    final today = _day(DateTime.now());
    for (final term in terms) {
      if (_within(today, _date(term['start']), _date(term['end']))) return term;
    }
    return null;
  }

  int countTerm(Map term) => logs
      .where(
        (l) =>
            _within(_date(l['date']), _date(term['start']), _date(term['end'])),
      )
      .length;
  String get id => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DefaultAppBar(title: const Text('Gym')),
    body: ValueListenableBuilder<Box>(
      valueListenable: box.listenable(),
      builder: (context, _, _) {
        final term = current;
        final now = _day(DateTime.now());
        final weekStart = now.subtract(Duration(days: now.weekday % 7));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final weeklyCount = logs
            .where((l) => _within(_date(l['date']), weekStart, weekEnd))
            .length;
        final colors = Theme.of(context).colorScheme;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            Text(
              'Your training days',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _stat(
                    'Left this term',
                    term == null
                        ? '—'
                        : '${((term['total'] as int) - countTerm(term)).clamp(0, 999999)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _stat(
                    'Left this week',
                    term == null
                        ? '—'
                        : '${((term['weekly'] as int) - weeklyCount).clamp(0, 999999)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current term',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    term == null
                        ? 'No active term'
                        : '${DateFormat.yMMMd().format(_date(term['start']))} – ${DateFormat.yMMMd().format(_date(term['end']))}',
                  ),
                  if (term != null) ...[
                    const SizedBox(height: 8),
                    Text('${countTerm(term)} / ${term['total']} sessions'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (countTerm(term) / (term['total'] as int)).clamp(
                        0.0,
                        1.0,
                      ),
                      color: colors.secondary,
                    ),
                  ],
                  TextButton(
                    onPressed: _manageTerms,
                    child: const Text('Manage terms →'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _calendar(term),
            const SizedBox(height: 12),
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent sessions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (logs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text('No sessions logged yet.'),
                    ),
                  ...logs
                      .take(10)
                      .map(
                        (log) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.calendar_today_outlined,
                            color: colors.secondary,
                          ),
                          title: Text(
                            DateFormat.yMMMd().format(_date(log['date'])),
                          ),
                          trailing: IconButton(
                            tooltip: 'Delete session',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteLog(log),
                          ),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _card(
              Row(
                children: [
                  Icon(Icons.bar_chart, color: colors.secondary),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('All-time sessions')),
                  Text(
                    '${logs.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _addLog,
      backgroundColor: AppColors.secondary,
      child: const Icon(Icons.add),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(22),
    ),
    child: child,
  );
  Widget _stat(String label, String value) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
  Widget _calendar(Map? term) {
    final colors = Theme.of(context).colorScheme;
    final offset = month.weekday % 7;
    final length = DateTime(month.year, month.month + 1, 0).day;
    final dates = logs.map((l) => _date(l['date'])).toSet();
    return _card(
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(
                  () => month = DateTime(month.year, month.month - 1),
                ),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat.yMMMM().format(month),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: () => setState(
                  () => month = DateTime(month.year, month.month + 1),
                ),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: offset + length,
            itemBuilder: (context, i) {
              if (i < offset) return const SizedBox.shrink();
              final date = DateTime(month.year, month.month, i - offset + 1);
              final logged = dates.contains(date);
              final inTerm =
                  term != null &&
                  _within(date, _date(term['start']), _date(term['end']));
              return Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: logged
                      ? colors.secondary
                      : inTerm
                      ? colors.primary.withValues(alpha: .12)
                      : null,
                  shape: BoxShape.circle,
                  border: date == _day(DateTime.now())
                      ? Border.all(color: colors.primary)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: logged ? colors.onSecondary : colors.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
          Text(
            '● Gym day    • Current term',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Future<void> _addLog() async {
    final now = _day(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (selected == null || !mounted) return;
    if (logs.any((l) => _date(l['date']) == _day(selected))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That day is already logged.')),
      );
      return;
    }
    final key = id;
    await box.put(key, {
      'type': 'log',
      'id': key,
      'date': _day(selected).toIso8601String(),
    });
  }

  Future<void> _deleteLog(Map log) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session?'),
        content: Text(DateFormat.yMMMd().format(_date(log['date']))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) await box.delete(log['id']);
  }

  void _manageTerms() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => _TermsScreen(box: box)));
}

class _TermsScreen extends StatelessWidget {
  const _TermsScreen({required this.box});
  final Box box;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DefaultAppBar(title: const Text('Gym terms')),
    body: ValueListenableBuilder<Box>(
      valueListenable: box.listenable(),
      builder: (context, _, _) {
        final terms =
            box.values
                .whereType<Map>()
                .where((e) => e['type'] == 'term')
                .toList()
              ..sort((a, b) => _date(b['start']).compareTo(_date(a['start'])));
        final logs = box.values.whereType<Map>().where(
          (e) => e['type'] == 'log',
        );
        if (terms.isEmpty) {
          return const Center(child: Text('Add your first gym term.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: terms.length,
          itemBuilder: (context, i) {
            final t = terms[i];
            final count = logs
                .where(
                  (l) => _within(
                    _date(l['date']),
                    _date(t['start']),
                    _date(t['end']),
                  ),
                )
                .length;
            return Card(
              child: ListTile(
                title: Text(
                  '${DateFormat.yMMMd().format(_date(t['start']))} – ${DateFormat.yMMMd().format(_date(t['end']))}',
                ),
                subtitle: Text(
                  '$count / ${t['total']} sessions · ${t['weekly']} per week',
                ),
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => showDialog(
        context: context,
        builder: (_) => _TermDialog(box: box),
      ),
      backgroundColor: AppColors.secondary,
      child: const Icon(Icons.add),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );
}

class _TermDialog extends StatefulWidget {
  const _TermDialog({required this.box});
  final Box box;
  @override
  State<_TermDialog> createState() => _TermDialogState();
}

class _TermDialogState extends State<_TermDialog> {
  DateTime start = _day(DateTime.now());
  late DateTime end = start.add(const Duration(days: 30));
  final total = TextEditingController(text: '12');
  final weekly = TextEditingController(text: '3');
  String? error;
  @override
  void dispose() {
    total.dispose();
    weekly.dispose();
    super.dispose();
  }

  Future<void> pick(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? start : end,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          start = _day(date);
          if (end.isBefore(start)) end = start.add(const Duration(days: 30));
        } else {
          end = _day(date);
        }
      });
    }
  }

  Future<void> save() async {
    final n = int.tryParse(total.text);
    final w = int.tryParse(weekly.text);
    if (end.isBefore(start) || n == null || n <= 0 || w == null || w <= 0) {
      setState(() => error = 'Enter valid dates and positive session counts.');
      return;
    }
    final overlaps = widget.box.values
        .whereType<Map>()
        .where((e) => e['type'] == 'term')
        .any(
          (t) =>
              !end.isBefore(_date(t['start'])) &&
              !start.isAfter(_date(t['end'])),
        );
    if (overlaps) {
      setState(() => error = 'Terms cannot overlap.');
      return;
    }
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await widget.box.put(id, {
      'type': 'term',
      'id': id,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'total': n,
      'weekly': w,
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New term'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Start date'),
            subtitle: Text(DateFormat.yMMMd().format(start)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => pick(true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('End date'),
            subtitle: Text(DateFormat.yMMMd().format(end)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => pick(false),
          ),
          TextField(
            controller: total,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Total sessions'),
          ),
          TextField(
            controller: weekly,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Weekly target'),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: save, child: const Text('Save term')),
    ],
  );
}
