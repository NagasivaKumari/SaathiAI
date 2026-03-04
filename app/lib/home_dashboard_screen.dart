import 'package:flutter/material.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuArpC6pJ0fZ_EcymBPwEGUfpgDm-bSwPjqSVOG4bZDrWh1fDEDHa89-tOKlqOtNwaH-N2QwS1w8wfKvtESvAw5cbGND10Di_WlpWLcnn30B988YytK9uEmauCwWstb3ZmXHt93Q1oHKi0gvP3Q73U9VAuTg_ibVQo2yE3qJps8w74cs5-TqgkmWiJyaHF_A5wYJen5QZrZ_I12BnrRscFYhzDtQcIxx9LrRoB-iImPCKn5ADwNFJrDJzh-j44rguQ7tO-CuY3iebAk',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'SathiAI',
                style: TextStyle(
                  color: Color(0xFF131711),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Lexend',
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: Color(0xFF131711)),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCe-lJipXIFvbpsnt7IVSJv_pohbh_y-VxmcQKcmTmc-pfgBr8IbY6bfhPXLYFLMTVej4JRjP3D8rdtpCltHJNKLWU7GnfpXK1xCM3u-MU58NuZg2DljTUsRcCB7goEiLqXOr2tzM8QWKVnwT_NAO7fnrYLYmPpKAwFqQU8xYAGjyRn0A1V80moMduJv0Mz8aeTzrq69nIpJ-pwOQy-aycHQ6sd78gXwHU_cTxPSHa9qpDMQh6HXsmNQ-Jt22Sh8YdXXRH0QgLIrzo',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Namaste, Ramesh Ji!',
                          style: TextStyle(
                            color: Color(0xFF131711),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Aapka Sathi aapki madad ke liye taiyar hai.',
                          style: TextStyle(
                            color: Color(0xFF6C8764),
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sab thik chal raha hai?',
                          style: TextStyle(
                            color: Color(0xFF6C8764),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Gamification / Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0x1A4CDF20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0x334CDF20)),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sakhi Learner Level',
                              style: TextStyle(
                                color: Color(0xFF131711),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'Gold Badge',
                              style: TextStyle(
                                color: Color(0xFF4CDF20),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Daily Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Text('750 / 1000 XP', style: TextStyle(color: Color(0xFF4CDF20), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.75,
                        minHeight: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(Color(0xFF4CDF20)),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.trending_up, size: 16, color: Color(0xFF6C8764)),
                        SizedBox(width: 4),
                        Text('250 XP more to reach next level', style: TextStyle(color: Color(0xFF6C8764), fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Quick Access Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'How can I help you today?',
                style: TextStyle(
                  color: Color(0xFF131711),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  fontFamily: 'Lexend',
                ),
              ),
            ),
            // Quick Access Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _QuickAccessCard(
                    icon: Icons.account_balance,
                    color: Colors.blue[100]!,
                    iconColor: Colors.blue[600]!,
                    title: 'Government Schemes',
                    subtitle: 'Find support and subsidies for you',
                  ),
                  SizedBox(height: 12),
                  _QuickAccessCard(
                    icon: Icons.menu_book,
                    color: Colors.orange[100]!,
                    iconColor: Colors.orange[600]!,
                    title: 'Skill Learning',
                    subtitle: 'New techniques for better farming',
                  ),
                  SizedBox(height: 12),
                  _QuickAccessCard(
                    icon: Icons.storefront,
                    color: Colors.green[100]!,
                    iconColor: Colors.green[700]!,
                    title: 'Market Prices',
                    subtitle: 'Check latest Mandi rates',
                  ),
                ],
              ),
            ),
            // Recent Activity Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Recent Updates',
                style: TextStyle(
                  color: Color(0xFF131711),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Lexend',
                ),
              ),
            ),
            // Horizontal Scroll News/Market
            Container(
              height: 120,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _UpdateCard(
                    icon: Icons.eco,
                    iconColor: Color(0xFF4CDF20),
                    title: 'Weather Alert',
                    message: 'Light rain expected in your area tomorrow afternoon.',
                    time: '2 hours ago',
                  ),
                  SizedBox(width: 12),
                  _UpdateCard(
                    icon: Icons.payments,
                    iconColor: Colors.blue,
                    title: 'Scheme Update',
                    message: 'PM-Kisan 15th installment released. Check your status.',
                    time: '5 hours ago',
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
      // Floating Voice Button & Bottom Nav
      bottomNavigationBar: _BottomNavBar(),
      floatingActionButton: _VoiceButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _QuickAccessCard({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Lexend', color: Color(0xFF131711))),
                  SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Color(0xFF6C8764), fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;

  const _UpdateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: iconColor)),
            ],
          ),
          SizedBox(height: 8),
          Text(message, style: TextStyle(fontSize: 16, color: Color(0xFF131711), fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 80,
      child: Stack(
        children: [
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Color(0xFF4CDF20),
            elevation: 8,
            child: Icon(Icons.mic, color: Colors.white, size: 36),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Text('Bol Kar Poochein', style: TextStyle(color: Color(0xFF4CDF20), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, color: Color(0xFF4CDF20)),
                Text('Home', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4CDF20))),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, color: Colors.grey),
                Text('Profile', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
