import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sotfbee/main.dart'; // Asegúrate de que esta ruta sea correcta

void main() {
  testWidgets('SoftBeeApp smoke test', (WidgetTester tester) async {
    // Construye el widget y espera a que se estabilice
    await tester.pumpWidget(const SoftBeeApp());

    // Puedes agregar más pruebas si tu landing page tiene texto o widgets esperados.
    // Por ejemplo, si hay un texto 'Bienvenido' en la LandingPage:
    expect(find.text('Bienvenido'), findsOneWidget);

    // Este test de contador es solo un ejemplo, puedes eliminarlo si no tienes un contador
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
