/// Shared state passed between v2 screens via GoRouter `extra`.
class V2Occasion {
  final String ky;
  final String en;
  final int defaultGuests;

  const V2Occasion({
    required this.ky,
    required this.en,
    required this.defaultGuests,
  });

  static const janaza = V2Occasion(ky: 'Жаназа', en: 'Funeral', defaultGuests: 80);
  static const toi = V2Occasion(ky: 'Той', en: 'Wedding', defaultGuests: 120);
  static const tushoo = V2Occasion(ky: 'Тушоо той', en: 'Birthday', defaultGuests: 40);
  static const kudai = V2Occasion(ky: 'Кудай тамак', en: 'Memorial', defaultGuests: 30);
  static const today = V2Occasion(ky: 'Бугүн жейм', en: 'For today', defaultGuests: 4);

  static const all = [janaza, toi, tushoo, kudai, today];
}

class V2OrderDraft {
  final V2Occasion occasion;
  final int guests;
  const V2OrderDraft({required this.occasion, required this.guests});
}

class V2ProposalLine {
  final String label;
  final String detail;
  final int kgs;
  const V2ProposalLine({
    required this.label,
    required this.detail,
    required this.kgs,
  });
}

class V2Proposal {
  final V2OrderDraft draft;
  final List<V2ProposalLine> lines;
  final int total;
  const V2Proposal({
    required this.draft,
    required this.lines,
    required this.total,
  });

  /// Halal-only proposal builder. ~1.2 kg meat per guest at a Kyrgyz
  /// family event. Composes from sheep, cattle, and horse only — no
  /// other livestock categories enter this surface.
  factory V2Proposal.from(V2OrderDraft draft) {
    final kg = (draft.guests * 1.2).round();
    final lines = <V2ProposalLine>[];

    if (kg >= 200) {
      lines.add(const V2ProposalLine(
        label: '1 жылкы',
        detail: '1 horse · ~180 kg',
        kgs: 108000,
      ));
      lines.add(const V2ProposalLine(
        label: '1 кой',
        detail: '1 sheep · ~25 kg',
        kgs: 14000,
      ));
    } else if (kg >= 120) {
      lines.add(const V2ProposalLine(
        label: '1 уй',
        detail: '1 cow · ~140 kg',
        kgs: 70000,
      ));
      lines.add(const V2ProposalLine(
        label: '1 кой',
        detail: '1 sheep · ~25 kg',
        kgs: 14000,
      ));
    } else if (kg >= 60) {
      lines.add(const V2ProposalLine(
        label: '2 кой',
        detail: '2 sheep · ~50 kg',
        kgs: 28000,
      ));
    } else if (kg >= 25) {
      lines.add(const V2ProposalLine(
        label: '1 кой',
        detail: '1 sheep · ~25 kg',
        kgs: 14000,
      ));
    } else {
      lines.add(const V2ProposalLine(
        label: 'Жарым кой',
        detail: '½ sheep · ~12 kg',
        kgs: 7000,
      ));
    }

    lines.add(const V2ProposalLine(
      label: 'Халал союу + кесүү',
      detail: 'Halal slaughter + cuts',
      kgs: 3500,
    ));
    lines.add(const V2ProposalLine(
      label: 'Жеткирүү',
      detail: 'Delivery to Bishkek',
      kgs: 2500,
    ));

    final total = lines.fold<int>(0, (s, l) => s + l.kgs);
    return V2Proposal(draft: draft, lines: lines, total: total);
  }
}
