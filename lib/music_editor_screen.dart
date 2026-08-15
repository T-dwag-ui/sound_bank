import 'package:flutter/material.dart';
import 'package:music_editor_app/models/track_model.dart';
import 'package:provider/provider.dart';
import 'editor_view_model (1).dart';
import 'new_song_screen.dart';
import 'timeline_view.dart';
import 'track_header.dart';
import 'views/widgets/ai_generator_view.dart';
import 'views/widgets/ai_mastering_view.dart';
import 'views/widgets/audio_sampler_view.dart';
import 'views/widgets/flex_pitch_view.dart';


class MusicEditorScreen extends StatelessWidget {
  final int initialBpm;
  final String initialKey;
  final String initialTimeSignature;
  final List<Track>? initialTracks;
  final String songTitle;

  const MusicEditorScreen({
    super.key,
    this.initialBpm = 92,
    this.initialKey = 'C maj',
    this.initialTimeSignature = '4/4',
    this.initialTracks,
    this.songTitle = 'Untitled Song',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditorViewModel(
        bpm: initialBpm,
        keySignature: initialKey,
        timeSignature: initialTimeSignature,
        initialTracks: initialTracks,
      ),
      child: _MusicEditorBody(songTitle: songTitle),
    );
  }
}

class _MusicEditorBody extends StatelessWidget {
  final String songTitle;

  const _MusicEditorBody({required this.songTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F1),
      body: SafeArea(
        child: Consumer<EditorViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                _TopBar(songTitle: songTitle),
                _Transport(vm: vm),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _EditorCanvas(vm: vm)),
                    ],
                  ),
                ),
                if (vm.activeBottomTab != BottomTab.none)
                  _buildBottomWorkbench(vm.activeBottomTab),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomWorkbench(BottomTab tab) {
    switch (tab) {
      case BottomTab.sampler:
        return const AudioSamplerView();
      case BottomTab.mastering:
        return const AiMasteringView();
      case BottomTab.flexPitch:
        return const FlexPitchView();
      case BottomTab.aiGenerator:
        return const AiGeneratorView();
      case BottomTab.none:
        return const SizedBox.shrink();
    }
  }
}

class _TopBar extends StatelessWidget {
  final String songTitle;

