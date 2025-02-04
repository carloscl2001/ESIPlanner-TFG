import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/overlap_class_provider.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final overlappingEvents = Provider.of<OverlapClassProvider>(context).overlappingEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Solapados'),
        backgroundColor: Colors.indigo,
      ),
      body: overlappingEvents.isEmpty
          ? const Center(
              child: Text(
                'No hay eventos solapados.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: overlappingEvents.length,
              itemBuilder: (context, index) {
                final event = overlappingEvents[index];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(event['subjectName'] ?? 'Sin asignatura'),
                    subtitle: Text(
                      'Fecha: ${event['event']['date']}\n'
                      'Hora: ${event['event']['start_hour']} - ${event['event']['end_hour']}',
                    ),
                    leading: const Icon(Icons.warning, color: Colors.red),
                  ),
                );
              },
            ),
    );
  }
}
