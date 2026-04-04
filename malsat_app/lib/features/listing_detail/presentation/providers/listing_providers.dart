import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/listing_api.dart';
import '../../data/listing_repository.dart';
import '../../domain/listing_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final listingApiProvider = Provider<ListingApi>((ref) {
  final dio = ref.read(dioProvider);
  return ListingApi(dio);
});

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository(ref.read(listingApiProvider));
});

/// Fetch a single listing by ID
final listingDetailProvider =
    FutureProvider.family<ListingModel, String>((ref, id) async {
  final repo = ref.read(listingRepositoryProvider);
  return repo.getListing(id);
});
