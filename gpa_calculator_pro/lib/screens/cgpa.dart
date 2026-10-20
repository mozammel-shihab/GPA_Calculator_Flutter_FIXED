import 'package:flutter/material.dart';

import '../services/app_store.dart';

class Cgpa extends StatefulWidget {
  const Cgpa({super.key, required this.store});

  final AppStore store;

  @override
  State<Cgpa> createState() => _CgpaState();
}

class _CgpaState extends State<Cgpa> {
  final Set<int> _selected = <int>{};
  final _currentController = TextEditingController(text: '3.50');
  final _nextCreditsController = TextEditingController(text: '15');
  final _desiredController = TextEditingController(text: '3.70');

  @override
  void dispose() {
    _currentController.dispose();
    _nextCreditsController.dispose();
    _desiredController.dispose();
    super.dispose();
  }

  double get _selectedCredits => _selected.fold(
        0.0,
        (sum, index) => sum + widget.store.history[index].totalCredits,
      );

  double get _selectedPoints => _selected.fold(
        0.0,
        (sum, index) =>
            sum + widget.store.history[index].totalGradePoints,
      );

  double get _cgpa => _selectedCredits <= 0
      ? 0.0
      : _selectedPoints / _selectedCredits;

  double get _currentCgpa => double.tryParse(_currentController.text) ?? 0.0;
  double get _nextCredits => double.tryParse(_nextCreditsController.text) ?? 0.0;
  double get _desiredCgpa => double.tryParse(_desiredController.text) ?? 0.0;

  double get _requiredGpa {
    if (_nextCredits <= 0) return 0.0;
    final previousCredits = _selectedCredits;
    return (_desiredCgpa * (previousCredits + _nextCredits) -
            _currentCgpa * previousCredits) /
        _nextCredits;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Text(
                    'Cumulative GPA (CGPA)',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _cgpa.toStringAsFixed(2),
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_selected.length} semester(s) • ${_selectedCredits.toStringAsFixed(2)} credits',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select the saved semesters that should be included in the cumulative calculation.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.store.history.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('Save semester results first.'),
              ),
            )
          else
            Card(
              child: Column(
                children: widget.store.history.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  return CheckboxListTile(
                    value: _selected.contains(index),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selected.add(index);
                        } else {
                          _selected.remove(index);
                        }
                      });
                    },
                    title: Text(record.semester),
                    subtitle: Text(
                      '${record.totalCredits.toStringAsFixed(1)} credits • GPA ${record.gpa.toStringAsFixed(2)}',
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target CGPA Planner',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use the selected semester credit total as your previous credit base.',
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _currentController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Current CGPA',
                      prefixIcon: Icon(Icons.assessment_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nextCreditsController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Next semester credits',
                      prefixIcon: Icon(Icons.credit_score_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _desiredController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Desired overall CGPA',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Text(
                      'Required next-semester GPA: ${_requiredGpa.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
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
}
