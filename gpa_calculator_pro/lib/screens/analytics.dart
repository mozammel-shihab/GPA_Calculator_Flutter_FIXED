import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/app_store.dart';

class Analytics extends StatelessWidget {
  const Analytics({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    if (store.history.isEmpty) {
      return const Center(
        child: Text('Save at least one semester to see analytics.'),
      );
    }

    final chronological = store.history.reversed.toList();
    final best = store.history.reduce((a, b) => a.gpa >= b.gpa ? a : b);
    final highestCredits =
        store.history.reduce((a, b) => a.totalCredits >= b.totalCredits ? a : b);
    final average = store.history.map((e) => e.gpa).reduce((a, b) => a + b) /
        store.history.length;

    final spots = chronological.asMap().entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.gpa))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _metric(context, 'Best GPA', best.gpa.toStringAsFixed(2), Icons.emoji_events_rounded),
              _metric(context, 'Latest GPA', store.history.first.gpa.toStringAsFixed(2), Icons.flag_rounded),
              _metric(context, 'Average GPA', average.toStringAsFixed(2), Icons.insights_rounded),
              _metric(context, 'Highest Credits', highestCredits.totalCredits.toStringAsFixed(1), Icons.menu_book_rounded),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GPA Progress',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 4.2,
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('${value.toInt() + 1}'),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 4,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return SizedBox(
      width: 205,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(label),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
