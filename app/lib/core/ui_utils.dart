import 'package:flutter/material.dart';

IconData getIconData(String? iconName) {
  switch (iconName) {
    case 'emoji_events':
      return Icons.emoji_events;
    case 'star':
      return Icons.star;
    case 'mic':
      return Icons.mic;
    case 'school':
      return Icons.school;
    case 'account_balance':
      return Icons.account_balance;
    case 'shopping_basket':
      return Icons.shopping_basket;
    case 'agriculture':
      return Icons.agriculture;
    case 'home':
      return Icons.home;
    case 'grass':
      return Icons.grass;
    case 'person':
      return Icons.person;
    case 'check_circle':
      return Icons.check_circle;
    case 'trending_up':
      return Icons.trending_up;
    case 'warning':
      return Icons.warning;
    case 'notifications':
      return Icons.notifications;
    case 'sync':
      return Icons.sync;
    default:
      return Icons.help_outline;
  }
}
