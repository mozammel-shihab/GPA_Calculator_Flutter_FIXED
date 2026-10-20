import 'package:flutter/material.dart';

import '../services/app_store.dart';
import 'analytics.dart';
import 'calculator.dart';
import 'cgpa.dart';
import 'dashboard.dart';
import 'history.dart';
import 'reports.dart';
import 'settings.dart';

class Shell extends StatefulWidget {
  const Shell({super.key, required this.store});

  final AppStore store;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  List<Widget> get _pages => [
        Dashboard(store: widget.store),
        Calculator(store: widget.store),
        History(store: widget.store),
        Cgpa(store: widget.store),
        Analytics(store: widget.store),
        Reports(store: widget.store),
        SettingsScreen(store: widget.store),
      ];

  static const _labels = [
    'Dashboard',
    'GPA Calculator',
    'GPA History',
    'CGPA Planner',
    'Analytics',
    'Reports',
    'Settings',
  ];

  static const _icons = [
    Icons.dashboard_rounded,
    Icons.calculate_rounded,
    Icons.history_rounded,
    Icons.school_rounded,
    Icons.insights_rounded,
    Icons.picture_as_pdf_rounded,
    Icons.settings_rounded,
  ];

  void _select(int value) => setState(() => _index = value);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 950;
        final pages = _pages;

        return Scaffold(
          appBar: AppBar(
            title: Text(_labels[_index]),
            actions: [
              if (constraints.maxWidth >= 600)
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Center(
                    child: Text(
                      widget.store.studentName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
          drawer: wide
              ? null
              : Drawer(
                  child: SafeArea(
                    child: Column(
                      children: [
                        UserAccountsDrawerHeader(
                          accountName: Text(widget.store.studentName),
                          accountEmail: Text(
                            widget.store.studentId.isEmpty
                                ? 'GPA Calculator Pro'
                                : widget.store.studentId,
                          ),
                          currentAccountPicture: const CircleAvatar(
                            child: Icon(Icons.school_rounded),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _labels.length,
                            itemBuilder: (context, i) => ListTile(
                              selected: _index == i,
                              leading: Icon(_icons[i]),
                              title: Text(_labels[i]),
                              onTap: () {
                                Navigator.pop(context);
                                _select(i);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          body: Row(
            children: [
              if (wide)
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (var i = 0; i < _labels.length; i++)
                      NavigationRailDestination(
                        icon: Icon(_icons[i]),
                        label: Text(_labels[i]),
                      ),
                  ],
                ),
              Expanded(child: pages[_index]),
            ],
          ),
        );
      },
    );
  }
}
