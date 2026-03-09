import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/providers/language_provider.dart';
import 'features/home/village_dashboard_screen.dart';
import 'features/schemes/schemes_screen.dart';
import 'features/market/market_screen.dart';
import 'features/skills/skills_screen.dart';
import 'features/voice/voice_screen.dart';
import 'features/onboarding/splash_screen.dart';

import 'features/notifications/notifications_screen.dart';
import 'features/profile/settings_screen.dart';
import 'features/profile/login_screen.dart';
import 'features/profile/signup_screen.dart';
import 'features/profile/otp_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // .env optional; AppConfig uses fallback URL
  }
  runApp(const SathiAIApp());
}

class SathiAIApp extends StatelessWidget {
  const SathiAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),

          '/home': (context) => MainNavigation(),
          '/notifications': (context) => const NotificationsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/signup': (context) => const SignupScreen(),
          '/login': (context) => const LoginScreen(),
          '/otp': (context) => OTPVerificationScreen(
            emailOrPhone: '',
            isEmail: true,
          ), // Placeholder, pass real args in push
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    VillageDashboardScreen(),
    SchemesScreen(),
    MarketScreen(),
    SkillsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: _buildMicButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildMicButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4CDF20).withOpacity(0.2),
              ),
            ),
            FloatingActionButton(
              backgroundColor: const Color(0xFF4CDF20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VoiceScreen()),
                );
              },
              tooltip: 'Ask Saathi',
              elevation: 6,
              shape: CircleBorder(),
              child: const Icon(Icons.mic, color: Colors.white, size: 32),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Bol Kar Poochein',
          style: TextStyle(
            color: Color(0xFF4CDF20),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabIcon(Icons.home, 'Home', 0),
          _buildTabIcon(Icons.search, 'Schemes', 1),
          const SizedBox(width: 48), // Space for mic
          _buildTabIcon(Icons.agriculture, 'Market', 2),
          _buildTabIcon(Icons.school, 'Skills', 3),
        ],
      ),
    );
  }

  Widget _buildTabIcon(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4CDF20) : Colors.grey,
            size: 28,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4CDF20) : Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
