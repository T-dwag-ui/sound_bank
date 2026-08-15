import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/editor_view_model.dart';

class AiMasteringView extends StatelessWidget {
  const AiMasteringView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditorViewModel>();
    final state = vm.masteringState;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF14151B), // Deep Mastering Metal Charcoal
        border: Border(
          top: BorderSide(color: const Color(0xFF8B5CF6).withValues(alpha: 0.6), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // 1. Mastering Control Bar
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFF1E1E24),
            child: Row(
              children: [
                const Icon(Icons.graphic_eq_rounded, color: Color(0xFFA855F7), size: 18),
                const SizedBox(width: 8),
                const Text(
                  'LOGIC AI MASTERING ASSISTANT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(width: 16),

                // LUFS Target Selector
                const Text('Target Loudness: ', style: TextStyle(color: Colors.white60, fontSize: 11)),
                DropdownButton<double>(
                  value: state.targetLufs,
                  dropdownColor: const Color(0xFF25252A),
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 11),
                  items: const [
                    DropdownMenuItem(value: -14.0, child: Text('-14.0 LUFS (Spotify / Apple Music)')),
                    DropdownMenuItem(value: -9.0, child: Text('-9.0 LUFS (Club / Festival EDM)')),
                    DropdownMenuItem(value: -16.0, child: Text('-16.0 LUFS (TV & Broadcast)')),
                  ],
                  onChanged: (val) {
                    if (val != null) vm.setTargetLufs(val);
                  },
                ),

                const Spacer(),

                // A/B Comparison Toggle
                Row(
                  children: [
                    const Text('A/B Bypass', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    Switch(
                      value: state.isAbBypass,
                      activeThumbColor: Colors.amberAccent,
                      onChanged: (_) => vm.toggleAbBypass(),
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                // Analyze & Auto-Master Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: vm.isAnalyzingMaster ? null : vm.runAiAutoMaster,
                  icon: vm.isAnalyzingMaster
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.bolt, size: 16),
                  label: Text(
                    vm.isAnalyzingMaster ? 'Analyzing Spectrum...' : 'Analyze & Auto-Master',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // 2. Spectrum Analyzer & Mastering Chain Controls
          Expanded(
            child: Row(
              children: [
                // AI Spectrum Analyzer Visualizer
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0B10),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'REALTIME SPECTRUM ANALYZER & DYNAMIC EQ',
                              style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              state.isMastered ? 'MASTER APPLIED (-14 LUFS)' : 'RAW UNMASTERED',
                              style: TextStyle(
                                color: state.isMastered ? Colors.greenAccent : Colors.amberAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Spectrum Graph Painter
                        Expanded(
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _SpectrumAnalyzerPainter(
                              isMastered: state.isMastered,
                              bands: state.eqBands,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Mastering Chain FX Controls
                Container(
                  width: 250,
                  margin: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1C22),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MASTERING CHAIN FX',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Compressor Threshold
                      _buildFxSliderRow('Threshold', '${state.thresholdDb} dB', (state.thresholdDb + 40) / 40.0, (_) {}),
                      // Stereo Width
                      _buildFxSliderRow('Stereo Width', '${(state.stereoWidth * 100).toInt()}%', (state.stereoWidth - 1.0) / 0.8, (_) {}),
                      // Tape Drive
                      _buildFxSliderRow('Tape Warmth', '${(state.exciterDrive * 100).toInt()}%', state.exciterDrive, (_) {}),
                      // Ceiling
                      _buildFxSliderRow('Peak Limiter', '${state.ceilingDb} dB', 0.9, (_) {}),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom AI Diagnostic Log
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color(0xFF101014),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFEC4899), size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vm.aiMasterDiagnostic,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontFamily: 'Monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFxSliderRow(String title, String valText, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10)),
              Text(valText, style: const TextStyle(color: Colors.cyanAccent, fontSize: 9, fontFamily: 'Monospace')),
            ],
          ),
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 2.5,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
              activeTrackColor: Color(0xFFA855F7),
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: value.clamp(0.0, 1.0),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpectrumAnalyzerPainter extends CustomPainter {
  final bool isMastered;
  final List<dynamic> bands;

  _SpectrumAnalyzerPainter({required this.isMastered, required this.bands});

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = isMastered ? const Color(0xFF10B981) : const Color(0xFF38BDF8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = (isMastered ? const Color(0xFF10B981) : const Color(0xFF38BDF8)).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    fillPath.moveTo(0, size.height);
    path.moveTo(0, size.height * 0.7);
    fillPath.lineTo(0, size.height * 0.7);

    const points = 60;
    final step = size.width / points;

    for (int i = 1; i <= points; i++) {
      final x = i * step;
      double amplitude = 0.3 + 0.5 * ((i * 13 + 7) % 19) / 19.0;
      if (isMastered) amplitude *= 1.25; // Enhanced spectral balance
      final y = size.height * (1.0 - amplitude.clamp(0.1, 0.9));

      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, wavePaint);

    // Draw Frequency Grid Labels (20Hz - 20kHz)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (int i = 1; i < 5; i++) {
      final gridX = (i / 5.0) * size.width;
      canvas.drawLine(Offset(gridX, 0), Offset(gridX, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
