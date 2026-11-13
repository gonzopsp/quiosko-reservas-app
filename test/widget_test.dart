import 'package:flutter_test/flutter_test.dart';
import 'package:quiosco_tia/main.dart';

void main() {
  testWidgets('Login navigates to the user home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const QuioscoApp());

    expect(find.text('Quiosco USM'), findsOneWidget);
    expect(find.text('Entrar como Usuario'), findsOneWidget);

    await tester.tap(find.text('Entrar como Usuario'));
    await tester.pumpAndSettle();

    expect(find.text('Catálogo de Productos'), findsOneWidget);
    expect(find.text('¡Bienvenido! Aquí verás los productos.'), findsOneWidget);
  });
}
