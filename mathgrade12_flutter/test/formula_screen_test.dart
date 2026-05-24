import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathgrade12/screens/formula_screen.dart';
import 'package:mathgrade12/theme/app_theme.dart';

void main() {
  testWidgets('FormulaScreen search filters formulas correctly', (WidgetTester tester) async {
    // Build the FormulaScreen
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const FormulaScreen(),
      ),
    );

    // Initial state: should show many formulas, including 'Quadratic Formula'
    expect(find.text('Quadratic Formula'), findsOneWidget);
    expect(find.text('Sine Rule'), findsOneWidget);

    // Enter search query 'Quadratic'
    await tester.enterText(find.byType(TextField), 'Quadratic');
    await tester.pump();

    // Should still show 'Quadratic Formula'
    expect(find.text('Quadratic Formula'), findsOneWidget);
    
    // Should NOT show 'Sine Rule'
    expect(find.text('Sine Rule'), findsNothing);

    // Enter search query 'Trigonometry' (category search)
    await tester.enterText(find.byType(TextField), 'Trigonometry');
    await tester.pump();

    // Should show 'Sine Rule' (part of Trigonometry category)
    expect(find.text('Sine Rule'), findsOneWidget);
    // Should NOT show 'Quadratic Formula'
    expect(find.text('Quadratic Formula'), findsNothing);
  });

  testWidgets('FormulaScreen category chips filter correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const FormulaScreen(),
      ),
    );

    // Find the 'Algebra' chip and tap it
    await tester.tap(find.text('Algebra'));
    await tester.pump();

    // Should show 'Quadratic Formula'
    expect(find.text('Quadratic Formula'), findsOneWidget);
    // Should NOT show 'Sine Rule' (Trigonometry)
    expect(find.text('Sine Rule'), findsNothing);

    // Tap 'Trigonometry' chip
    await tester.tap(find.text('Trigonometry'));
    await tester.pump();

    // Should show 'Sine Rule'
    expect(find.text('Sine Rule'), findsOneWidget);
    // Should NOT show 'Quadratic Formula'
    expect(find.text('Quadratic Formula'), findsNothing);
  });
}
