import 'package:flutter/material.dart';
import '../../domain/entity/vehicle_region.dart';
import '../../domain/entity/autocenter_budget.dart';

Color stateColor(InspectionState? state) => switch (state) {
  InspectionState.normal => const Color(0xffb7ddc3),
  InspectionState.scratched => const Color(0xffbcd4f1),
  InspectionState.broken => const Color(0xfff1d780),
  InspectionState.dented => const Color(0xffefb3aa),
  null => const Color(0xffe1e7de),
};

// Parser restrito aos comandos absolutos M/L/H/V/Q/Z dos nossos paths estáticos.
// Não aceita SVG de rede ou do usuário.
Path regionPath(String source) {
  final tokens = RegExp(
    r'[MLHVQZ]|-?\d+(?:\.\d+)?',
  ).allMatches(source).map((m) => m[0]!).toList();
  final path = Path();
  var i = 0;
  var x = 0.0, y = 0.0;
  double next() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    switch (tokens[i++]) {
      case 'M':
        x = next();
        y = next();
        path.moveTo(x, y);
      case 'L':
        x = next();
        y = next();
        path.lineTo(x, y);
      case 'H':
        x = next();
        path.lineTo(x, y);
      case 'V':
        y = next();
        path.lineTo(x, y);
      case 'Q':
        final cx = next(), cy = next();
        x = next();
        y = next();
        path.quadraticBezierTo(cx, cy, x, y);
      case 'Z':
        path.close();
      default:
        throw const FormatException('Comando vetorial inesperado');
    }
  }
  return path;
}

final carPaths = carRegions.map((r) => regionPath(r.svg)).toList();

class InspectionCar extends StatelessWidget {
  const InspectionCar({
    super.key,
    required this.inspection,
    required this.selected,
    required this.onSelect,
  });
  final VehicleInspection inspection;
  final int selected;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text(
        '↑ FRENTE DO VEÍCULO',
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 2,
          color: Color(0xff69746d),
        ),
      ),
      const SizedBox(height: 8),
      AspectRatio(
        aspectRatio: 2 / 3,
        child: LayoutBuilder(
          builder: (context, box) {
            return Semantics(
              label:
                  'Carro visto de cima. As mesmas 22 regiões estão disponíveis na lista.',
              child: GestureDetector(
                onTapUp: (event) {
                  final p = Offset(
                    event.localPosition.dx * 400 / box.maxWidth,
                    event.localPosition.dy * 600 / box.maxHeight,
                  );
                  for (var i = carPaths.length - 1; i >= 0; i--) {
                    if (carPaths[i].contains(p)) {
                      onSelect(i + 1);
                      return;
                    }
                  }
                },
                child: CustomPaint(
                  painter: _CarPainter(List.of(inspection.regions), selected),
                ),
              ),
            );
          },
        ),
      ),
      Wrap(
        spacing: 12,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [null, ...InspectionState.values]
            .map(
              (s) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: stateColor(s),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    s?.label ?? 'Pendente',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    ],
  );
}

class _CarPainter extends CustomPainter {
  _CarPainter(this.states, this.selected);
  final List<InspectionState?> states;
  final int selected;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 400, size.height / 600);
    for (var i = 0; i < carPaths.length; i++) {
      canvas.drawPath(carPaths[i], Paint()..color = stateColor(states[i]));
      canvas.drawPath(
        carPaths[i],
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    final glass = Paint()..color = const Color(0xff536f62);
    canvas.drawPath(
      regionPath('M155 161Q200 143 245 161L253 193Q200 182 147 193Z'),
      glass,
    );
    canvas.drawPath(
      regionPath('M149 393Q200 404 251 393L241 421Q200 431 159 421Z'),
      glass,
    );
    canvas.drawPath(
      carPaths[selected - 1],
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
    for (final region in carRegions) {
      final center = Offset(region.x, region.y);
      canvas.drawCircle(center, 10, Paint()..color = const Color(0xff30463a));
      final label = TextPainter(
        text: TextSpan(
          text: '${region.id}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, center - Offset(label.width / 2, label.height / 2));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CarPainter old) => true;
}
