import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguage;
  bool _voiceEnabled = false;
  final List<String> _languages = ['Hindi', 'Telugu', 'Marathi', 'English'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Language'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose your language:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._languages.map((lang) => RadioListTile<String>(
                  title: Text(lang),
                  value: lang,
                  groupValue: _selectedLanguage,
                  onChanged: (val) => setState(() => _selectedLanguage = val),
                )),
            const SizedBox(height: 24),
            CheckboxListTile(
              value: _voiceEnabled,
              onChanged: (val) => setState(() => _voiceEnabled = val ?? false),
              title: const Text('Enable Voice Assistance'),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _selectedLanguage == null
                  ? null
                  : () {
                      // Save preferences here
                      Navigator.pushReplacementNamed(context, '/location');
                    },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
