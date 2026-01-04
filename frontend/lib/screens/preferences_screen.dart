import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  Map<String, dynamic> _preferences = {
    "notifications": true,
    "theme": "light",
    "favorite_topics": ["King", "Temple"]
  };

  bool _isSaving = false;

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    // Simulate saving delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _savePreferences,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Receive notifications'),
                  value: _preferences['notifications'] ?? true,
                  onChanged: (value) {
                    setState(() {
                      _preferences['notifications'] = value;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(_preferences['theme'] ?? 'light'),
                  trailing: DropdownButton<String>(
                    value: _preferences['theme'] ?? 'light',
                    items: const [
                      DropdownMenuItem(
                        value: 'light',
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: 'dark',
                        child: Text('Dark'),
                      ),
                      DropdownMenuItem(
                        value: 'system',
                        child: Text('System'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _preferences['theme'] = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Favorite Topics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'King',
                  'Temple',
                  'Festival',
                  'Kingdom',
                  'Buddhism'
                ].map((topic) {
                  final favorites =
                      List<String>.from(_preferences['favorite_topics'] ?? []);
                  final isSelected = favorites.contains(topic);

                  return FilterChip(
                    label: Text(topic),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          favorites.add(topic);
                        } else {
                          favorites.remove(topic);
                        }
                        _preferences['favorite_topics'] = favorites;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
