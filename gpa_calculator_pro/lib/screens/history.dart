import 'package:flutter/material.dart';

import '../services/app_store.dart';

class History extends StatelessWidget {
  const History({super.key, required this.store});

  final AppStore store;

  Future<void> _confirmDelete(BuildContext context, int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete semester?'),
        content: const Text('This saved result will be removed from GPA History.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await store.removeRecord(index);
  }

  @override
  Widget build(BuildContext context) {
    if (store.history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No saved semester results yet.'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: store.history.length,
      itemBuilder: (context, index) {
        final record = store.history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              child: Text(record.gpa.toStringAsFixed(1)),
            ),
            title: Text(
              record.semester,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${record.date.day}/${record.date.month}/${record.date.year} • ${record.courses.length} courses • ${record.totalCredits.toStringAsFixed(1)} credits',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  record.gpa.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context, index),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            children: [
              for (final course in record.courses)
                ListTile(
                  leading: const Icon(Icons.book_outlined),
                  title: Text(course.name),
                  subtitle: Text(
                    '${course.code.isEmpty ? '' : '${course.code} • '}${course.credit.toStringAsFixed(1)} credits',
                  ),
                  trailing: Text(
                    '${course.grade}  ${(record.scale[course.grade] ?? 0).toStringAsFixed(2)}',
                  ),
                ),
              const Divider(height: 1),
              ListTile(
                title: Text(
                  'Total Grade Points: ${record.totalGradePoints.toStringAsFixed(2)}',
                ),
                trailing: Text(
                  'GPA ${record.gpa.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
