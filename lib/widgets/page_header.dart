import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const PageHeader(
      {super.key, required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textos =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: GoogleFonts.dmSans(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: dark ? Colors.white : const Color(0xFF003D5A))),
      const SizedBox(height: 4),
      Text(subtitle,
          style:
              GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF718096))),
    ]);
    return LayoutBuilder(
        builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (constraints.maxWidth < 460) ...[
                  textos,
                  if (action != null) ...[const SizedBox(height: 14), action!],
                ] else
                  Row(children: [
                    Expanded(child: textos),
                    if (action != null) action!
                  ]),
                const SizedBox(height: 24),
              ],
            ));
  }
}
