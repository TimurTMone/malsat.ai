/// The cut presets a customer can pick for their butcher-service order.
///
/// Values are short opaque codes persisted server-side in `MeatOrder.cuttingPreset`
/// (JSON array). The display labels live in i18n under `butcher.cut.*`.
///
/// `BONE_IN` / `BONELESS` is mutually exclusive (radio). The rest are
/// independent toggles a customer can stack — except `WHOLE`, which when
/// chosen disables every other portion-specific cut.
enum Cut {
  whole('WHOLE'), // бүтүн — no portioning
  halvesQuarters('HALVES_QUARTERS'),
  cubedEsh('CUBED_ESH'), // кесинди эт for бешбармак / куурдак
  groundKyima('GROUND_KYIMA'), // кыйма
  organsAndTailFat('ORGANS_TAIL_FAT'), // каа-сан / куйрук май
  boneIn('BONE_IN'),
  boneless('BONELESS');

  final String wireName;
  const Cut(this.wireName);

  String get i18nKey => switch (this) {
        Cut.whole => 'whole',
        Cut.halvesQuarters => 'halvesQuarters',
        Cut.cubedEsh => 'cubedEsh',
        Cut.groundKyima => 'groundKyima',
        Cut.organsAndTailFat => 'organsAndTailFat',
        Cut.boneIn => 'boneIn',
        Cut.boneless => 'boneless',
      };

  static Cut? fromWire(String wire) {
    for (final c in Cut.values) {
      if (c.wireName == wire) return c;
    }
    return null;
  }
}

/// Defaults vary by occasion (validated with partner before P0 launch):
/// - Жаназа: halves/quarters, bone-in — for distribution to mourners
/// - Той: cubed for бешбармак, plus organs/tail fat — banquet
/// - Тушоо той: cubed, boneless — smaller scale
/// - Кудай тамак: cubed, bone-in — boiled
/// - Other: whole — let the customer decide
List<Cut> defaultCutsForOccasion(String occasionWireName) {
  switch (occasionWireName) {
    case 'JANAZA':
      return const [Cut.halvesQuarters, Cut.boneIn];
    case 'TOI':
      return const [Cut.cubedEsh, Cut.organsAndTailFat, Cut.boneIn];
    case 'TUSHOO_TOI':
      return const [Cut.cubedEsh, Cut.boneless];
    case 'KUDAI_TAMAK':
      return const [Cut.cubedEsh, Cut.boneIn];
    default:
      return const [Cut.whole];
  }
}
