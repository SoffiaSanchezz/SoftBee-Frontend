import 'package:flutter/material.dart';
import 'package:sotfbee/features/auth/presentation/pages/confirm_reset_page.dart';
import 'package:sotfbee/features/auth/presentation/pages/login_page.dart';
import 'package:sotfbee/features/auth/presentation/pages/register_page.dart';
import 'package:sotfbee/features/auth/presentation/pages/reset_password_page.dart';
import 'package:sotfbee/features/onboarding/presentation/landing_page.dart';

void main() {
  runApp(const SoftBeeApp());
}

class SoftBeeApp extends StatelessWidget {
  const SoftBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoftBee',
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/reset-password': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final String token;

          if (args is String) {
            token = args;
          } else {
            // Manejar el caso cuando se navega directamente sin token
            final routeSettings = ModalRoute.of(context)?.settings;
            final uri = Uri.parse(routeSettings?.name ?? '');
            token = uri.queryParameters['token'] ?? '';
          }

          if (token.isEmpty) {
            return const ForgotPasswordPage();
          }
          return ResetPasswordPage(token: token);
        },
      },
    );
  }
}