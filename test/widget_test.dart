import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_vocabulary/core/database/app_database.dart';
import 'package:my_vocabulary/main.dart';
import 'package:my_vocabulary/screens/vocabulary_form/vocabulary_form_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.dbName = 'test_widget.db';
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

  testWidgets('App renders Home dashboard with navigation and FAB', (WidgetTester tester) async {
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

    // Verify Title & Target Review
    expect(find.text('Kosakata Saya'), findsOneWidget);
    expect(find.text('Target Review Hari Ini'), findsOneWidget);

    // Verify Navigation Tabs
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Kosakata'), findsWidgets);

    // Verify Stat Cards
    expect(find.text('Total Kata'), findsOneWidget);
    expect(find.text('Speaking'), findsWidgets);
    expect(find.text('Writing'), findsWidgets);
    expect(find.text('General'), findsWidgets);

    // Verify Floating Action Button (+) is present
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);

    // Tap Floating Action Button to open New Vocabulary form
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // Verify Form Screen opened
    expect(find.byType(VocabularyFormScreen), findsOneWidget);
    expect(find.text('Tambah Kosakata'), findsOneWidget);
    expect(find.text('Kata atau Frasa Bahasa Inggris *'), findsOneWidget);
    expect(find.text('Arti Bahasa Indonesia *'), findsOneWidget);
  });
}
