import 'package:flutter/material.dart';

class CommunityPostComments2Screen extends StatelessWidget {
  const CommunityPostComments2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final comments = [
      {'user': 'Sunita', 'comment': 'Congratulations!'},
      {'user': 'Vikas', 'comment': 'How did you achieve this?'},
      {'user': 'Meena', 'comment': 'Share more tips please.'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Community Post Comments 2')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: comments.length,
        separatorBuilder: (_, __) => const Divider(),
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
