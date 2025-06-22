import 'package:flutter/material.dart';
import 'package:sotfbee/features/auth/presentation/pages/confirm_reset_page.dart';
import 'package:sotfbee/features/auth/presentation/pages/login_page.dart';
import 'package:sotfbee/features/auth/presentation/pages/register_page.dart';
import 'package:sotfbee/features/auth/presentation/pages/reset_password_page.dart';
import 'package:sotfbee/features/onboarding/presentation/landing_page.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  // Configuración para web
  setUrlStrategy(PathUrlStrategy());

  runApp(const SoftBeeApp());
}

class SoftBeeApp extends StatelessWidget {
  const SoftBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoftBee',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Manejo especial para rutas de reset-password
        if (settings.name?.startsWith('/reset-password') ?? false) {
          final uri = Uri.parse(settings.name!);
          final token = uri.queryParameters['token'] ?? '';

          if (token.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => ResetPasswordPage(token: token),
              settings: settings,
            );
          }
        }

        // Rutas normales
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const LandingPage());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (context) => RegisterPage());
          case '/forgot-password':
            return MaterialPageRoute(
              builder: (context) => const ForgotPasswordPage(),
            );
          default:
            return MaterialPageRoute(builder: (context) => const LandingPage());
        }
      },
    );
  }
}
