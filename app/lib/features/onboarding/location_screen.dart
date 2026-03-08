import 'package:flutter/material.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? _state;
  String? _district;
  String? _village;
  bool _locationAllowed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Location'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: _locationAllowed,
              onChanged: (val) => setState(() => _locationAllowed = val),
              title: const Text('Allow location access'),
            ),
            if (!_locationAllowed) ...[
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'State'),
                onChanged: (val) => setState(() => _state = val),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'District'),
                onChanged: (val) => setState(() => _district = val),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Village'),
                onChanged: (val) => setState(() => _village = val),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _locationAllowed || (_state != null && _district != null && _village != null)
                  ? () {
                      // Save location here
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
