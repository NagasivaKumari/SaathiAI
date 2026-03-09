import 'package:flutter/material.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/config.dart';
import '../../services/api_client.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SecureStorageService.getUserProfile(),
      builder: (context, snapshot) {
        final user = snapshot.data != null ? _parseUser(snapshot.data!) : null;
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8F6),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Account Details',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.green),
                tooltip: 'Refresh Profile',
                onPressed: () async {
                  try {
                    await ProfileService.fetchProfile();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/settings');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'PERSONAL INFO',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        Icons.person,
                        'Full Name',
                        user?['name'] ?? '-',
                      ),
                      _buildDivider(),
                      _buildInfoTile(
                        Icons.email,
                        'Email Address',
                        user?['email'] ?? '-',
                      ),
                      _buildDivider(),
                      _buildInfoTile(
                        Icons.phone,
                        'Phone Number',
                        user?['phone'] ?? '-',
                      ),
                      _buildDivider(),
                      _buildInfoTile(
                        Icons.account_circle,
                        'Username',
                        user?['username'] ?? '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'ACHIEVEMENTS',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        Icons.emoji_events,
                        'Points Earned',
                        user?['points']?.toString() ?? '-',
                      ),
                      _buildDivider(),
                      _buildInfoTile(
                        Icons.star,
                        'Current Level',
                        user?['level']?.toString() ?? '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'APP SETTINGS',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: true,
                        activeColor: Colors.green,
                        onChanged: (v) {},
                        title: const Text(
                          'Voice Assistance',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _buildDivider(),
                      SwitchListTile(
                        value: true,
                        activeColor: Colors.green,
                        onChanged: (v) {},
                        title: const Text(
                          'Push Notifications',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _buildDivider(),
                      ListTile(
                        leading: const Icon(Icons.sync, color: Colors.green),
                        title: const Text(
                          'Offline Sync',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black38,
                        ),
                        onTap: () {},
                      ),
                      _buildDivider(),
                      ListTile(
                        leading: const Icon(
                          Icons.privacy_tip,
                          color: Colors.green,
                        ),
                        title: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black38,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () async {
                          await SecureStorageService.clearAll();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/splash',
                            (route) => false,
                          );
                        },
                      ),
                      _buildDivider(),
                      ListTile(
                        leading: const Icon(
                          Icons.phonelink_erase,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Logout All Devices',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () async {
                          try {
                            final client = ApiClient(
                              baseUrl: AppConfig.BASE_URL,
                            );
                            await client.logoutAll();
                            await SecureStorageService.clearAll();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/splash',
                              (route) => false,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to logout from all devices',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      endIndent: 16,
      color: Color(0xFFEEEEEE),
    );
  }

  Map<String, dynamic>? _parseUser(String userStr) {
    try {
      if (userStr.startsWith('{') && userStr.endsWith('}')) {
        return _parseMap(userStr);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _parseMap(String str) {
    // Very basic parser for Map<String, dynamic> from toString()
    final map = <String, dynamic>{};
    final entries = str.substring(1, str.length - 1).split(', ');
    for (final entry in entries) {
      final idx = entry.indexOf(':');
      if (idx > 0) {
        final key = entry.substring(0, idx).trim();
        final value = entry.substring(idx + 1).trim();
        map[key] = value;
      }
    }
    return map;
  }
}
