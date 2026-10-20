import 'package:flutter/material.dart';

import '../models/semester.dart';
import '../services/app_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _id = TextEditingController();
  final _university = TextEditingController();
  final List<String> _grades = defaultScale.keys.toList();
  late final Map<String, TextEditingController> _scaleControllers;

  @override
  void initState() {
    super.initState();
    _name.text = widget.store.studentName;
    _id.text = widget.store.studentId;
    _university.text = widget.store.university;
    _scaleControllers = {
      for (final grade in _grades)
        grade: TextEditingController(
          text: (widget.store.scale[grade] ?? defaultScale[grade] ?? 0)
              .toStringAsFixed(2),
        ),
    };
  }

  @override
  void dispose() {
    _name.dispose();
    _id.dispose();
    _university.dispose();
    for (final controller in _scaleControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.store.updateProfile(_name.text, _id.text, _university.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved.')),
    );
  }

  Future<void> _saveScale() async {
    final result = <String, double>{};
    for (final grade in _grades) {
      final value = double.tryParse(_scaleControllers[grade]!.text);
      if (value == null || value < 0 || value > 4.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid value for $grade. Use 0–4.')),
        );
        return;
      }
      result[grade] = value;
    }
    await widget.store.setScale(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grading scale saved.')),
    );
  }

  Future<void> _resetScale() async {
    await widget.store.resetScale();
    for (final grade in _grades) {
      _scaleControllers[grade]!.text =
          (defaultScale[grade] ?? 0).toStringAsFixed(2);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default grading scale restored.')),
    );
  }

  Future<void> _clearHistory() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear GPA history?'),
        content: const Text('All saved semester results will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true) await widget.store.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Card(
          child: SwitchListTile.adaptive(
            value: widget.store.darkMode,
            onChanged: (_) => widget.store.toggleDark(),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark appearance.'),
            secondary: const Icon(Icons.dark_mode_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Profile',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Student Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter student name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _id,
                    decoration: const InputDecoration(
                      labelText: 'Student ID',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _university,
                    decoration: const InputDecoration(
                      labelText: 'University',
                      prefixIcon: Icon(Icons.account_balance_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save Profile'),
                  ),
                ],
              ),
            ),
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
                  'University Grading Scale',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text('Customize grade points from 0.00 to 4.00.'),
                const SizedBox(height: 14),
                ..._grades.map(
                  (grade) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      controller: _scaleControllers[grade],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: '$grade Grade Point',
                        prefixIcon: const Icon(Icons.grade_outlined),
                      ),
                    ),
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _saveScale,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Scale'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _resetScale,
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('Reset Default'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: const Text('Local Data Storage'),
                subtitle: Text(
                  '${widget.store.history.length} semester result(s) saved on this device.',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined),
                title: const Text('Clear GPA History'),
                onTap: widget.store.history.isEmpty ? null : _clearHistory,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: widget.store.logout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Log Out'),
        ),
      ],
    );
  }
}
