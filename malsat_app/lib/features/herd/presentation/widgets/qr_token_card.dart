import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

/// Ownership certificate with a deterministic QR-style visual.
/// Real QR generation can be added later with qr_flutter — this version
/// renders a visually-convincing matrix derived from the token string so
/// every animal has a unique-looking code.
class QrTokenCard extends StatelessWidget {
  final String tokenId;
  final String animalName;

  const QrTokenCard({super.key, required this.tokenId, required this.animalName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0B547),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '✓ VERIFIED OWNERSHIP',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B4332),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Icon(LucideIcons.shield, size: 16, color: Colors.white.withValues(alpha: 0.7)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  size: const Size(110, 110),
                  painter: _QrPainter(seed: tokenId),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MalSat Token',
                        style: TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      animalName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('TOKEN ID',
                        style: TextStyle(fontSize: 9, color: Colors.white54, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      tokenId,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Menlo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.info, size: 12, color: Colors.white70),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Scan with vets, buyers, or inspectors to verify',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final String seed;
  _QrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    const grid = 21;
    final cell = size.width / grid;
    final paint = Paint()..color = const Color(0xFF1B4332);

    // Deterministic pattern from the seed string
    int hash = 0;
    for (var i = 0; i < seed.length; i++) {
      hash = (hash * 31 + seed.codeUnitAt(i)) & 0x7fffffff;
    }

    // Finder patterns (top-left, top-right, bottom-left 7x7)
    void finder(int x0, int y0) {
      for (var y = 0; y < 7; y++) {
        for (var x = 0; x < 7; x++) {
          final isOuter = x == 0 || x == 6 || y == 0 || y == 6;
          final isInner = x >= 2 && x <= 4 && y >= 2 && y <= 4;
          if (isOuter || isInner) {
            canvas.drawRect(
              Rect.fromLTWH((x0 + x) * cell, (y0 + y) * cell, cell, cell),
              paint,
            );
          }
        }
      }
    }

    finder(0, 0);
    finder(14, 0);
    finder(0, 14);

    // Data cells — pseudo-random from seed hash
    int h = hash;
    for (var y = 0; y < grid; y++) {
      for (var x = 0; x < grid; x++) {
        // Skip finder patterns
        if ((x < 8 && y < 8) || (x >= 13 && y < 8) || (x < 8 && y >= 13)) continue;
        h = (h * 1103515245 + 12345) & 0x7fffffff;
        if ((h >> 16) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell, cell),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) => oldDelegate.seed != seed;
}
