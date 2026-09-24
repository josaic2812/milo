import 'package:flutter/material.dart';

void main() {
  runApp(const MiloApp());
}

class MiloApp extends StatelessWidget {
  const MiloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MILO',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E7DFF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
      ),
      home: const MiloHome(),
    );
  }
}

enum TaskState { open, done }
enum MiloSection { today, inbox, family, more }

class MiloTask {
  MiloTask({
    required this.title,
    required this.person,
    required this.due,
    this.note = '',
    this.state = TaskState.open,
  });

  final String title;
  final String person;
  final String due;
  final String note;
  TaskState state;
}

class MiloHome extends StatefulWidget {
  const MiloHome({super.key});

  @override
  State<MiloHome> createState() => _MiloHomeState();
}

class _MiloHomeState extends State<MiloHome> {
  MiloSection section = MiloSection.today;

  final List<MiloTask> tasks = [
    MiloTask(
      title: 'Einverständniserklärung abgeben',
      person: 'Anna',
      due: 'Heute',
      note: 'Unterschrieben mitnehmen.',
    ),
    MiloTask(
      title: '18 € Wandertag einzahlen',
      person: 'Paul',
      due: 'Heute',
      note: 'Elternverein Volksschule',
    ),
    MiloTask(title: 'Jause vorbereiten', person: 'Anna', due: 'Morgen'),
    MiloTask(title: 'Turnbeutel einpacken', person: 'Paul', due: 'Morgen'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Row(
                  children: [
                    if (wide) _sideNavigation(),
                    Expanded(child: _content()),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 800
          ? _bottomNavigation()
          : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Neu'),
      ),
    );
  }

  Widget _sideNavigation() {
    return Container(
      width: 220,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7EAE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 28),
            child: Text(
              'MILO',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
            ),
          ),
          _navItem(Icons.today_rounded, 'Heute', MiloSection.today),
          _navItem(Icons.inbox_rounded, 'Posteingang', MiloSection.inbox),
          _navItem(Icons.groups_rounded, 'Familie', MiloSection.family),
          _navItem(Icons.more_horiz_rounded, 'Mehr', MiloSection.more),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Alles Wichtige\nan einem Ort.',
              style: TextStyle(fontWeight: FontWeight.w700, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, MiloSection value) {
    final active = section == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        selected: active,
        selectedTileColor: const Color(0xFFEFF3FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Icon(icon),
        title: Text(label),
        onTap: () => setState(() => section = value),
      ),
    );
  }

  Widget _content() {
    switch (section) {
      case MiloSection.today:
        return _today();
      case MiloSection.inbox:
        return _inbox();
      case MiloSection.family:
        return _family();
      case MiloSection.more:
        return _more();
    }
  }

  Widget _page({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 31,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF70766F),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              _avatar('J'),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _today() {
    final open = tasks.where((t) => t.state == TaskState.open).length;
    return _page(
      title: 'Guten Morgen.',
      subtitle: '$open offene Dinge für eure Familie',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _assistantCard(),
          const SizedBox(height: 22),
          const Text(
            'Heute',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...tasks.where((t) => t.due == 'Heute').map(_taskCard),
          const SizedBox(height: 20),
          const Text(
            'Als Nächstes',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...tasks.where((t) => t.due != 'Heute').map(_taskCard),
        ],
      ),
    );
  }

  Widget _assistantCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF4FF), Color(0xFFF1FAF6)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE0E8F5)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 29),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MILO',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Ich habe eure wichtigsten Dinge im Blick. Was soll ich für euch festhalten?',
                  style: TextStyle(fontSize: 14, height: 1.35),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _taskCard(MiloTask task) {
    final done = task.state == TaskState.done;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showTask(task),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE6E9E6)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    task.state = done ? TaskState.open : TaskState.done;
                  }),
                  icon: Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                          color: done ? Colors.grey : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${task.person} · ${task.due}',
                        style: const TextStyle(
                          color: Color(0xFF777D77),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inbox() {
    return _page(
      title: 'Posteingang',
      subtitle: 'Hier landen neue Informationen.',
      child: Column(
        children: [
          _inboxTile(
            Icons.camera_alt_rounded,
            'Foto oder Schulzettel',
            'Später automatisch in Aufgaben und Termine umwandeln.',
          ),
          _inboxTile(
            Icons.edit_note_rounded,
            'Notiz hinzufügen',
            'Einfach etwas für die Familie festhalten.',
          ),
          _inboxTile(
            Icons.calendar_month_rounded,
            'Termin merken',
            'Einen Termin direkt in MILO speichern.',
          ),
        ],
      ),
    );
  }

  Widget _inboxTile(IconData icon, String title, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6E9E6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }

  Widget _family() {
    return _page(
      title: 'Unsere Familie',
      subtitle: 'Alle sehen denselben aktuellen Stand.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _person('Mama', 'M'),
              _person('Josef', 'J'),
              _person('Anna', 'A'),
              _person('Paul', 'P'),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE6E9E6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.task_alt_rounded, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '${tasks.where((t) => t.state == TaskState.open).length} offene Aufgaben',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _person(String name, String letter) {
    return Expanded(
      child: Column(
        children: [
          _avatar(letter),
          const SizedBox(height: 7),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _more() {
    return _page(
      title: 'Mehr',
      subtitle: 'Einstellungen und Familie verwalten.',
      child: Column(
        children: [
          _settingsTile(
            Icons.notifications_none_rounded,
            'Erinnerungen',
            'Später Benachrichtigungen einrichten.',
          ),
          _settingsTile(
            Icons.people_outline_rounded,
            'Familienmitglieder',
            'Mitglieder und Zuständigkeiten.',
          ),
          _settingsTile(
            Icons.lock_outline_rounded,
            'Datenschutz',
            'MILO startet zunächst komplett ohne Cloud-Dienst.',
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6E9E6)),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String letter) {
    return Container(
      width: 43,
      height: 43,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF2FF),
        shape: BoxShape.circle,
      ),
      child: Text(letter, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }

  Widget _bottomNavigation() {
    return NavigationBar(
      selectedIndex: section.index,
      onDestinationSelected: (index) =>
          setState(() => section = MiloSection.values[index]),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.today_outlined),
          selectedIcon: Icon(Icons.today),
          label: 'Heute',
        ),
        NavigationDestination(
          icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox),
          label: 'Posteingang',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'Familie',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz),
          label: 'Mehr',
        ),
      ],
    );
  }

  void _showTask(MiloTask task) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Für ${task.person} · ${task.due}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (task.note.isNotEmpty) ...[
              const SizedBox(height: 15),
              Text(task.note),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() => task.state = TaskState.done);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('Als erledigt markieren'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTask() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neue Aufgabe'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Was ist zu erledigen?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  tasks.insert(
                    0,
                    MiloTask(
                      title: controller.text.trim(),
                      person: 'Familie',
                      due: 'Heute',
                    ),
                  );
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}
