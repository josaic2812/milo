import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tasks_screen.dart';
import 'calendar_screen.dart';
import 'family_screen.dart';

class MiloShell extends StatefulWidget {
  const MiloShell({super.key});
  @override State<MiloShell> createState() => _MiloShellState();
}

class _MiloShellState extends State<MiloShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const TasksScreen(),
      const CalendarScreen(),
      const FamilyScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(CupertinoIcons.house), label: 'Heute'),
          NavigationDestination(icon: Icon(CupertinoIcons.checkmark_square), label: 'Aufgaben'),
          NavigationDestination(icon: Icon(CupertinoIcons.calendar), label: 'Kalender'),
          NavigationDestination(icon: Icon(CupertinoIcons.person_2), label: 'Familie'),
        ],
      ),
    );
  }
}
