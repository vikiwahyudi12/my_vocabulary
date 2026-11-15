import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_vocabulary/core/database/app_database.dart';
import 'package:my_vocabulary/main.dart';
import 'package:my_vocabulary/screens/topic_explorer/topic_explorer_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.dbName = 'test_topic_explorer.db';
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

  testWidgets('Topic Explorer Screen: Displays curated IELTS topics and filters',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
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
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });

    await tester.pumpAndSettle();

    // 1. Navigate to 'Kategori & Topik' tab via Web Sidebar
    await tester.tap(find.text('Kategori & Topik'));
    await tester.pumpAndSettle();

    // Verify Topic Explorer Header is present
    expect(find.byType(TopicExplorerScreen), findsOneWidget);
    expect(find.text('TOPIK KOSAKATA IELTS'), findsOneWidget);
    expect(find.text('Jelajahi per Topik & Kategori'), findsOneWidget);

    // Verify key foundational topics requested by the user are visible
    expect(find.text('Objek & Rumah'), findsOneWidget);
    expect(find.text('Hewan & Ciri Fisik'), findsOneWidget);
    expect(find.text('Makanan, Rasa & Tekstur'), findsOneWidget);
    expect(find.text('Hutan & Alam'), findsOneWidget);

    // 2. Test search inside Topic Explorer
    final topicSearchField = find.byType(TextField);
    await tester.enterText(topicSearchField, 'makanan');
    await tester.pumpAndSettle();

    // Only Food & Taste should match
    expect(find.text('Makanan, Rasa & Tekstur'), findsOneWidget);
    expect(find.text('Objek & Rumah'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Objek & Rumah'), findsOneWidget);

    // 3. Tap on a topic card to view its modal word list
    await tester.tap(find.text('Objek & Rumah'));
    await tester.pumpAndSettle();

    // Modal sheet should display words under Objek & Rumah (e.g. Chair, Drawer, Tap)
    expect(find.text('Objek & Rumah'), findsWidgets);
    expect(find.text('Buka di Daftar'), findsOneWidget);
  });
}
