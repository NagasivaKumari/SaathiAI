// Flutter navigation and screen structure for user account features
import 'package:flutter/material.dart';

// Screens (to be implemented)
import 'signup_screen.dart';
import 'login_screen.dart';
import 'otp_screen.dart';
import 'forgot_password_screen.dart';
import 'reset_password_screen.dart';
import 'profile_screen.dart';
import 'change_password_screen.dart';
import 'address_book_screen.dart';
import 'address_edit_screen.dart';
import 'settings_screen.dart';
import 'notification_settings_screen.dart';
import 'language_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'support_screen.dart';
import 'faq_screen.dart';
import 'report_problem_screen.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';
import 'delete_account_screen.dart';

final Map<String, WidgetBuilder> accountRoutes = {
  '/signup': (context) => SignupScreen(),
  '/login': (context) => LoginScreen(),
  '/otp': (context) => OTPScreen(),
  '/forgot-password': (context) => ForgotPasswordScreen(),
  '/reset-password': (context) => ResetPasswordScreen(),
  '/profile': (context) => ProfileScreen(),
  '/change-password': (context) => ChangePasswordScreen(),
  '/addresses': (context) => AddressBookScreen(),
  '/address-edit': (context) => AddressEditScreen(),
  '/settings': (context) => SettingsScreen(),
  '/settings/notifications': (context) => NotificationSettingsScreen(),
  '/settings/language': (context) => LanguageSettingsScreen(),
  '/settings/theme': (context) => ThemeSettingsScreen(),
  '/settings/privacy': (context) => PrivacySettingsScreen(),
  '/support': (context) => SupportScreen(),
  '/faq': (context) => FAQScreen(),
  '/report-problem': (context) => ReportProblemScreen(),
  '/terms': (context) => TermsScreen(),
  '/privacy-policy': (context) => PrivacyPolicyScreen(),
  '/delete-account': (context) => DeleteAccountScreen(),
};
