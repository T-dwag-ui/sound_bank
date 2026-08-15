import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/editor_view_model.dart';

class InspectorPanel extends StatelessWidget {
  const InspectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditorViewModel>();
    final track = vm.selectedTrack;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E20), // Logic Inspector Charcoal
        border: Border(
          right: BorderSide(color: Colors.black.withValues(alpha: 0.6), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // 1. Top Inspector Header (Region & Track Details)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFF28282B),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.arrow_right, color: Colors.white70, size: 16),
                    Text(
                      'Region: Audio / Flex Pitch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.arrow_right, color: Colors.white70, size: 16),
                    Text(
                      'Track: ${track.name}',
                      style: TextStyle(
                        color: track.themeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.black),

          // 2. Dual Channel Strips (Track Channel Strip + Stereo Out Master)
          Expanded(
            child: Row(
              children: [
                // Track Channel Strip (Left)
                Expanded(
                  child: _buildChannelStrip(
                    context: context,
                    title: track.name,
                    icon: track.icon,
                    accentColor: track.themeColor,
                    isMaster: false,
                    volume: track.volume,
                    pan: track.pan,
                    plugins: track.plugins,
                    peakDb: -6.5,
                    isMuted: track.isMuted,
                    isSoloed: track.isSoloed,
                    isRecordArmed: track.isRecordArmed,
                    onVolumeChanged: (val) => vm.setTrackVolume(track.id, val),
                    onPanChanged: (val) => vm.setTrackPan(track.id, val),
                    onMuteToggled: () => vm.toggleMute(track.id),
                    onSoloToggled: () => vm.toggleSolo(track.id),
                    onRecordToggled: () => vm.toggleRecordArm(track.id),
                  ),
                ),

                Container(width: 1, color: Colors.black.withValues(alpha: 0.5)),

                // Stereo Out / Master Channel Strip (Right)
                Expanded(
                  child: _buildChannelStrip(
                    context: context,
                    title: 'Stereo Out',
                    icon: Icons.speaker_group_rounded,
                    accentColor: const Color(0xFF38BDF8),
                    isMaster: true,
                    volume: vm.masterVolume,
                    pan: 0.0,
                    plugins: const ['Linear EQ', 'Exciter', 'AdLimit'],
                    peakDb: -0.5,
                    isMuted: false,
                    isSoloed: false,
                    isRecordArmed: false,
                    onVolumeChanged: vm.setMasterVolume,
                    onPanChanged: (_) {},
                    onMuteToggled: () {},
                    onSoloToggled: () {},
                    onRecordToggled: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelStrip({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color accentColor,
    required bool isMaster,
    required double volume,
    required double pan,
    required List<String> plugins,
    required double peakDb,
    required bool isMuted,
    required bool isSoloed,
    required bool isRecordArmed,
    required ValueChanged<double> onVolumeChanged,
    required ValueChanged<double> onPanChanged,
    required VoidCallback onMuteToggled,
    required VoidCallback onSoloToggled,
    required VoidCallback onRecordToggled,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      color: isMaster ? const Color(0xFF19191C) : const Color(0xFF222225),
      child: Column(
        children: [
          // EQ Thumbnail Graphic (Logic Channel EQ Curve display)
          Container(
            height: 42,
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: accentColor.withValues(alpha: 0.4)),
            ),
            child: CustomPaint(
              painter: _EqThumbnailPainter(color: accentColor),
            ),
          ),

          const SizedBox(height: 6),

          // Input Slot
          Container(
            height: 20,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D32),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              isMaster ? 'Input: Bus 1' : 'Input 1',
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ),

          const SizedBox(height: 4),

          // Plugins Rack Inserts
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF161618),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final pluginName = (index < plugins.length) ? plugins[index] : '--- Setting ---';
                  final hasPlugin = index < plugins.length;

                  return Container(
                    height: 18,
                    margin: const EdgeInsets.only(bottom: 3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasPlugin
                          ? const Color(0xFF1E3A8A).withValues(alpha: 0.6)
                          : const Color(0xFF222226),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: hasPlugin ? const Color(0xFF3B82F6) : Colors.white10,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      pluginName,
                      style: TextStyle(
                        color: hasPlugin ? Colors.cyanAccent : Colors.grey,
                        fontSize: 9,
                        fontWeight: hasPlugin ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Automation Read Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Text(
              'Read',
              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 6),

          // Pan Knob Control
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Pan', style: TextStyle(color: Colors.white54, fontSize: 9)),
              const SizedBox(width: 4),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2B2B30),
                  border: Border.all(color: Colors.white30),
                ),
                child: Center(
                  child: Container(
                    width: 2,
                    height: 8,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Channel Fader & Peak Meter Section
          SizedBox(
            height: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fader Slider
                RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 6,
                      activeTrackColor: accentColor,
                      inactiveTrackColor: const Color(0xFF1E1E22),
                      thumbColor: Colors.white,
                      thumbShape: const RectangularSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: volume,
                      onChanged: onVolumeChanged,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Stereo VU Meter Bars
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 12,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: (volume * 95),
                              width: 8,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.green, Colors.yellow, Colors.red],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${peakDb}dB',
                      style: TextStyle(
                        color: peakDb > 0 ? Colors.red : Colors.greenAccent,
                        fontSize: 8,
                        fontFamily: 'Monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Mute, Solo & Record Arm Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!isMaster)
                _buildSmallButton(
                  label: 'R',
                  isActive: isRecordArmed,
                  activeColor: Colors.redAccent,
                  onTap: onRecordToggled,
                ),
              _buildSmallButton(
                label: 'M',
                isActive: isMuted,
                activeColor: const Color(0xFF3B82F6),
                onTap: onMuteToggled,
              ),
              _buildSmallButton(
                label: 'S',
                isActive: isSoloed,
                activeColor: const Color(0xFFF59E0B),
                onTap: onSoloToggled,
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Track Title Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: accentColor, width: 0.8),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFF2C2C32),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
      ),
    );
  }
}

class RectangularSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;

  const RectangularSliderThumbShape({required this.enabledThumbRadius});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(enabledThumbRadius * 2, enabledThumbRadius * 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rect = Rect.fromCenter(center: center, width: 14, height: 10);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }
}

class _EqThumbnailPainter extends CustomPainter {
  final Color color;

  _EqThumbnailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.8,
      size.width * 0.75,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height * 0.4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
