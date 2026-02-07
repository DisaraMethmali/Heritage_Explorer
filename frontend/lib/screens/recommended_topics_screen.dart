import 'package:flutter/material.dart';

class RecommendedTopicsScreen extends StatefulWidget {
  final List<String>? recommendedTopics;

  const RecommendedTopicsScreen({super.key, this.recommendedTopics});

  @override
  State<RecommendedTopicsScreen> createState() =>
      _RecommendedTopicsScreenState();
}

class _RecommendedTopicsScreenState extends State<RecommendedTopicsScreen> {
  List<String> _selectedTopics = [];

  @override
  void initState() {
    super.initState();
    _selectedTopics = [];
  }

  @override
  Widget build(BuildContext context) {
    final topics = widget.recommendedTopics ??
        ['King', 'Temple', 'Festival', 'Kingdom', 'Buddhism'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Topics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Select your recommended topics:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topics.map((topic) {
                  final isSelected = _selectedTopics.contains(topic);
                  return FilterChip(
                    label: Text(topic),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTopics.add(topic);
                        } else {
                          _selectedTopics.remove(topic);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Selected topics: ${_selectedTopics.join(', ')}')),
              );
            },
            child: const Text('Save Selection'),
          ),
        ],
      ),
    );
  }
}
