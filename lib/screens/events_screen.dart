import 'package:flutter/material.dart';
import 'package:eventaccess_app/utils/app_routes.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    // final events = await apiService.get('/events');
    await Future.delayed(const Duration(seconds: 1)); // Delay obligatorio
    setState(() {
      _events = [
        {'id': 1, 'name': 'Concierto Rock', 'date': '2026-05-01', 'location': 'Estadio Central', 'imageUrl': 'assets/images/img1.jpeg'},
        {'id': 2, 'name': 'Festival Jazz', 'date': '2026-06-15', 'location': 'Parque Urbano', 'imageUrl': 'assets/images/img1.jpeg'},
        {'id': 3, 'name': 'Teatro Musical', 'date': '2026-07-20', 'location': 'Teatro Nacional', 'imageUrl': 'assets/images/img1.jpeg'},
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis eventos'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        event['imageUrl'] as String,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(event['name'] as String),
                    subtitle: Text('${event['date']} - ${event['location']}'),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.eventTickets,
                        arguments: event,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}