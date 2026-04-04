import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/user_api.dart';
import '../../domain/user_profile_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final userApiProvider = Provider<UserApi>((ref) {
  final dio = ref.read(dioProvider);
  return UserApi(dio);
});

/// Fetch a public user profile by ID.
final userProfileProvider =
    FutureProvider.family<UserProfileModel, String>((ref, userId) async {
  final api = ref.read(userApiProvider);
  final data = await api.getUser(userId);
  return UserProfileModel.fromJson(data);
});

/// Fetch the current authenticated user's profile.
final myProfileProvider = FutureProvider<UserProfileModel?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;

  final api = ref.read(userApiProvider);
  final data = await api.getUser(currentUser.id);
  return UserProfileModel.fromJson(data);
});
