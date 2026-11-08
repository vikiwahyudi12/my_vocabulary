import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_vocabulary/core/database/app_database.dart';
import 'package:my_vocabulary/main.dart';
import 'package:my_vocabulary/models/vocabulary_model.dart';
import 'package:my_vocabulary/screens/vocabulary_form/vocabulary_form_screen.dart';
import 'package:my_vocabulary/screens/vocabulary_list/vocabulary_list_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.dbName = 'test_add_vocab.db';
  });

  setUp(() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppDatabase.dbName);
    await AppDatabase.instance.close();
    await databaseFactory.deleteDatabase(path);
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });

  testWidgets('Integration Test: Add new vocabulary from form and verify persistence', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch App
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyVocabularyApp(),
        ),
      );
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();

    // 2. Open Add Vocabulary Form from Sidebar
    final addButton = find.widgetWithText(FilledButton, 'Tambah Kosakata');
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.byType(VocabularyFormScreen), findsOneWidget);

    // 3. Fill the form
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Ubiquitous');
    await tester.enterText(textFields.at(1), 'Ada di mana-mana');
    await tester.pumpAndSettle();

    // 4. Tap Simpan inside runAsync to handle SQLite isolate write
    await tester.runAsync(() async {
      await tester.tap(find.text('Simpan'));
      for (int i = 0; i < 15; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();

    // 5. Verify Form closed
    expect(find.byType(VocabularyFormScreen), findsNothing);

    // 6. Verify in Database directly using runAsync
    late List<Vocabulary> dbVocabs;
    await tester.runAsync(() async {
      dbVocabs = await AppDatabase.instance.getAllVocabularies();
    });
    final ubiquitous = dbVocabs.firstWhere((v) => v.word == 'Ubiquitous');
    expect(ubiquitous.meaning, 'Ada di mana-mana');
    expect(ubiquitous.level, 'Advance');

    // 7. Navigate to Vocabulary List and verify it appears in UI
    final listTab = find.text('Daftar Kosakata');
    await tester.runAsync(() async {
      await tester.tap(listTab);
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();

    expect(find.byType(VocabularyListScreen), findsOneWidget);
    expect(find.text('Ubiquitous'), findsWidgets);
    expect(find.text('Ada di mana-mana'), findsWidgets);
  });
}
