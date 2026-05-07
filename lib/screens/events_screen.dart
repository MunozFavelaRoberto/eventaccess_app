import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:eventaccess_app/models/event.dart';
import 'package:eventaccess_app/services/data_provider.dart';
import 'package:eventaccess_app/utils/app_routes.dart';

String _formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  } catch (e) {
    return dateStr; // fallback
  }
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    // Los eventos se cargan automáticamente por DataProvider
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final events = dataProvider.events;
    final isLoading = dataProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : RefreshIndicator(
              onRefresh: () => context.read<DataProvider>().refreshAllData(),
              color: Colors.green,
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.grey.shade700,
                    child: ListTile(
                      leading: const SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(Icons.local_activity, color: Colors.white, size: 40),
                      ),
                      title: Text(event.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(_formatDate(event.date), style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text('${event.startTime.substring(0, 5)} - ${event.endTime.substring(0, 5)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(event.placeName, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
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
            ),
    );
  }
}