import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:eventaccess_app/models/ticket.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key});

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



  @override
  Widget build(BuildContext context) {
    final ticket = ModalRoute.of(context)!.settings.arguments as Ticket;
    final theme = Theme.of(context);

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
                  const SnackBar(content: Text('PDF del boleto')),
                );
              },
              tooltip: 'Descargar PDF',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ticket Card
            Card(
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Event Name centered
                    Text(
                      ticket.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Date left, Time right (start - end without AM/PM)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(
                                'Fecha:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 140,
                              child: Text(
                                'Horario:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(
                                _formatDate(ticket.date),
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 140,
                              child: Text(
                                '${ticket.startTime.substring(0, 5)} - ${ticket.endTime.substring(0, 5)}',
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Ticket Code centered
                    _buildLabeledText('Código de boleto:', ticket.ticketCode, textAlign: TextAlign.center, valueStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    const SizedBox(height: 24),

                    // QR Code centered in middle
                    Center(
                        child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark ? Colors.white : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Código QR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            ticket.qrB64.isNotEmpty && ticket.qrB64.contains(',')
                                ? Image.memory(
                                    Uint8List.fromList(base64Decode(ticket.qrB64.split(',')[1])),
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.contain,
                                  )
                                : const SizedBox(
                                    width: 200.0,
                                    height: 200.0,
                                    child: Center(child: Text('QR no disponible')),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Place centered to the left
                    _buildLabeledText('Lugar:', ticket.placeName, alignment: Alignment.centerLeft),
                    const SizedBox(height: 8),

                    // Address centered to the left
                    _buildLabeledText('Dirección:', ticket.address, alignment: Alignment.centerLeft),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledText(String label, String value, {TextAlign textAlign = TextAlign.left, AlignmentGeometry? alignment, TextStyle? valueStyle}) {
    Widget textWidget = Column(
      crossAxisAlignment: textAlign == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: textAlign,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueStyle ?? const TextStyle(
            fontSize: 16,
          ),
          textAlign: textAlign,
        ),
      ],
    );

    if (alignment != null) {
      return Align(
        alignment: alignment,
        child: textWidget,
      );
    }
    return textWidget;
  }
}