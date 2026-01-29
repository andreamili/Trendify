
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trendify/firebase_options.dart';
import 'package:trendify/main.dart'; // ovo je OK

void main() {
  // setUpAll će se pokrenuti pre svih testova i inicijalizovati Firebase
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Inicijalizacija Firebase-a sa opcijama za trenutnu platformu
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const TrendifyApp());

    // Proveravamo da li se tekst pojavljuje
    expect(find.text('Firebase je spreman! 🎉'), findsOneWidget);
    expect(find.text('Ne postoji ovaj tekst'), findsNothing);

    // Ako želiš, možeš dodati simulaciju tastera i testiranje countera,
    // ali trenutno tvoj HomeScreen nema button, pa ne radimo to.
  });
}
