import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_vocabulary/core/database/app_database.dart';
import 'package:my_vocabulary/main.dart';
import 'package:my_vocabulary/screens/vocabulary_detail/vocabulary_detail_screen.dart';
import 'package:my_vocabulary/screens/vocabulary_list/vocabulary_list_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.dbName = 'test_flow.db';
  });

  setUp(() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppDatabase.dbName);
    await AppDatabase.instance.close();
    await databaseFactory.deleteDatabase(path);
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  testWidgets('Full Vocabulary Flow: List tab, Search, Filter, Detail, Add', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyVocabularyApp(),
        ),
      );
      // Wait for SQLite FFI isolate to deliver initial database seed & query
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();

    // 1. Switch to 'Kosakata' tab
    final myVocabTab = find.text('Kosakata').last;
    await tester.tap(myVocabTab);
    await tester.pumpAndSettle();

    // Verify search bar and filter pills are present
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Speaking'), findsWidgets);
    expect(find.text('Writing'), findsWidgets);
    expect(find.text('Favorit'), findsOneWidget);

    // Initial list has the seeded words
    expect(find.text('In a nutshell'), findsOneWidget);
    expect(find.text('Mitigate'), findsOneWidget);

    // 2. Test Search
    await tester.enterText(find.byType(TextField), 'mitigate');
    await tester.pumpAndSettle();

    // Only Mitigate should appear
    expect(find.text('Mitigate'), findsOneWidget);
    expect(find.text('In a nutshell'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pumpAndSettle();
    expect(find.text('In a nutshell'), findsOneWidget);

    // 3. Test Detail Screen
    await tester.tap(find.text('In a nutshell'));
    await tester.pumpAndSettle();

    expect(find.byType(VocabularyDetailScreen), findsOneWidget);
    expect(find.text('Singkatnya / kesimpulannya'), findsOneWidget);
    expect(find.text('CONTOH KALIMAT'), findsOneWidget);

    // Back to list
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 4. Test Adding a new word via FAB
    final fab = find.byType(FloatingActionButton);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Enter English word and Indonesian meaning
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Prolific');
    await tester.enterText(textFields.at(1), 'Sangat produktif / menghasilkan banyak karya');

    // Tap Simpan inside runAsync to handle SQLite isolate write
    await tester.runAsync(() async {
      await tester.tap(find.text('Simpan'));
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();

    // Verify newly added word appears on VocabularyListScreen
    expect(
      find.descendant(
        of: find.byType(VocabularyListScreen),
        matching: find.text('Prolific'),
      ),
      findsOneWidget,
    );
  });
}
