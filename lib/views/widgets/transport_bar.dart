import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/editor_view_model.dart';

class TransportBar extends StatelessWidget {
  const TransportBar({super.key});

  String _formatBarBeatTick(double currentBar) {
    int bar = currentBar.floor();
    double remainder = currentBar - bar;
    int beat = (remainder * 4).floor() + 1;
    double beatRemainder = (remainder * 4) - (beat - 1);
    int div = (beatRemainder * 4).floor() + 1;
    int tick = ((beatRemainder * 4 - (div - 1)) * 240).floor();
    return '${bar.toString().padLeft(3, '0')} $beat $div ${tick.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditorViewModel>();

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF232326), // Logic Pro Top Bar Metal Grey
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.8), width: 1.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Left View Toggle Icons (Logic Pro Sidebar Controls)
          _buildIconButton(
            icon: Icons.view_sidebar_outlined,
            tooltip: 'Library (Y)',
            isActive: vm.isLibraryOpen,
            onPressed: vm.toggleLibrary,
          ),
          _buildIconButton(
            icon: Icons.info_outline_rounded,
            tooltip: 'Inspector (I)',
            isActive: vm.isInspectorOpen,
            onPressed: vm.toggleInspector,
          ),
          const SizedBox(width: 4),
          _buildDivider(),
          const SizedBox(width: 4),

          // Logic Bottom Tab Buttons (Sampler, AI Mastering, Flex Pitch, AI Generator)
          _buildTabIconButton(
            icon: Icons.tune_rounded,
            label: 'Smart Controls',
            isActive: vm.isSmartControlsOpen,
            onPressed: () {},
          ),
          _buildTabIconButton(
            icon: Icons.keyboard_rounded,
            label: 'Sampler',
            isActive: vm.activeBottomTab == BottomTab.sampler,
            onPressed: () => vm.setBottomTab(BottomTab.sampler),
          ),
          _buildTabIconButton(
            icon: Icons.graphic_eq_rounded,
            label: 'AI Master',
            isActive: vm.activeBottomTab == BottomTab.mastering,
            onPressed: () => vm.setBottomTab(BottomTab.mastering),
          ),
          _buildTabIconButton(
            icon: Icons.mic_external_on_rounded,
            label: 'Flex Pitch',
            isActive: vm.activeBottomTab == BottomTab.flexPitch,
            onPressed: () => vm.setBottomTab(BottomTab.flexPitch),
          ),
          _buildTabIconButton(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Generator',
            isActive: vm.activeBottomTab == BottomTab.aiGenerator,
            onPressed: () => vm.setBottomTab(BottomTab.aiGenerator),
          ),

          const Spacer(),

          // 2. Center Transport Buttons (Logic Pro Style Rewind/Forward/Stop/Play/Record)
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF19191B),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTransportButton(
                  icon: Icons.skip_previous_rounded,
                  tooltip: 'Return to Start',
                  onPressed: () => vm.updatePlayhead(1.0),
                ),
                _buildTransportButton(
                  icon: Icons.fast_rewind_rounded,
                  tooltip: 'Rewind',
                  onPressed: () => vm.updatePlayhead((vm.currentBar - 4).clamp(1.0, 100.0)),
                ),
                _buildTransportButton(
                  icon: Icons.fast_forward_rounded,
                  tooltip: 'Forward',
                  onPressed: () => vm.updatePlayhead((vm.currentBar + 4).clamp(1.0, 100.0)),
                ),

                const SizedBox(width: 2),

                // Stop & Play
                _buildTransportButton(
                  icon: Icons.stop_rounded,
                  tooltip: 'Stop',
                  onPressed: vm.stop,
                ),
                _buildTransportButton(
                  icon: vm.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  iconColor: vm.isPlaying ? Colors.lightGreenAccent : Colors.white,
                  tooltip: vm.isPlaying ? 'Pause' : 'Play',
                  onPressed: vm.togglePlayPause,
                ),
                _buildTransportButton(
                  icon: Icons.fiber_manual_record_rounded,
                  iconColor: Colors.redAccent,
                  tooltip: 'Record (R)',
                  onPressed: () {},
                ),

                const SizedBox(width: 4),
                _buildDivider(),
                const SizedBox(width: 4),

                // Cycle / Loop Toggle
                _buildTransportButton(
                  icon: Icons.repeat_rounded,
                  iconColor: vm.isLooping ? const Color(0xFF38BDF8) : Colors.grey,
                  tooltip: 'Cycle Mode (C)',
                  onPressed: vm.toggleLooping,
                ),
                // Metronome Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28282C),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '1234',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 3. Signature Logic Pro Digital LCD Display
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220), // Deep Logic Blue LCD Screen
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF1E3A8A), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Bar Beat Division Tick Display
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BAR  BEAT  DIV  TICK',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      _formatBarBeatTick(vm.currentBar),
                      style: const TextStyle(
                        color: Color(0xFF38BDF8), // Cyan LED
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Monospace',
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),
                Container(width: 1, height: 24, color: Colors.white12),
                const SizedBox(width: 12),

                // BPM / Key / Time Signature
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${vm.bpm}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Monospace',
                          ),
                        ),
                        const Text(
                          ' TEMPO',
                          style: TextStyle(color: Colors.white38, fontSize: 8),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          vm.keySignature,
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          vm.timeSignature,
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // 4. Right Tool Settings (Snap, Drag & Zoom)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF19191B),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Text(
                  'Snap: Smart',
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 12, color: Colors.white24),
                const SizedBox(width: 8),
                const Text(
                  'Drag: Overlap',
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Zoom Slider
          Row(
            children: [
              const Icon(Icons.zoom_out, color: Colors.white38, size: 14),
              SizedBox(
                width: 60,
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 2,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 8),
                    activeTrackColor: Color(0xFF38BDF8),
                    inactiveTrackColor: Colors.white12,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: vm.zoomLevel,
                    min: 35.0,
                    max: 160.0,
                    onChanged: vm.setZoomLevel,
                  ),
                ),
              ),
              const Icon(Icons.zoom_in, color: Colors.white38, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 18),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTabIconButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF1E1E22),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive ? const Color(0xFF60A5FA) : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: isActive ? Colors.white : Colors.white60),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransportButton({
    required IconData icon,
    Color iconColor = Colors.white,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: iconColor, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 18,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}
