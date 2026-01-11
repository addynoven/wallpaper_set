import 'package:flutter_test/flutter_test.dart';
import 'package:wallpaper_set/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const WallpaperApp(showOnboarding: false));
    expect(find.text('Home'), findsOneWidget);
  });
}
