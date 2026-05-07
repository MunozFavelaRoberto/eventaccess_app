import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventaccess_app/models/event.dart';
import 'package:eventaccess_app/models/ticket.dart';
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
                          title: Text(ticket.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.event, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(_formatDate(ticket.date), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text('${ticket.startTime.substring(0, 5)} - ${ticket.endTime.substring(0, 5)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.confirmation_number, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(ticket.ticketCode, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
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