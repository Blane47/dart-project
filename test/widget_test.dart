import 'package:dart_project/shared/strings.dart';
import 'package:dart_project/shared/theme/theme.dart';
import 'package:dart_project/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget-level smoke tests for shared components. The full app is gated behind
/// Firebase init, so these exercise the design system in isolation instead.
void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('PrimaryButton shows its label and fires onPressed', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(PrimaryButton(label: 'Continue', onPressed: () => taps++)),
    );

    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    expect(taps, 1);
  });

  testWidgets('PrimaryButton is inert when disabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      // onPressed null => disabled.
      wrap(const PrimaryButton(label: 'Disabled', onPressed: null)),
    );
    await tester.tap(find.text('Disabled'));
    expect(taps, 0);
  });

  testWidgets('BalanceText masks the amount when hidden', (tester) async {
    await tester.pumpWidget(
      wrap(const BalanceText(amount: 12480, hidden: true)),
    );
    await tester.pump(); // let the AnimatedSwitcher settle

    expect(find.text('••••••'), findsOneWidget);
    expect(find.text('12,480'), findsNothing);
    expect(find.text(AppStrings.currencyCode), findsOneWidget);
  });

  testWidgets('BalanceText shows the grouped amount when visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const BalanceText(amount: 12480, hidden: false)),
    );
    await tester.pump();

    expect(find.text('12,480'), findsOneWidget);
  });
}
