import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDown;
  final String? label;
  final Color? color;

  const NavigationArrow({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isDown = false,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          constraints: const BoxConstraints(minHeight: 38),
          padding: EdgeInsets.symmetric(
            horizontal: label != null ? 16 : 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (color ?? const Color(0xFF6366F1)).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (color ?? const Color(0xFF6366F1)).withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null && !isDown) ...[
                Text(
                  label!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              if (label != null && isDown) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
