import 'package:flutter/material.dart';
import 'package:eventaccess_app/widgets/app_drawer.dart';
import 'package:eventaccess_app/screens/events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const Center(
          child: Text('Bienvenido'),
        );
      case 1:
        return const EventsScreen();
      default:
        return const Center(
          child: Text('Bienvenido'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: const Text('Event Access'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton.outlined(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            tooltip: 'Menú',
          ),
        ],
      ),
       endDrawer: const AppDrawer(),
       body: _buildBody(_selectedIndex),
       bottomNavigationBar: NavigationBar(
         selectedIndex: _selectedIndex,
         onDestinationSelected: _onDestinationSelected,
         destinations: const [
           NavigationDestination(
             icon: Icon(Icons.home_outlined),
             selectedIcon: Icon(Icons.home),
             label: 'Inicio',
           ),
           NavigationDestination(
             icon: Icon(Icons.event_outlined),
             selectedIcon: Icon(Icons.event),
             label: 'Eventos',
           ),
         ],
       ),
    );
  }
}
