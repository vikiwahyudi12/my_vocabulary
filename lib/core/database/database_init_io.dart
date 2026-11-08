import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> initializePlatformDatabase() async {
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

Future<String> getPlatformDatabasePath(String dbName) async {
  if (dbName == inMemoryDatabasePath) {
    return inMemoryDatabasePath;
  }
  final dbPath = await getDatabasesPath();
  return join(dbPath, dbName);
}
