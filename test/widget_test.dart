import 'package:flutter_test/flutter_test.dart';
import 'package:wallpaper_set/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const WallpaperApp());
    expect(find.text('Home'), findsOneWidget);
  });
}
