import 'package:flutter/material.dart';
import '../../core/services/support_service.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  late Future<List<dynamic>> _faqFuture;

  @override
  void initState() {
    super.initState();
    _faqFuture = SupportService.fetchFaq();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FAQs')),
      body: FutureBuilder<List<dynamic>>(
        future: _faqFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final faqs = snapshot.data ?? [];
          if (faqs.isEmpty) {
            return Center(child: Text('No FAQs available right now.'));
          }
          return ListView.builder(
            itemCount: faqs.length,
            itemBuilder: (context, idx) {
              final faq = faqs[idx];
              return ExpansionTile(
                title: Text(faq['question'] ?? ''),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(faq['answer'] ?? ''),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
