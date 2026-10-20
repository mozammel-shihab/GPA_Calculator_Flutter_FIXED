import 'package:flutter/material.dart';

import '../services/app_store.dart';
import '../widgets/stat_card.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final average = store.history.isEmpty
        ? 0.0
        : store.history.map((e) => e.gpa).reduce((a, b) => a + b) /
            store.history.length;
    final credits = store.history.fold<double>(
      0.0,
      (sum, item) => sum + item.totalCredits,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${store.studentName} 👋',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            store.university.isEmpty
                ? 'Your academic overview'
                : store.university,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000
                  ? 4
                  : constraints.maxWidth >= 620
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 3.2 : 2.1,
                children: [
                  StatCard(
                    title: 'Latest GPA',
                    value: store.history.isEmpty
                        ? '—'
                        : store.history.first.gpa.toStringAsFixed(2),
                    icon: Icons.grade_rounded,
                  ),
                  StatCard(
                    title: 'Average GPA',
                    value: store.history.isEmpty
                        ? '—'
                        : average.toStringAsFixed(2),
                    icon: Icons.trending_up_rounded,
                  ),
                  StatCard(
                    title: 'Semesters Saved',
                    value: '${store.history.length}',
                    icon: Icons.history_rounded,
                  ),
                  StatCard(
                    title: 'Credits Completed',
                    value: credits.toStringAsFixed(1),
                    icon: Icons.menu_book_rounded,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What you can do',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Use the GPA Calculator to enter courses and calculate a semester GPA. Save results to GPA History, combine semesters for CGPA, review Analytics, create academic PDF reports, and customize the grading scale from Settings.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
