import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sell_api.dart';
import '../../data/ai_api.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final sellApiProvider = Provider<SellApi>((ref) {
  final dio = ref.read(dioProvider);
  return SellApi(dio);
});

final aiApiProvider = Provider<AiApi>((ref) {
  final dio = ref.read(dioProvider);
  return AiApi(dio);
});

/// Represents a picked image that hasn't been uploaded yet.
class PickedImage {
  final String path;
  final String name;

  const PickedImage({required this.path, required this.name});
}

/// Form state for creating a listing.
class SellFormState {
  final String? category;
  final String title;
  final String priceText;
  final String? breed;
  final String? description;
  final String? ageText;
  final String? weightText;
  final String? gender;
  final List<PickedImage> images;
  final bool isSubmitting;
  final String? error;

  const SellFormState({
    this.category,
    this.title = '',
    this.priceText = '',
    this.breed,
    this.description,
    this.ageText,
    this.weightText,
    this.gender,
    this.images = const [],
    this.isSubmitting = false,
    this.error,
  });

  SellFormState copyWith({
    String? Function()? category,
    String? title,
    String? priceText,
    String? Function()? breed,
    String? Function()? description,
    String? Function()? ageText,
    String? Function()? weightText,
    String? Function()? gender,
    List<PickedImage>? images,
    bool? isSubmitting,
    String? Function()? error,
  }) {
    return SellFormState(
      category: category != null ? category() : this.category,
      title: title ?? this.title,
      priceText: priceText ?? this.priceText,
      breed: breed != null ? breed() : this.breed,
      description: description != null ? description() : this.description,
      ageText: ageText != null ? ageText() : this.ageText,
      weightText: weightText != null ? weightText() : this.weightText,
      gender: gender != null ? gender() : this.gender,
      images: images ?? this.images,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error != null ? error() : this.error,
    );
  }

  bool get isValid =>
      category != null && title.isNotEmpty && priceText.isNotEmpty;

  int? get priceKgs => int.tryParse(priceText);
  int? get ageMonths => ageText != null ? int.tryParse(ageText!) : null;
  double? get weightKg =>
      weightText != null ? double.tryParse(weightText!) : null;
}

final sellFormProvider =
    StateNotifierProvider<SellFormNotifier, SellFormState>((ref) {
  return SellFormNotifier(ref);
});

class SellFormNotifier extends StateNotifier<SellFormState> {
  final Ref _ref;

  SellFormNotifier(this._ref) : super(const SellFormState());

  void setCategory(String? category) =>
      state = state.copyWith(category: () => category);
  void setTitle(String title) => state = state.copyWith(title: title);
  void setPrice(String price) => state = state.copyWith(priceText: price);
  void setBreed(String? breed) => state = state.copyWith(breed: () => breed);
  void setDescription(String? desc) =>
      state = state.copyWith(description: () => desc);
  void setAge(String? age) => state = state.copyWith(ageText: () => age);
  void setWeight(String? weight) =>
      state = state.copyWith(weightText: () => weight);
  void setGender(String? gender) =>
      state = state.copyWith(gender: () => gender);

  void addImage(PickedImage image) {
    state = state.copyWith(images: [...state.images, image]);
  }

  void removeImage(int index) {
    final updated = [...state.images]..removeAt(index);
    state = state.copyWith(images: updated);
  }

  /// AI-analyze the first image and auto-fill the form.
  Future<AiAnalysisResult?> analyzeWithAi(String lang) async {
    if (state.images.isEmpty) return null;

    state = state.copyWith(isSubmitting: true, error: () => null);

    try {
      final aiApi = _ref.read(aiApiProvider);
      final img = state.images.first;

      final result = await aiApi.analyzePhoto(
        filePath: img.path,
        fileName: img.name,
        lang: lang,
      );

      // Auto-fill form with AI results
      state = state.copyWith(
        category: () => result.category,
        title: result.title ?? state.title,
        priceText: result.suggestedPriceKgs?.toString() ?? state.priceText,
        breed: () => result.breed,
        description: () => result.description,
        ageText: () => result.estimatedAgeMonths?.toString(),
        weightText: () => result.estimatedWeightKg?.toStringAsFixed(0),
        gender: () => result.gender,
        isSubmitting: false,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: () => e.toString(),
      );
      return null;
    }
  }

  /// Analyze photo quality and get enhancement suggestions.
  Future<PhotoQualityResult?> analyzePhotoQuality() async {
    if (state.images.isEmpty) return null;

    try {
      final aiApi = _ref.read(aiApiProvider);
      final img = state.images.first;

      return await aiApi.analyzePhotoQuality(
        filePath: img.path,
        fileName: img.name,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> submit() async {
    if (!state.isValid) return false;

    state = state.copyWith(isSubmitting: true, error: () => null);

    try {
      final api = _ref.read(sellApiProvider);

      // 1. Create the listing
      final listingData = await api.createListing(
        category: state.category!,
        title: state.title,
        priceKgs: state.priceKgs!,
        breed: state.breed,
        description: state.description,
        ageMonths: state.ageMonths,
        weightKg: state.weightKg,
        gender: state.gender,
      );

      final listingId = listingData['id'] as String;

      // 2. Upload images and attach to listing
      for (var i = 0; i < state.images.length; i++) {
        final img = state.images[i];
        await api.uploadMedia(
          filePath: img.path,
          fileName: img.name,
          listingId: listingId,
          isPrimary: i == 0,
        );
      }

      // Reset form on success
      state = const SellFormState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: () => e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const SellFormState();
}
