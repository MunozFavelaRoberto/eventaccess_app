import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ticket = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del boleto'),
        actions: [
          Container(
            margin: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () {
              // Generar y descargar PDF del boleto
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF del boleto generado')),
              );
            },
              tooltip: 'Descargar PDF',
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(ticket['event'], style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(ticket['date'], style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(ticket['time'], style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(ticket['type'], style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            QrImageView(
              data: ticket['qrCode'],
              size: 200.0,
            ),
          ],
        ),
      ),
    );
  }
}