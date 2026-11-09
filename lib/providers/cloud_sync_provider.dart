import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/cloud_sync_service.dart';

final authUserProvider = StreamProvider<User?>((ref) {
  return CloudSyncService.instance.authStateChanges;
});

final isCloudConnectedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(authUserProvider);
  return userAsync.value != null;
});
