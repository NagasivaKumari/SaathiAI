import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/config.dart';
import '../services/api_client.dart';

class SkillCertificateScreen extends StatefulWidget {
  final String email;
  final String skillName;
  const SkillCertificateScreen({
    super.key,
    required this.email,
    required this.skillName,
  });

  @override
  State<SkillCertificateScreen> createState() => _SkillCertificateScreenState();
}

class _SkillCertificateScreenState extends State<SkillCertificateScreen> {
  bool _loading = false;
  String? _certificateUrl;
  String? _error;

  Future<void> _fetchCertificate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = await ApiClient(
        baseUrl: AppConfig.BASE_URL,
      ).getSkillCertificate(widget.email, widget.skillName);
      setState(() {
        _certificateUrl = url;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Certificate')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _fetchCertificate,
              child: Text(_loading ? 'Fetching...' : 'Get Certificate'),
            ),
            if (_certificateUrl != null) ...[
              const SizedBox(height: 24),
              Text('Certificate ready!'),
              ElevatedButton(
                onPressed: () => launchUrl(Uri.parse(_certificateUrl!)),
                child: const Text('Download/View PDF'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 24),
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
