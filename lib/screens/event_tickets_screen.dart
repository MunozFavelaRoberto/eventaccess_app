import 'package:flutter/material.dart';
import 'package:eventaccess_app/utils/app_routes.dart';

class EventTicketsScreen extends StatefulWidget {
  const EventTicketsScreen({super.key});

  @override
  State<EventTicketsScreen> createState() => _EventTicketsScreenState();
}

class _EventTicketsScreenState extends State<EventTicketsScreen> {
  bool _isLoading = true;
  late Map<String, dynamic> _event;
  List<Map<String, dynamic>> _tickets = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _event = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    // final tickets = await apiService.get('/events/${_event['id']}/tickets');
    await Future.delayed(const Duration(seconds: 1)); // Delay obligatorio
    if (context.mounted) {
      setState(() {
        _tickets = [
          {'id': 1, 'event': _event['name'], 'date': _event['date'], 'time': '20:00', 'type': 'VIP', 'qrCode': 'QR123'},
          {'id': 2, 'event': _event['name'], 'date': _event['date'], 'time': '19:00', 'type': 'Oro', 'qrCode': 'QR456'},
          {'id': 3, 'event': _event['name'], 'date': _event['date'], 'time': '21:00', 'type': 'General', 'qrCode': 'QR789'},
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Boletos - ${_event['name']}'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : ListView.builder(
              itemCount: _tickets.length,
              itemBuilder: (context, index) {
                final ticket = _tickets[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        _event['imageUrl'] as String,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text('${ticket['event']} - ${ticket['type']}'),
                    subtitle: Text('${ticket['date']} ${ticket['time']}'),
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
  }
}