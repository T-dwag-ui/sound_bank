import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/track_model.dart';
import '../view_models/editor_view_model.dart';
import './music_editor_screen.dart';

enum SongStartMode { blank, template, ai }

class SongTemplate {
  final String id;
  final String genre;
  final String name;
  final String description;
  final int bpm;
  final String key;
  final String timeSignature;
  final IconData icon;
  final List<_TemplateTrack> tracks;

  const SongTemplate({
    required this.id,
    required this.genre,
    required this.name,
    required this.description,
    required this.bpm,
    required this.key,
    required this.timeSignature,
    required this.icon,
    required this.tracks,
  });
}

class _TemplateTrack {
  final String name;
  final TrackType type;
  final IconData icon;
  final Color color;
  final List<String> plugins;

  const _TemplateTrack({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  }) : plugins = const [];
}

const _templates = <SongTemplate>[
  SongTemplate(
    id: 'rnb_late_night',
    genre: 'R&B',
    name: 'Late Night',
    description: 'Warm keys, deep bass and a pocketed groove.',
    bpm: 92,
    key: 'C min',
    timeSignature: '4/4',
    icon: Icons.nightlight_round,
    tracks: [
      _TemplateTrack(name: 'Drums', type: TrackType.audio, icon: Icons.grid_view_rounded, color: Color(0xFFE5A93D)),
      _TemplateTrack(name: 'Bass', type: TrackType.audio, icon: Icons.graphic_eq_rounded, color: Color(0xFFB57EDC)),
      _TemplateTrack(name: 'Keys', type: TrackType.midi, icon: Icons.piano_rounded, color: Color(0xFF5EB8A5)),
      _TemplateTrack(name: 'Lead Vocal', type: TrackType.audio, icon: Icons.mic_rounded, color: Color(0xFF7EA7E8)),
    ],
  ),
  SongTemplate(
    id: 'hiphop_modern',
    genre: 'Hip-Hop',
    name: 'Modern',
    description: 'Punchy drums, 808 bass and space for a vocal.',
    bpm: 88,
    key: 'F min',
    timeSignature: '4/4',
    icon: Icons.local_fire_department_rounded,
    tracks: [
      _TemplateTrack(name: 'Drums', type: TrackType.audio, icon: Icons.grid_view_rounded, color: Color(0xFFE5A93D)),
      _TemplateTrack(name: '808', type: TrackType.audio, icon: Icons.graphic_eq_rounded, color: Color(0xFFB57EDC)),
      _TemplateTrack(name: 'Keys', type: TrackType.midi, icon: Icons.piano_rounded, color: Color(0xFF5EB8A5)),
      _TemplateTrack(name: 'Vocal', type: TrackType.audio, icon: Icons.mic_rounded, color: Color(0xFF7EA7E8)),
    ],
  ),
  SongTemplate(
    id: 'afrobeats_warm',
    genre: 'Afrobeats',
    name: 'Warm Groove',
    description: 'Percussion-led rhythm with a smooth melodic pocket.',
    bpm: 102,
    key: 'A min',
    timeSignature: '4/4',
    icon: Icons.wb_sunny_rounded,
    tracks: [
      _TemplateTrack(name: 'Drums', type: TrackType.audio, icon: Icons.grid_view_rounded, color: Color(0xFFE5A93D)),
      _TemplateTrack(name: 'Percussion', type: TrackType.audio, icon: Icons.album_rounded, color: Color(0xFFF08A5D)),
      _TemplateTrack(name: 'Bass', type: TrackType.audio, icon: Icons.graphic_eq_rounded, color: Color(0xFFB57EDC)),
      _TemplateTrack(name: 'Keys', type: TrackType.midi, icon: Icons.piano_rounded, color: Color(0xFF5EB8A5)),
      _TemplateTrack(name: 'Vocal', type: TrackType.audio, icon: Icons.mic_rounded, color: Color(0xFF7EA7E8)),
    ],
  ),
  SongTemplate(
    id: 'pop_radio',
    genre: 'Pop',
    name: 'Radio',
    description: 'A clean four-on-the-floor foundation ready for a hook.',
    bpm: 118,
    key: 'G maj',
    timeSignature: '4/4',
    icon: Icons.auto_awesome_rounded,
    tracks: [
      _TemplateTrack(name: 'Drums', type: TrackType.audio, icon: Icons.grid_view_rounded, color: Color(0xFFE5A93D)),
      _TemplateTrack(name: 'Bass', type: TrackType.audio, icon: Icons.graphic_eq_rounded, color: Color(0xFFB57EDC)),
      _TemplateTrack(name: 'Piano', type: TrackType.midi, icon: Icons.piano_rounded, color: Color(0xFF5EB8A5)),
      _TemplateTrack(name: 'Synth', type: TrackType.midi, icon: Icons.waves_rounded, color: Color(0xFF6FA8DC)),
      _TemplateTrack(name: 'Vocal', type: TrackType.audio, icon: Icons.mic_rounded, color: Color(0xFF7EA7E8)),
    ],
  ),
  SongTemplate(
    id: 'indie_band',
    genre: 'Indie',
    name: 'Small Room',
    description: 'Drums, bass and guitar with plenty of breathing room.',
    bpm: 108,
    key: 'E maj',
    timeSignature: '4/4',
    icon: Icons.music_note_rounded,
    tracks: [
      _TemplateTrack(name: 'Drums', type: TrackType.audio, icon: Icons.grid_view_rounded, color: Color(0xFFE5A93D)),
      _TemplateTrack(name: 'Bass', type: TrackType.audio, icon: Icons.graphic_eq_rounded, color: Color(0xFFB57EDC)),
      _TemplateTrack(name: 'Guitar', type: TrackType.audio, icon: Icons.music_note_rounded, color: Color(0xFFD18B5B)),
      _TemplateTrack(name: 'Vocal', type: TrackType.audio, icon: Icons.mic_rounded, color: Color(0xFF7EA7E8)),
    ],
  ),
];

