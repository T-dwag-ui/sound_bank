import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/editor_view_model.dart';

class AudioSamplerView extends StatelessWidget {
  const AudioSamplerView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditorViewModel>();

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF18181B), // Dark Slate Metal
        border: Border(
          top: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.6), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // 1. Top Sampler Toolbar
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFF222226),
            child: Row(
              children: [
                const Icon(Icons.keyboard_rounded, color: Colors.cyanAccent, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'QUICK SAMPLER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(width: 12),

                // Loaded Sample Badge & File Loader
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.audio_file, color: Colors.cyanAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        vm.sampleName,
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Load New Sound Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334155),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.file_upload_outlined, size: 14),
                  label: const Text('Load Sound', style: TextStyle(fontSize: 11)),
                ),

                const Spacer(),

                // Pitch Shift Control
                Row(
                  children: [
                    const Text('Pitch Shift: ', style: TextStyle(color: Colors.white60, fontSize: 11)),
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white, size: 14),
                      onPressed: () => vm.setSamplePitchShift(vm.samplePitchShift - 1),
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      '${vm.samplePitchShift > 0 ? "+" : ""}${vm.samplePitchShift} st',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        fontFamily: 'Monospace',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 14),
                      onPressed: () => vm.setSamplePitchShift(vm.samplePitchShift + 1),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // Convert Audio to MIDI Sampler Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: vm.convertAudioToMidiSampler,
                  icon: const Icon(Icons.auto_awesome, size: 14),
                  label: const Text(
                    'Audio -> MIDI Sampler',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Sampler Canvas (Waveform Display + ADSR Controls)
          Expanded(
            child: Row(
              children: [
                // Waveform Slicing Display Canvas
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D11),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Stack(
                      children: [
                        // Waveform Graphic with Slices
                        CustomPaint(
                          size: Size.infinite,
                          painter: _SamplerWaveformPainter(sliceCount: vm.sliceCount),
                        ),

                        // Overlay Badges
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            color: Colors.black.withValues(alpha: 0.7),
                            child: const Text(
                              'Transient Slices Mode (8 Regions)',
                              style: TextStyle(color: Colors.cyanAccent, fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ADSR Envelope Controls
                Container(
                  width: 220,
                  margin: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131317),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ADSR ENVELOPE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ADSR Sliders Row
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAdsrKnob('A', vm.sampleAttack, (v) => vm.setSampleAdsr(attack: v)),
                            _buildAdsrKnob('D', vm.sampleDecay, (v) => vm.setSampleAdsr(decay: v)),
                            _buildAdsrKnob('S', vm.sampleSustain, (v) => vm.setSampleAdsr(sustain: v)),
                            _buildAdsrKnob('R', vm.sampleRelease, (v) => vm.setSampleAdsr(release: v)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Playable Interactive Virtual MIDI Piano Keyboard
          SizedBox(
            height: 70,
            child: _buildVirtualPianoKeyboard(context, vm),
          ),
        ],
      ),
    );
  }

  Widget _buildAdsrKnob(String label, double val, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 3,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                activeTrackColor: Color(0xFFEC4899),
                inactiveTrackColor: Colors.white12,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: val,
                min: 0.0,
                max: 1.0,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
        ),
        Text(
          '${(val * 100).toInt()}%',
          style: const TextStyle(color: Colors.grey, fontSize: 8, fontFamily: 'Monospace'),
        ),
      ],
    );
  }

  Widget _buildVirtualPianoKeyboard(BuildContext context, EditorViewModel vm) {
    // Generates 2 Octaves (24 Keys: C3 to B4)
    final whiteNotes = [60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 77, 79, 81, 83];
    final noteLabels = ['C3', 'D3', 'E3', 'F3', 'G3', 'A3', 'B3', 'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4'];

    return Container(
      color: const Color(0xFF0F0F12),
      child: Stack(
        children: [
          // White Keys
          Row(
            children: List.generate(whiteNotes.length, (index) {
              final midiNote = whiteNotes[index];
              final isPressed = vm.activePianoNote == midiNote;

              return Expanded(
                child: GestureDetector(
                  onTapDown: (_) => vm.pressPianoNote(midiNote),
                  onTapUp: (_) => vm.releasePianoNote(),
                  onTapCancel: () => vm.releasePianoNote(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isPressed ? const Color(0xFF38BDF8) : Colors.white,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 2)],
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      noteLabels[index],
                      style: TextStyle(
                        color: isPressed ? Colors.white : Colors.black87,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SamplerWaveformPainter extends CustomPainter {
  final int sliceCount;

  _SamplerWaveformPainter({required this.sliceCount});

  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 1.5;

    final middle = size.height / 2;
    const points = 80;
    final step = size.width / points;

    for (int i = 0; i < points; i++) {
      final x = i * step;
      final amplitude = (0.2 + 0.8 * ((i * 11 + 5) % 17) / 17.0) * (middle - 4);
      canvas.drawLine(
        Offset(x, middle - amplitude),
        Offset(x, middle + amplitude),
        wavePaint,
      );
    }

    // Slice Marker Vertical Lines
    final slicePaint = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 1.0;

    for (int i = 1; i < sliceCount; i++) {
      final sliceX = (i / sliceCount) * size.width;
      canvas.drawLine(
        Offset(sliceX, 0),
        Offset(sliceX, size.height),
        slicePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
