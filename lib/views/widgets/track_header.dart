import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/track_model.dart';
import '../../view_models/editor_view_model.dart';

class TrackHeaderWidget extends StatelessWidget {
  final Track track;

  const TrackHeaderWidget({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditorViewModel>();
    final isSelected = vm.selectedTrackId == track.id;

    return GestureDetector(
      onTap: () => vm.selectTrack(track.id),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E2E32) : const Color(0xFF212124),
          border: Border(
            bottom: BorderSide(color: Colors.black.withValues(alpha: 0.8), width: 1.0),
            left: BorderSide(
              color: isSelected ? Colors.cyanAccent : track.themeColor,
              width: isSelected ? 4.5 : 3.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Row 1: Track #, Icon, Name, Record & Input Monitor
            Row(
              children: [
                Text(
                  '${track.trackNumber}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Monospace',
                  ),
                ),
                const SizedBox(width: 6),
                Icon(track.icon, color: track.themeColor, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    track.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                // Input Monitoring [I] Button
                _buildSmallControlPill(
                  label: 'I',
                  isActive: track.isInputMonitored,
                  activeColor: Colors.orangeAccent,
                  onTap: () => vm.toggleInputMonitoring(track.id),
                ),
                const SizedBox(width: 3),
                // Record Arm [R] Button
                _buildSmallControlPill(
                  label: 'R',
                  isActive: track.isRecordArmed,
                  activeColor: Colors.redAccent,
                  onTap: () => vm.toggleRecordArm(track.id),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Row 2: Mute [M], Solo [S], Volume Slider
            Row(
              children: [
                // Mute [M]
                _buildSmallControlPill(
                  label: 'M',
                  isActive: track.isMuted,
                  activeColor: const Color(0xFF3B82F6),
                  onTap: () => vm.toggleMute(track.id),
                ),
                const SizedBox(width: 3),
                // Solo [S]
                _buildSmallControlPill(
                  label: 'S',
                  isActive: track.isSoloed,
                  activeColor: const Color(0xFFF59E0B),
                  onTap: () => vm.toggleSolo(track.id),
                ),
                const SizedBox(width: 8),

                // Track Volume Slider
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2.5,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                      activeTrackColor: track.themeColor,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: track.volume,
                      onChanged: (val) => vm.setTrackVolume(track.id, val),
                    ),
                  ),
                ),

                Text(
                  '${(track.volume * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontFamily: 'Monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallControlPill({
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 17,
        height: 17,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFF161618),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? (label == 'S' ? Colors.black : Colors.white) : Colors.white38,
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
      ),
    );
  }
}
