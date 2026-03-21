import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WelcomeModal extends StatelessWidget {
  const WelcomeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 20,
      backgroundColor: Colors.white,
      child: Container(
        width: 650,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '💉 OpenVAXX',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'DIY Personalized mRNA Cancer Vaccines',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'From biopsy to syringe: everything you need to synthesize personalized mRNA cancer vaccines in your garage. Focuses on open-source, state-of-the-art software tools paired with "best-tool-for-the-job" benchtop lab equipment.',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF475569),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFEE2E2), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.alertTriangle, color: Color(0xFFEF4444), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Caution',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFEF4444),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '⚠️ RESEARCH & EDUCATION USE ONLY. NOT MEDICAL ADVICE. This repository is a technical reference architecture for educational and research purposes only. Building and administering a personalized mRNA vaccine involves significant biological hazards, legal regulations, and requires regulatory oversight, institutional biosafety review, and qualified personnel. The authors do not advocate for the self-administration of any biological or medical products and assume no liability for the use or misuse of any information provided herein. Consult with qualified medical, scientific, and regulatory professionals before attempting any part of this workflow.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF991B1B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'I Understand & Want to Proceed',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
