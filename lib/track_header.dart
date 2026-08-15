import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'editor_view_model (1).dart';
import 'models/track_model.dart';


class TrackHeaderWidget extends StatelessWidget {
  final Track track;

  const TrackHeaderWidget({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditorViewModel>();
    final selected = vm.selectedTrackId == track.id;

    return InkWell(
      onTap: () => vm.selectTrack(track.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF8F8F5),
          border: Border(
            bottom: const BorderSide(color: Color(0xFFE8E8E3)),
            left: BorderSide(
              color: selected ? track.themeColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: track.themeColor.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(track.icon, color: track.themeColor, size: 16),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: const Color(0xFF282826),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    track.type == TrackType.midi
                        ? 'Instrument'
                        : track.type == TrackType.aiGenerated
                            ? 'AI'
                            : 'Audio',
                    style: const TextStyle(fontSize: 9, color: Colors.black38),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_horiz_rounded, size: 18, color: Colors.black38),
              onSelected: (value) {
                if (value == 'mute') vm.toggleMute(track.id);
                if (value == 'solo') vm.toggleSolo(track.id);
                if (value == 'delete') vm.removeTrack(track.id);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'mute',
                  child: Text(track.isMuted ? 'Unmute' : 'Mute'),
                ),
                PopupMenuItem(
                  value: 'solo',
                  child: Text(track.isSoloed ? 'Unsolo' : 'Solo'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Remove Track'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
