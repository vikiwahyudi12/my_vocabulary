import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> initializePlatformDatabase() async {
  // Use databaseFactoryFfiWebNoWebWorker directly for rock-solid cross-browser compatibility.
  // This avoids Web Worker script loading / 404 / CORS issues on Safari iOS and custom domains
  // while keeping persistent IndexedDB SQLite storage.
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}

Future<String> getPlatformDatabasePath(String dbName) async {
  if (dbName == inMemoryDatabasePath) {
    return inMemoryDatabasePath;
  }
  return dbName;
}
