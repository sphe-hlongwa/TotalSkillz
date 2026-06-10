import 'package:flutter_test/flutter_test.dart';
import 'package:mathgrade12/main.dart';
import 'package:mathgrade12/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final themeService = ThemeService();
    await themeService.init();

    await tester.pumpWidget(TotalSkillzApp(themeService: themeService));
  });
}
