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
    AppDatabase.dbName = 'test_responsive_web.db';
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

  testWidgets('Responsive Layout: Renders Web Sidebar on wide screens (>= 850px)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
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

    // In wide mode: sidebar should be visible
    expect(find.text('NAVIGASI'), findsOneWidget);
    expect(find.text('Tambah Kosakata'), findsOneWidget);
    expect(find.text('Kosakata Favorit'), findsOneWidget);
    expect(find.text('Total Koleksi'), findsOneWidget);

    // BottomAppBar should NOT be present on wide screens
    expect(find.byType(BottomAppBar), findsNothing);

    // Tap "Daftar Kosakata" in the sidebar
    await tester.tap(find.text('Daftar Kosakata'));
    await tester.pumpAndSettle();

    // Verify search bar in vocabulary list is displayed
    expect(find.byType(TextField), findsOneWidget);

    // Tap "+ Tambah Kosakata" in the sidebar
    await tester.tap(find.text('Tambah Kosakata'));
    await tester.pumpAndSettle();

    // VocabularyFormScreen should be opened
    expect(find.byType(VocabularyFormScreen), findsOneWidget);
  });

  testWidgets('Responsive Layout: Renders Mobile BottomBar on compact screens (< 850px)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
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

    // In mobile mode: sidebar should NOT be visible
    expect(find.text('NAVIGASI'), findsNothing);

    // Mobile BottomAppBar and center FloatingActionButton should be present
    expect(find.byType(BottomAppBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
