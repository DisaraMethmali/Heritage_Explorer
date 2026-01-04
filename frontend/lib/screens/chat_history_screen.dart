import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<Map<String, dynamic>>? _history;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));

    // Hardcoded chat history
    final hardcodedHistory = [
      {
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'query': 'Tell me about the first king of Sri Lanka.',
        'answer': 'The first king of Sri Lanka was Vijaya.',
        'topic': 'King',
        'intent': 'person',
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
        'query': 'What are the main festivals in Kandy?',
        'answer': 'The main festival in Kandy is the Esala Perahera.',
        'topic': 'Festival',
        'intent': 'description',
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'query': 'Show me famous temples in Sri Lanka.',
        'answer': 'Some famous temples include Temple of the Tooth, Ruwanwelisaya, and Jetavanaramaya.',
        'topic': 'Temple',
        'intent': 'place',
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(days: 3, hours: 4)).toIso8601String(),
        'query': 'Hello, how are you?',
        'answer': 'Hello! I am here to help you with Sri Lankan history.',
        'topic': 'Greeting',
        'intent': 'greeting',
      },
      {
        'timestamp': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'query': 'What is Buddhism?',
        'answer': 'Buddhism is a religion and philosophy based on the teachings of Siddhartha Gautama.',
        'topic': 'Buddhism',
        'intent': 'description',
      },
    ];

    setState(() {
      _history = hardcodedHistory;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history == null || _history!.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No chat history yet'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history!.length,
                    itemBuilder: (context, index) {
                      final message = _history![index];
                      final timestamp = DateTime.parse(message['timestamp']);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: Icon(
                            _getIntentIcon(message['intent']),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            message['query'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(message['answer']),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(message['topic']),
                                        avatar: const Icon(Icons.label, size: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text(message['intent']),
                                        avatar: const Icon(Icons.category, size: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _getIntentIcon(String intent) {
    switch (intent) {
      case 'greeting':
        return Icons.waving_hand;
      case 'person':
        return Icons.person;
      case 'place':
        return Icons.place;
      case 'description':
        return Icons.description;
      default:
        return Icons.chat;
    }
  }
}
