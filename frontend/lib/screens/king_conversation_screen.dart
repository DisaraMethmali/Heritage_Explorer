// frontend/lib/screens/king_conversation_screen.dart
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class KingConversationScreen extends StatelessWidget {
  const KingConversationScreen({super.key});

  // Hardcoded conversation about the Temple of the Tooth Relic
  final List<Map<String, String>> _conversation = const [
    {
      'speaker': 'King',
      'text': 'Welcome, traveler. What knowledge do you seek today?'
    },
    {
      'speaker': 'User',
      'text': 'Your Majesty, tell me about the Temple of the Tooth Relic.'
    },
    {
      'speaker': 'King',
      'text':
          'Ah, the Temple of the Tooth Relic in Kandy houses the sacred tooth of Lord Buddha. '
              'It is one of our most revered Buddhist sites and a symbol of sovereignty.'
    },
    {
      'speaker': 'User',
      'text':
          'How old is the temple, and why is it so important?'
    },
    {
      'speaker': 'King',
      'text':
          'The temple dates back to the 4th century in Anuradhapura, though the current structure is from the 18th century. '
              'It plays a central role in religious ceremonies and the annual Esala Perahera festival.'
    },
    {
      'speaker': 'User',
      'text': 'Can visitors see the relic?'
    },
    {
      'speaker': 'King',
      'text':
          'Yes, the relic is displayed during special ceremonies. Visitors can also explore the temple complex, '
              'which includes shrines, museums, and beautiful architecture.'
    },
    {
      'speaker': 'User',
      'text': 'Thank you, Your Majesty, for sharing this wisdom.'
    },
    {
      'speaker': 'King',
      'text':
          'May this knowledge guide you. Remember, history is the treasure of our people.'
    },
  ];

  Future<void> _exportPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Conversation with the King',
                  style:
                      pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              ..._conversation.map(
                (msg) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text('${msg['speaker']}: ${msg['text']}',
                      style: pw.TextStyle(fontSize: 16)),
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/king_conversation.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation with the King'),
        backgroundColor: const Color(0xFF004C7A),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () => _exportPdf(context),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversation.length,
        itemBuilder: (context, index) {
          final msg = _conversation[index];
          final isUser = msg['speaker'] == 'User';
          return Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue.shade100 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${msg['speaker']}: ${msg['text']}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isUser ? Colors.black : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
