import 'package:flutter/material.dart';
import 'package:general_pos/screens/records/records.dart';
import 'package:general_pos/theme.dart';
import 'history/history_page.dart';
import 'home/home_page.dart';
import 'settings/settings_page.dart';

class Destination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget page;

  const Destination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.page,
  });
}

class MainPage extends StatefulWidget {
  final int pageIndex;
  const MainPage({super.key, this.pageIndex = 0});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Destination> destinations = [
    const Destination(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home', page: HomePage()),
    const Destination(icon: Icons.history_outlined, selectedIcon: Icons.history_sharp, label: 'History', page: HistoryPage()),
    const Destination(icon: Icons.checklist_outlined, selectedIcon: Icons.checklist_sharp, label: 'Records', page: RecordPage()),
    const Destination(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings', page: SettingsPage()),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.pageIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: destinations[currentIndex].page,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        selectedIndex: currentIndex,
        destinations: destinations.map((destination) {
          return NavigationDestination(
            selectedIcon: Icon(destination.selectedIcon),
            icon: Icon(destination.icon),
            label: destination.label,
          );
        }).toList(),
      ),
    );
  }
}
