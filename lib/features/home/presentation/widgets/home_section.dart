import 'package:flutter/material.dart';

class HomeSection extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color? color;
  final bool highlighted;
  final bool fullWidth;
  final double height;

  const HomeSection({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.color,
    this.highlighted = false,
    this.fullWidth = false,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Colors.black87;

    return Container(
      width: fullWidth ? double.infinity : null,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFF4ED) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted ? const Color(0xFFFFE1D2) : const Color(0xFFEDEDED),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Text(
            count.toString(),
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}