class NewSongScreen extends StatefulWidget {
  const NewSongScreen({super.key});

  @override
  State<NewSongScreen> createState() => _NewSongScreenState();
}

class _NewSongScreenState extends State<NewSongScreen> {
  String _genre = 'R&B';
  SongStartMode _mode = SongStartMode.template;
  SongTemplate? _selected;

  @override
  void initState() {
    super.initState();
    _selected = _templates.first;
  }

  List<SongTemplate> get _visibleTemplates =>
      _templates.where((template) => template.genre == _genre).toList();

  void _continue() {
    final template = _selected;
    if (_mode == SongStartMode.ai) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MusicEditorScreen()),
      );
      return;
    }

    final tracks = <Track>[];
    if (_mode == SongStartMode.template && template != null) {
      for (var i = 0; i < template.tracks.length; i++) {
        final t = template.tracks[i];
        tracks.add(
          Track(
            id: '${template.id}_$i',
            trackNumber: i + 1,
            name: t.name,
            type: t.type,
            icon: t.icon,
            themeColor: t.color,
            plugins: t.plugins,
            regions: [
              AudioRegion(
                id: '${template.id}_region_$i',
                name: t.name,
                startBar: 1.0,
                durationBars: 8.0,
                color: t.color,
              ),
            ],
          ),
        );
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MusicEditorScreen(
          initialBpm: template?.bpm ?? 92,
          initialKey: template?.key ?? 'C maj',
          initialTimeSignature: template?.timeSignature ?? '4/4',
          initialTracks: tracks,
          songTitle: template?.name ?? 'Untitled Song',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = _visibleTemplates;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F4),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: SingleChildScrollView(
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.graphic_eq_rounded, size: 28, color: Color(0xFF262626)),
                          const SizedBox(width: 10),
                          const Text(
                            'AURA',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 2),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const MusicEditorScreen()),
                              );
                            },
                            child: const Text('Open empty studio'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 42),
                      const Text(
                        'Let’s make something.',
                        style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: -1.2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start simple. You can always add more later.',
                        style: TextStyle(fontSize: 16, color: Colors.black.withValues(alpha: .55)),
                      ),
                      const SizedBox(height: 30),
                      const Text('1  •  Pick a vibe', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['R&B', 'Hip-Hop', 'Afrobeats', 'Pop', 'Indie'].map((genre) {
                          final active = genre == _genre;
                          return ChoiceChip(
                            label: Text(genre),
                            selected: active,
                            onSelected: (_) {
                              setState(() {
                                _genre = genre;
                                _selected = _templates.firstWhere(
                                  (t) => t.genre == genre,
                                  orElse: () => _templates.first,
                                );
                              });
                            },
                            selectedColor: const Color(0xFF262626),
                            labelStyle: TextStyle(color: active ? Colors.white : Colors.black87),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.black.withValues(alpha: .08)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),
                      const Text('2  •  Choose your starting point', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StartCard(
                            icon: Icons.auto_awesome_rounded,
                            title: 'Create with AI',
                            subtitle: 'Describe the song and let AURA build the starting arrangement.',
                            selected: _mode == SongStartMode.ai,
                            onTap: () => setState(() => _mode = SongStartMode.ai),
                          ),
                          const SizedBox(width: 12),
                          _StartCard(
                            icon: Icons.layers_rounded,
                            title: 'Use a template',
                            subtitle: 'A clean set of tracks, sounds and tempo — ready to play.',
                            selected: _mode == SongStartMode.template,
                            onTap: () => setState(() => _mode = SongStartMode.template),
                          ),
                          const SizedBox(width: 12),
                          _StartCard(
                            icon: Icons.add_rounded,
                            title: 'Start empty',
                            subtitle: 'Nothing on the timeline. Build it exactly how you want.',
                            selected: _mode == SongStartMode.blank,
                            onTap: () => setState(() => _mode = SongStartMode.blank),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      if (_mode == SongStartMode.template) ...[
                        const Text('3  •  Pick a template', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Expanded(
                          // flex: 1,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: templates.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (_, index) {
                              final template = templates[index];
                              final selected = _selected?.id == template.id;
                              return _TemplateCard(
                                template: template,
                                selected: selected,
                                onTap: () => setState(() => _selected = template),
                              );
                            },
                          ),
                        ),
                      ] else if (_mode == SongStartMode.ai) ...[
                        Expanded(child: _AiStartCard()),
                      ] else ...[
                        Expanded(
                          child: Center(
                            child: Text(
                              'You’ll get a clean timeline with no tracks.',
                              style: TextStyle(color: Colors.black.withValues(alpha: .55)),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _continue,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            child: Text('Open Studio'),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF262626),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _StartCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          height: 132,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF262626) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? const Color(0xFF262626) : Colors.black.withValues(alpha: .08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: selected ? Colors.white : const Color(0xFF262626)),
              const Spacer(),
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.white : Colors.black87)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: selected ? Colors.white70 : Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final SongTemplate template;
  final bool selected;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 255,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF262626) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFF262626) : Colors.black.withValues(alpha: .08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: selected ? Colors.white12 : const Color(0xFFF0F0EC),
              child: Icon(template.icon, color: selected ? Colors.white : const Color(0xFF262626)),
            ),
            const SizedBox(height: 18),
            Text(template.name, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: selected ? Colors.white : Colors.black87)),
            const SizedBox(height: 5),
            Text(
              template.description,
              maxLines: 2,
              style: TextStyle(fontSize: 12, height: 1.35, color: selected ? Colors.white70 : Colors.black54),
            ),
            const Spacer(),
            Text(
              '${template.bpm} BPM  •  ${template.key}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: template.tracks.map((track) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white10 : const Color(0xFFF3F3EF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    track.name,
                    style: TextStyle(fontSize: 9, color: selected ? Colors.white70 : Colors.black54),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiStartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 28),
          const SizedBox(height: 14),
          const Text('Tell AURA what you hear in your head.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'The AI generator remains available inside the studio too. This entry point is intentionally simple: describe the idea, then edit the result as tracks.',
            style: TextStyle(color: Colors.black.withValues(alpha: .55), height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. dreamy late-night R&B, slow groove, warm Rhodes, intimate vocal...',
              filled: true,
              fillColor: const Color(0xFFF5F5F1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
