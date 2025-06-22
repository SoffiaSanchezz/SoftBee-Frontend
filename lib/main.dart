import 'package:flutter/material.dart';
import 'package:sotfbee/core/widgets/dashboard_menu.dart';
import 'package:sotfbee/features/auth/presentation/pages/confirm_reset_page.dart';
import 'package:sotfbee/features/auth/presentation/pages/login_page.dart';
import 'package:sotfbee/features/auth/presentation/pages/register_page.dart';
import 'package:sotfbee/features/auth/presentation/pages/reset_password_page.dart';
import 'package:sotfbee/features/auth/presentation/pages/user_profile_page.dart';
import 'package:sotfbee/features/onboarding/presentation/Landing_Page.dart';

void main() {
  runApp(const SoftBeeApp());
}

class SoftBeeApp extends StatelessWidget {
  const SoftBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoftBee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF59E0B),
          primary: const Color(0xFFF59E0B),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(),
        '/menu': (context) => MenuScreen(),
        '/profile': (context) => UserProfilePage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        "/reset-password": (context) {
          final routeSettings = ModalRoute.of(context)?.settings;
          final uri = Uri.parse(routeSettings?.name ?? '');
          final token = uri.queryParameters['token'];

          if (token == null || token.isEmpty) {
            return const ForgotPasswordPage();
          }
          return ResetPasswordPage(token: token);
        },
      },
    );
  }
}
