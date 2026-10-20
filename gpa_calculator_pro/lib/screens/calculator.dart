import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/semester.dart';
import '../services/app_store.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key, required this.store});

  final AppStore store;

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  final _formKey = GlobalKey<FormState>();
  final _semesterController = TextEditingController(text: 'Semester 1');
  final List<Course> _courses = [Course()];
  final Map<Course, TextEditingController> _creditControllers = {};

  double _gradePoint(Course course) => widget.store.scale[course.grade] ?? 0.0;

  double get _credits => _courses.fold(0.0, (sum, item) => sum + item.credit);

  double get _points => _courses.fold(
        0.0,
        (sum, item) => sum + item.credit * _gradePoint(item),
      );

  double get _gpa => _credits <= 0 ? 0.0 : _points / _credits;

  @override
  void dispose() {
    _semesterController.dispose();
    for (final controller in _creditControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _creditControllerFor(Course course) {
    return _creditControllers.putIfAbsent(
      course,
      () => TextEditingController(text: course.credit.toString()),
    );
  }

  void _addCourse() {
    setState(() => _courses.add(Course()));
  }

  void _removeCourse(int index) {
    final course = _courses[index];
    final controller = _creditControllers.remove(course);
    controller?.dispose();
    setState(() => _courses.removeAt(index));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _semesterController.text.trim();
    final record = SemesterRecord(
      semester: name.isEmpty ? 'Semester' : name,
      date: DateTime.now(),
      courses: _courses
          .map(
            (course) => Course(
              name: course.name.trim(),
              code: course.code.trim(),
              credit: course.credit,
              grade: course.grade,
            ),
          )
          .toList(),
      scale: Map<String, double>.from(widget.store.scale),
    );

    await widget.store.addRecord(record);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semester result saved successfully.')),
    );
  }

  void _reset() {
    for (final controller in _creditControllers.values) {
      controller.dispose();
    }
    _creditControllers.clear();
    setState(() {
      _courses
        ..clear()
        ..add(Course());
      _semesterController.text = 'Semester 1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        controller: _semesterController,
                        decoration: const InputDecoration(
                          labelText: 'Semester / Term',
                          prefixIcon: Icon(Icons.calendar_month_rounded),
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _addCourse,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Course'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ..._courses.asMap().entries.map(
              (entry) => _courseCard(context, entry.key, entry.value),
            ),
            const SizedBox(height: 8),
            _summaryCard(context),
          ],
        ),
      ),
    );
  }

  Widget _courseCard(BuildContext context, int index, Course course) {
    final creditController = _creditControllerFor(course);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Course ${index + 1}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_courses.length > 1)
                  IconButton(
                    tooltip: 'Remove course',
                    onPressed: () => _removeCourse(index),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 650;
                final nameField = TextFormField(
                  initialValue: course.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  onChanged: (value) => course.name = value,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter course name'
                      : null,
                );
                final codeField = TextFormField(
                  initialValue: course.code,
                  decoration: const InputDecoration(
                    labelText: 'Course Code',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  onChanged: (value) => course.code = value,
                );
                final creditField = TextFormField(
                  controller: creditController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Credit Hour',
                    prefixIcon: Icon(Icons.schedule_rounded),
                  ),
                  onChanged: (value) {
                    course.credit = double.tryParse(value) ?? 0.0;
                    setState(() {});
                  },
                  validator: (value) {
                    final credit = double.tryParse(value ?? '');
                    if (credit == null || credit <= 0 || credit > 20) {
                      return 'Use 0–20';
                    }
                    return null;
                  },
                );
                final gradeField = DropdownButtonFormField<String>(
                  initialValue: widget.store.scale.containsKey(course.grade)
                      ? course.grade
                      : widget.store.scale.keys.first,
                  decoration: const InputDecoration(
                    labelText: 'Letter Grade',
                    prefixIcon: Icon(Icons.grade_outlined),
                  ),
                  items: widget.store.scale.entries
                      .map(
                        (entry) => DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(
                            '${entry.key} (${entry.value.toStringAsFixed(2)})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => course.grade = value);
                  },
                );
                final points = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Grade Point'),
                    const SizedBox(height: 6),
                    Text(
                      _gradePoint(course).toStringAsFixed(2),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                );

                if (narrow) {
                  return Column(
                    children: [
                      nameField,
                      const SizedBox(height: 10),
                      codeField,
                      const SizedBox(height: 10),
                      creditField,
                      const SizedBox(height: 10),
                      gradeField,
                      const SizedBox(height: 12),
                      Align(alignment: Alignment.centerLeft, child: points),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: nameField),
                    const SizedBox(width: 10),
                    Expanded(flex: 2, child: codeField),
                    const SizedBox(width: 10),
                    SizedBox(width: 150, child: creditField),
                    const SizedBox(width: 10),
                    Expanded(flex: 2, child: gradeField),
                    const SizedBox(width: 20),
                    SizedBox(width: 95, child: points),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _summaryRow('Total Credit Hours', _credits.toStringAsFixed(2)),
            _summaryRow('Total Grade Points', _points.toStringAsFixed(2)),
            const Divider(height: 24),
            _summaryRow('FINAL GPA', _gpa.toStringAsFixed(2), big: true),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save Semester Result'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: big ? 18 : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: big ? 28 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
