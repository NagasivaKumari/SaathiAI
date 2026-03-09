import 'package:flutter/material.dart';
import '../../core/services/legal_service.dart';

class DeleteAccountScreen extends StatefulWidget {
  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isLoading = false;

  Future<void> _delete() async {
    setState(() => _isLoading = true);
    try {
      await LegalService.deleteAccount();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Account deleted.')));
      Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _delete,
                    child: Text('Delete Account'),
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                  ),
          ],
        ),
      ),
    );
  }
}