  const _TopBar({required this.songTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFDFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE6E6E1))),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to song setup',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const NewSongScreen()),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.graphic_eq_rounded, size: 20),
          const SizedBox(width: 9),
          Text(songTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const Spacer(),
          _ToolbarButton(
            icon: Icons.auto_awesome_rounded,
            label: 'AI',
            onTap: () => context.read<EditorViewModel>().setBottomTab(BottomTab.aiGenerator),
          ),
          const SizedBox(width: 5),
          _ToolbarButton(
            icon: Icons.tune_rounded,
            label: 'Mix',
            onTap: () => context.read<EditorViewModel>().toggleMixer(),
          ),
          const SizedBox(width: 5),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (value) {
              final vm = context.read<EditorViewModel>();
              switch (value) {
                case 'master':
                  vm.setBottomTab(BottomTab.mastering);
                  break;
                case 'pitch':
                  vm.setBottomTab(BottomTab.flexPitch);
                  break;
                case 'sampler':
                  vm.setBottomTab(BottomTab.sampler);
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'master', child: Text('AI Mastering')),
              PopupMenuItem(value: 'pitch', child: Text('Pitch Editing')),
              PopupMenuItem(value: 'sampler', child: Text('Sampler')),
            ],
            child: const Padding(
              padding: EdgeInsets.all(9),
              child: Icon(Icons.more_horiz_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor: const Color(0xFF262626),
        side: const BorderSide(color: Color(0xFFE1E1DC)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _Transport extends StatelessWidget {
  final EditorViewModel vm;

  const _Transport({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFDFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE6E6E1))),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Stop',
            onPressed: vm.stop,
            icon: const Icon(Icons.stop_rounded),
          ),
          IconButton(
            tooltip: vm.isPlaying ? 'Pause' : 'Play',
            onPressed: vm.togglePlayPause,
            icon: Icon(vm.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded, size: 36),
          ),
          IconButton(
            tooltip: 'Loop',
            onPressed: vm.toggleLooping,
            icon: Icon(Icons.repeat_rounded, color: vm.isLooping ? const Color(0xFF262626) : Colors.black26),
          ),
          const SizedBox(width: 14),
          _TransportValue(label: 'BPM', value: '${vm.bpm}'),
          _TransportValue(label: 'KEY', value: vm.keySignature),
          _TransportValue(label: 'TIME', value: vm.timeSignature),
          const Spacer(),
          Text(
            'BAR ${vm.currentBar.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _TransportValue extends StatelessWidget {
  final String label;
  final String value;

  const _TransportValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, color: Colors.black38, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _EditorCanvas extends StatelessWidget {
  final EditorViewModel vm;

  const _EditorCanvas({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.tracks.isEmpty) {
      return _EmptyProjectState(
        onAdd: () => _showAddTrack(context),
        onAi: () => vm.setBottomTab(BottomTab.aiGenerator),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 214,
                child: Column(
                  children: [
                    const _TrackColumnHeader(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: vm.tracks.length,
                        itemBuilder: (_, index) => TrackHeaderWidget(track: vm.tracks[index]),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: TimelineViewWidget(
                  tracks: vm.tracks,
                  totalBars: vm.totalBars,
                  currentBar: vm.currentBar,
                  zoomLevel: vm.zoomLevel,
                ),
              ),
            ],
          ),
        ),
        _BottomActions(
          onAddTrack: () => _showAddTrack(context),
          onAi: () => vm.setBottomTab(BottomTab.aiGenerator),
        ),
      ],
    );
  }

  Future<void> _showAddTrack(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFDFDFC),
      showDragHandle: true,
      builder: (_) => _AddTrackSheet(vm: vm),
    );
  }
}

class _TrackColumnHeader extends StatelessWidget {
  const _TrackColumnHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      color: const Color(0xFFF8F8F5),
      child: const Text(
        'TRACKS',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: Colors.black45),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final VoidCallback onAddTrack;
  final VoidCallback onAi;

  const _BottomActions({required this.onAddTrack, required this.onAi});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFDFC),
        border: Border(top: BorderSide(color: Color(0xFFE6E6E1))),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: onAddTrack,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Track'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF262626),
              side: const BorderSide(color: Color(0xFFDCDCD6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onAi,
            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
            label: const Text('Create with AI'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF262626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
          ),
          const Spacer(),
          Text(
            'Drag, record, or generate. Keep it simple.',
            style: TextStyle(fontSize: 11, color: Colors.black.withValues(alpha: .38)),
          ),
        ],
      ),
    );
  }
}

class _EmptyProjectState extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onAi;

  const _EmptyProjectState({required this.onAdd, required this.onAi});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: .07)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFF1F1ED),
              child: Icon(Icons.music_note_rounded, color: Color(0xFF262626)),
            ),
            const SizedBox(height: 18),
            const Text('Your song is empty.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Add one thing at a time. You never need to start with a wall of tracks.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withValues(alpha: .52), height: 1.4),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_rounded), label: const Text('Add Track')),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onAi,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('AI'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF262626)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTrackSheet extends StatelessWidget {
  final EditorViewModel vm;

  const _AddTrackSheet({required this.vm});

  void _add(BuildContext context, String name, TrackType type, IconData icon, Color color) {
    vm.addTrack(name: name, type: type, icon: icon, themeColor: color);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Voice', TrackType.audio, Icons.mic_rounded, const Color(0xFF7EA7E8)),
      ('Instrument', TrackType.midi, Icons.piano_rounded, const Color(0xFF5EB8A5)),
      ('Drums', TrackType.audio, Icons.grid_view_rounded, const Color(0xFFE5A93D)),
      ('Guitar', TrackType.audio, Icons.music_note_rounded, const Color(0xFFD18B5B)),
      ('Bass', TrackType.audio, Icons.graphic_eq_rounded, const Color(0xFFB57EDC)),
      ('Audio', TrackType.audio, Icons.audiotrack_rounded, const Color(0xFF7C8DE8)),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Track', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text('Choose what you want to add. You can pick the sound next.', style: TextStyle(color: Colors.black.withValues(alpha: .5))),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 82,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (_, index) {
                final item = items[index];
                return InkWell(
                  onTap: () => _add(context, item.$1, item.$2, item.$3, item.$4),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(item.$3, size: 19),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
