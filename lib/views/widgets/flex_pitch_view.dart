import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/track_model.dart';
import '../../view_models/editor_view_model.dart';

class FlexPitchView extends StatelessWidget {
  const FlexPitchView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditorViewModel>();
    final track = vm.selectedTrack;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22), // Logic Editor Dark Grey
        border: Border(
          top: BorderSide(color: const Color(0xFF38BDF8).withValues(alpha: 0.6), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // 1. Top Editor Header Tabs (Track / File / Flex Pitch)
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color(0xFF28282D),
            child: Row(
              children: [
                // Track / File Tab Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Track',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: const Text(
                    'File',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),

                const SizedBox(width: 16),
                Container(width: 1, height: 18, color: Colors.white12),
                const SizedBox(width: 16),

                // Flex Pitch Mode Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.multitrack_audio, color: Color(0xFF10B981), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Flex Pitch Mode',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Note Selection Status
                Text(
                  '114 Notes selected in 2 Regions (${track.name})',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),

          // 2. Main Flex Pitch Work Area (Left Controls + Piano Roll Note Canvas)
          Expanded(
            child: Row(
              children: [
                // Left Flex Pitch Control Panel (Matching Logic Reference Image)
                Container(
                  width: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222226),
                    border: Border(
                      right: BorderSide(color: Colors.black.withValues(alpha: 0.6)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Badge with Vocal Mic Icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.mic, color: Colors.cyanAccent, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flex Pitch Editor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Fine Tuning & Correction',
                                style: TextStyle(color: Colors.white38, fontSize: 9),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Pitch Correction Slider (0 - 100%)
                      const Text(
                        'Pitch Correction',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: const SliderThemeData(
                                trackHeight: 3,
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                                activeTrackColor: Color(0xFF38BDF8),
                                inactiveTrackColor: Colors.white12,
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: vm.globalPitchCorrection,
                                min: 0.0,
                                max: 100.0,
                                onChanged: vm.setGlobalPitchCorrection,
                              ),
                            ),
                          ),
                          Text(
                            '${vm.globalPitchCorrection.toInt()}%',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              fontFamily: 'Monospace',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Scale Quantize Selector
                      const Text(
                        'Scale Quantize',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161618),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: DropdownButton<String>(
                                value: vm.scaleQuantize,
                                dropdownColor: const Color(0xFF222226),
                                isExpanded: true,
                                underline: const SizedBox(),
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                                items: const [
                                  DropdownMenuItem(value: 'Major', child: Text('Major Scale')),
                                  DropdownMenuItem(value: 'Minor', child: Text('Minor Scale')),
                                  DropdownMenuItem(value: 'Chromatic', child: Text('Chromatic')),
                                  DropdownMenuItem(value: 'Off', child: Text('Off')),
                                ],
                                onChanged: (val) {
                                  if (val != null) vm.setScaleQuantize(val);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: const Size(30, 32),
                            ),
                            onPressed: () {},
                            child: const Text('Q', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Formant & Fine Pitch Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Formant Shift:', style: TextStyle(color: Colors.white54, fontSize: 10)),
                          Text(
                            '${vm.globalFormantShift} st',
                            style: const TextStyle(color: Colors.amber, fontSize: 10, fontFamily: 'Monospace'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right Flex Pitch Piano Roll Grid & Note Nodes Canvas
                Expanded(
                  child: Container(
                    color: const Color(0xFF131316),
                    child: Stack(
                      children: [
                        // Piano Roll Note Grid & Pitch Nodes
                        CustomPaint(
                          size: Size.infinite,
                          painter: _FlexPitchNodesPainter(
                            selectedNode: vm.selectedPitchNode,
                            pitchCorrection: vm.globalPitchCorrection,
                          ),
                        ),

                        // Fine Pitch Tooltip Overlay (matching reference image)
                        Positioned(
                          top: 40,
                          left: 210,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4)],
                            ),
                            child: const Text(
                              'Fine Pitch: 0',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _FlexPitchNodesPainter extends CustomPainter {
  final FlexPitchNode? selectedNode;
  final double pitchCorrection;

  _FlexPitchNodesPainter({required this.selectedNode, required this.pitchCorrection});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Horizontal Piano Roll Keys Grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const keyCount = 10;
    final rowHeight = size.height / keyCount;

    for (int i = 0; i <= keyCount; i++) {
      canvas.drawLine(Offset(0, i * rowHeight), Offset(size.width, i * rowHeight), gridPaint);
    }

    // 2. Draw Audio Waveform Background Silhouette (Flex Pitch Backdrop)
    final wavePaint = Paint()
      ..color = const Color(0xFF0EA5E9).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    const points = 50;
    final step = size.width / points;

    for (int i = 0; i <= points; i++) {
      final x = i * step;
      final amplitude = (0.2 + 0.8 * ((i * 7 + 3) % 13) / 13.0) * (size.height * 0.35);
      final y = size.height * 0.5 + (i % 2 == 0 ? -amplitude : amplitude);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);

    // 3. Draw Flex Pitch Note Rectangles & Pitch Drift Curves (Logic Pro Style)
    final noteBlockPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final pitchCurvePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Pitch Notes Demo Blocks
    final notes = [
      Rect.fromLTWH(40, rowHeight * 6, 70, rowHeight * 0.7),
      Rect.fromLTWH(130, rowHeight * 5, 80, rowHeight * 0.7),
      Rect.fromLTWH(230, rowHeight * 3, 90, rowHeight * 0.7),
      Rect.fromLTWH(340, rowHeight * 4, 75, rowHeight * 0.7),
      Rect.fromLTWH(440, rowHeight * 2, 85, rowHeight * 0.7),
    ];

    for (int i = 0; i < notes.length; i++) {
      final rect = notes[i];
      final isSelected = i == 2;

      // Note Box
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        isSelected ? (Paint()..color = const Color(0xFF2563EB)) : noteBlockPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        borderPaint,
      );

      // Pitch Drift Curve Line inside/around note
      final curvePath = Path();
      curvePath.moveTo(rect.left - 10, rect.center.dy + 8);
      curvePath.cubicTo(
        rect.left + rect.width * 0.25,
        rect.center.dy - 12,
        rect.left + rect.width * 0.75,
        rect.center.dy + 10,
        rect.right + 10,
        rect.center.dy - 4,
      );
      canvas.drawPath(curvePath, pitchCurvePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
