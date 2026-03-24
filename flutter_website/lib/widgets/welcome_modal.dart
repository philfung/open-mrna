import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math';

class WelcomeModal extends StatelessWidget {
  const WelcomeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 20,
        backgroundColor: const Color(0xFF1C1C1E),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 650,
            minWidth: 320,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Container(
            padding: EdgeInsets.all(
              min(MediaQuery.of(context).size.width * 0.05, 40),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '💉🐶 OpenVAXX',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(LucideIcons.x, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 8),
                  // FittedBox(
                  //   fit: BoxFit.scaleDown,
                  //   alignment: Alignment.centerLeft,
                  //   child: Text(
                  //     'A end-to-end guide to producing a personalized mRNA vaccine',
                  //     style: GoogleFonts.outfit(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.w600,
                  //       color: const Color(0xFF6366F1),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                  Text(
                    'From biopsy to syringe, this demonstrates an end-to-end workflow for producing a personalized mRNA cancer vaccine. ',
                    style: GoogleFonts.inter(
                      fontSize: min(
                        MediaQuery.of(context).size.width * 0.04,
                        16,
                      ),
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[300],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F1D1D),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF7F1D1D),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.alertTriangle,
                              color: Color(0xFFEF4444),
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Caution',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.red[400],
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '⚠️ RESEARCH & EDUCATION USE ONLY. NOT MEDICAL ADVICE. This is a reference for educational purposes. Building mRNA vaccines involves severe biological hazards, requiring strict oversight and qualified personnel. The authors assume no liability for misuse.  Do not attempt any part of this workflow.',
                          style: GoogleFonts.inter(
                            fontSize: min(
                              MediaQuery.of(context).size.width * 0.035,
                              13,
                            ),
                            fontWeight: FontWeight.w500,
                            color: Colors.red[200],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'I Understand',
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
          ),
        ),
      ),
    );
  }
}
