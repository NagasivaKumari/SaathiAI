import 'package:flutter/material.dart';
import '../../core/services/support_service.dart';

class ReportProblemScreen extends StatefulWidget {
  @override
  _ReportProblemScreenState createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _descController = TextEditingController();
  final _typeController = TextEditingController(text: 'Bug'); // Default value
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_descController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await SupportService.reportProblem(
        _typeController.text.trim(),
        _descController.text.trim(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Problem reported successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report a Problem')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _typeController.text,
              items: ['Bug', 'Feature Request', 'Other'].map((String val) {
                return DropdownMenuItem(value: val, child: Text(val));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _typeController.text = val);
              },
              decoration: InputDecoration(labelText: 'Issue Type'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Describe your problem'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}
