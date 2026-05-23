/// The cultural occasions a butcher-service order is prepared for.
///
/// These are not decorative — they drive default cut presets, the dua
/// the partner recites, and how the meat is portioned. The backend enum
/// is the single source of truth ([OccasionType] in prisma/schema.prisma).
enum Occasion {
  janaza('JANAZA'),
  toi('TOI'),
  tushooToi('TUSHOO_TOI'),
  kudaiTamak('KUDAI_TAMAK'),
  other('OTHER');

  final String wireName;
  const Occasion(this.wireName);

  /// i18n key suffix under `butcher.occasion.*`.
  String get i18nKey => switch (this) {
        Occasion.janaza => 'janaza',
        Occasion.toi => 'toi',
        Occasion.tushooToi => 'tushooToi',
        Occasion.kudaiTamak => 'kudaiTamak',
        Occasion.other => 'other',
      };

  static Occasion? fromWire(String? wire) {
    if (wire == null) return null;
    for (final o in Occasion.values) {
      if (o.wireName == wire) return o;
    }
    return null;
  }
}
