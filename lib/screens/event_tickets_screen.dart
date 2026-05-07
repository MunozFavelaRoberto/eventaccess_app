import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventaccess_app/models/event.dart';
import 'package:eventaccess_app/models/ticket.dart';
import 'package:eventaccess_app/services/data_provider.dart';
import 'package:eventaccess_app/utils/app_routes.dart';

class EventTicketsScreen extends StatefulWidget {
  const EventTicketsScreen({super.key});

  @override
  State<EventTicketsScreen> createState() => _EventTicketsScreenState();
}

class _EventTicketsScreenState extends State<EventTicketsScreen> {
  late Event _event;
  List<Ticket> _tickets = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _event = ModalRoute.of(context)!.settings.arguments as Event;
    _loadTickets();
  }

  void _loadTickets() {
    final dataProvider = context.read<DataProvider>();
    _tickets = dataProvider.getTicketsForEvent(_event.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boletos - ${_event.name}'),
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          final isLoading = dataProvider.isLoading;
          return isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : RefreshIndicator(
                  onRefresh: () => dataProvider.refreshAllData(),
                  color: Colors.green,
                  child: ListView.builder(
                    itemCount: _tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = _tickets[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        color: Colors.grey.shade700,
                        child: ListTile(
                          leading: const SizedBox(
                            width: 60,
                            height: 60,
                            child: Icon(Icons.confirmation_number, color: Colors.white, size: 40),
                          ),
                          title: Text('${ticket.name} - ${ticket.ticketCode}', style: const TextStyle(color: Colors.white)),
                          subtitle: Text('${ticket.date} ${ticket.startTime}', style: const TextStyle(color: Colors.white)),
                          onTap: () async {
                            // Mostrar loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Center(
                                  child: CircularProgressIndicator(color: Colors.green),
                                );
                              },
                            );
                            // Delay obligatorio
                            await Future.delayed(const Duration(seconds: 1));
                            if (context.mounted) {
                              Navigator.of(context).pop(); // Cerrar loading
                              Navigator.pushNamed(
                                context,
                                AppRoutes.ticketDetail,
                                arguments: ticket,
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}