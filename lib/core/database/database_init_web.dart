import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> initializePlatformDatabase() async {
  try {
    databaseFactory = databaseFactoryFfiWeb;
  } catch (e) {
    debugPrint(
      'databaseFactoryFfiWeb init error, using databaseFactoryFfiWebNoWebWorker: $e',
    );
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }
}

Future<String> getPlatformDatabasePath(String dbName) async {
  if (dbName == inMemoryDatabasePath) {
    return inMemoryDatabasePath;
  }
  return dbName;
}
