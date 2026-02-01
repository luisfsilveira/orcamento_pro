import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_pro/main.dart';

void main() {
  testWidgets('Verifica se o app carrega', (WidgetTester tester) async {
    await tester.pumpWidget(const OrcamentoPro());
    expect(find.text('Orçamento Pro'), findsOneWidget);
  });
}