import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLang;
  final List<String> supportedLangs;
  final void Function(String) onChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLang,
    required this.supportedLangs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedLang,
      items: supportedLangs
          .map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(_langLabel(lang)),
              ))
          .toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }

  String _langLabel(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी';
      case 'te':
        return 'తెలుగు';
      default:
        return code;
    }
  }
}
