import 'package:flutter/material.dart';

class CommunityPostComments1Screen extends StatelessWidget {
  const CommunityPostComments1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final comments = [
      {'user': 'Amit', 'comment': 'Great post!'},
      {'user': 'Priya', 'comment': 'Very helpful, thanks!'},
      {'user': 'Ravi', 'comment': 'How do I apply for this scheme?'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Community Post Comments')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: comments.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, idx) {
          final c = comments[idx];
          return ListTile(
            leading: CircleAvatar(child: Text(c['user']![0])),
            title: Text(c['user'] ?? ''),
            subtitle: Text(c['comment'] ?? ''),
          );
        },
      ),
    );
  }
}
