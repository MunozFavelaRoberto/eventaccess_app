import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:eventaccess_app/models/event.dart';
import 'package:eventaccess_app/services/data_provider.dart';
import 'package:eventaccess_app/utils/app_routes.dart';

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
                        child: Icon(Icons.event, color: Colors.white, size: 40),
                      ),
                      title: Text(event.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${event.date} - ${event.placeName}', style: const TextStyle(color: Colors.white)),
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