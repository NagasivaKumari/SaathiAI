import 'package:flutter/material.dart';
import '../../core/services/secure_storage_service.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback? onLogout;
  const LogoutButton({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () async {
        await SecureStorageService.clearAll();
        if (onLogout != null) {
          onLogout!();
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
        }
      },
    );
  }
}
