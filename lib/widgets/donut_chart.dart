import 'package:flutter/material.dart';

class DonutSlice {
  final String label;
  final double value;
  final Color color;
  const DonutSlice(this.label, this.value, this.color);
}

class DonutChart extends StatelessWidget {
  final List<DonutSlice> data;
  final String centerLabel;
  final String centerValue;
  const DonutChart(
      {super.key,
      required this.data,
      required this.centerLabel,
      required this.centerValue});
  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, item) => sum + item.value);
    final legend = Column(children: [
      for (final item in data)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(item.label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12))),
              Text(total == 0 ? '0%' : '${(item.value / total * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700))
            ]))
    ]);
    Widget chart(double size) => SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(
              size: Size(size, size),
              painter: _DonutPainter(
                  data,
                  total,
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF29414C)
                      : const Color(0xFFE5EDE2))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(centerValue,
                style: TextStyle(
                    fontSize: size < 160 ? 19 : 24,
                    fontWeight: FontWeight.w800)),
            Text(centerLabel,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: size < 160 ? 9 : 11))
          ])
        ]));
    return LayoutBuilder(builder: (_, c) {
      // A row makes the summary short enough to leave room for the records.
      if (c.maxWidth >= 310) {
        return Row(children: [
          chart(132),
          const SizedBox(width: 14),
          Expanded(child: legend)
        ]);
      }
      return Column(children: [chart(145), const SizedBox(height: 8), legend]);
    });
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSlice> data;
  final double total;
  final Color track;
  _DonutPainter(this.data, this.total, this.track);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2 - 12);
    canvas.drawArc(
        rect,
        0,
        6.283185,
        false,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22);
    var start = -1.570796;
    final safe = total == 0 ? 1 : total;
    for (final item in data) {
      final sweep = item.value / safe * 6.283185;
      if (sweep > 0)
        canvas.drawArc(
            rect,
            start,
            (sweep - .035).clamp(0, sweep),
            false,
            Paint()
              ..color = item.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 22);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.data != data || old.total != total;
}
