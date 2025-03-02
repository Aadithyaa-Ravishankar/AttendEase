import 'package:flutter/material.dart';

class NeomorphicContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final double blurRadius;
  final Offset offset;
  final EdgeInsets padding;

  const NeomorphicContainer({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.color,
    this.textColor,
    this.borderRadius = 16.0,
    this.blurRadius = 22.0,
    this.offset = const Offset(6, 6),
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Colors.black87;
    final primaryTextColor = textColor ?? Colors.greenAccent;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.2), // Soft green glow
            offset: -offset,
            blurRadius: blurRadius,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5), // Dark shadow for depth
            offset: offset,
            blurRadius: blurRadius,
          ),
        ],
      ),
      child: Row(
        children: [
          // Content Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryTextColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Trailing Widget (Icon, Button, etc.)
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
