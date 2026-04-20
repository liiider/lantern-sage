import 'package:flutter_test/flutter_test.dart';
import 'package:lantern_sage/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders the Today tab by default', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(LanternSageApp());

    expect(find.text('Today'), findsWidgets);
  });
}
