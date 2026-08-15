import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track_model.dart';
import 'music_theory.dart';

class DawState extends ChangeNotifier {
  final List<Track> tracks = [];
  double playhead = 1;
  double zoom = 64;
  int bpm = 92;
  String key = 'C min';
  String timeSignature = '4/4';
  bool playing = false;
  bool loop = true;
  String? selectedTrackId;
  String? selectedRegionId;
  Timer? _timer;

  DawState() { createProject('Late Night', 92, 'C min'); }

  void createProject(String name, int tempo, String projectKey) {
    tracks
      ..clear()
      ..addAll(_templateTracks());
    bpm = tempo;
    key = projectKey;
    playhead = 1;
    selectedTrackId = tracks.first.id;
    selectedRegionId = tracks.first.regions.first.id;
    notifyListeners();
  }

  List<Track> _templateTracks() => [
    Track(id: 'drums', trackNumber: 1, name: 'Drums', type: TrackType.audio, icon: Icons.grid_view_rounded, themeColor: const Color(0xFFE39A32), regions: [AudioRegion(id: 'drums_r', name: 'Main Groove', startBar: 1, durationBars: 8, color: const Color(0xFFE39A32))]),
    Track(id: 'bass', trackNumber: 2, name: 'Bass', type: TrackType.audio, icon: Icons.graphic_eq_rounded, themeColor: const Color(0xFF9C72C9), regions: [AudioRegion(id: 'bass_r', name: 'Bassline', startBar: 1, durationBars: 8, color: const Color(0xFF9C72C9))]),
    Track(id: 'keys', trackNumber: 3, name: 'Keys', type: TrackType.midi, icon: Icons.piano_rounded, themeColor: const Color(0xFF4EAD96), regions: [AudioRegion(id: 'keys_r', name: 'Chord Progression', startBar: 1, durationBars: 8, color: const Color(0xFF4EAD96), midiNotes: [MidiNote(pitch: 60, startBar: 0, durationBars: 2), MidiNote(pitch: 64, startBar: 0, durationBars: 2), MidiNote(pitch: 67, startBar: 0, durationBars: 2), MidiNote(pitch: 65, startBar: 2, durationBars: 2), MidiNote(pitch: 69, startBar: 2, durationBars: 2), MidiNote(pitch: 72, startBar: 2, durationBars: 2), MidiNote(pitch: 62, startBar: 4, durationBars: 2), MidiNote(pitch: 65, startBar: 4, durationBars: 2), MidiNote(pitch: 69, startBar: 4, durationBars: 2)] )]),
    Track(id: 'vocal', trackNumber: 4, name: 'Lead Vocal', type: TrackType.audio, icon: Icons.mic_rounded, themeColor: const Color(0xFF6F91D0), regions: [AudioRegion(id: 'vocal_r', name: 'Verse + Hook', startBar: 9, durationBars: 8, color: const Color(0xFF6F91D0))]),
  ];

  void togglePlay() {
    playing = !playing;
    _timer?.cancel();
    if (playing) {
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        final barsPerSecond = bpm / 60 / 4;
        playhead += barsPerSecond * .03;
        if (playhead > 65) {
          if (loop) playhead = 1;
          else { playing = false; playhead = 1; _timer?.cancel(); }
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void stop() { playing = false; _timer?.cancel(); playhead = 1; notifyListeners(); }
  void select(Track track, AudioRegion region) { selectedTrackId = track.id; selectedRegionId = region.id; notifyListeners(); }
  void setPlayhead(double bar) { playhead = bar.clamp(1, 65); notifyListeners(); }
  void setBpm(int value) { bpm = value.clamp(40, 240); notifyListeners(); }
  void toggleMute(Track t) { t.isMuted = !t.isMuted; notifyListeners(); }
  void toggleSolo(Track t) { t.isSoloed = !t.isSoloed; notifyListeners(); }
  void setVolume(Track t, double value) { t.volume = value; notifyListeners(); }
  void setPan(Track t, double value) { t.pan = value; notifyListeners(); }
  void rename(Track t, String name) { t.name = name.trim().isEmpty ? t.name : name.trim(); notifyListeners(); }

  void addTrack(TrackType type) {
    final i = tracks.length + 1;
    final id = 'track_$i';
    final color = [const Color(0xFF5A9CC8), const Color(0xFFB779B8), const Color(0xFFCB875C), const Color(0xFF5DAE82)][i % 4];
    final track = Track(id: id, trackNumber: i, name: type == TrackType.midi ? 'Instrument $i' : 'Audio $i', type: type, icon: type == TrackType.midi ? Icons.piano_rounded : Icons.audiotrack_rounded, themeColor: color, regions: [AudioRegion(id: '${id}_region', name: 'New Region', startBar: 1, durationBars: 4, color: color)]);
    tracks.add(track);
    selectedTrackId = id; selectedRegionId = track.regions.first.id;
    notifyListeners();
  }

  void moveRegion(Track track, AudioRegion region, double startBar) {
    region.startBar = _snap(startBar.clamp(1, 64 - region.durationBars));
    select(track, region);
  }

  void resizeRegion(AudioRegion region, double duration) {
    region.durationBars = _snap(duration.clamp(1, 32));
    notifyListeners();
  }

  double _snap(double bar) => (bar * 4).round() / 4;
  @override void dispose() { _timer?.cancel(); super.dispose(); }
}

class DawApp extends StatelessWidget {
  const DawApp({super.key});
  @override Widget build(BuildContext context) => ChangeNotifierProvider(create: (_) => DawState(), child: MaterialApp(debugShowCheckedModeBanner: false, title: 'Sound Bank', theme: ThemeData(useMaterial3: true, fontFamily: 'Inter', colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF202020), brightness: Brightness.light)), home: const DawEditor()));
}

class DawEditor extends StatelessWidget {
  const DawEditor({super.key});
  @override Widget build(BuildContext context) {
    final state = context.watch<DawState>();
    return Scaffold(backgroundColor: const Color(0xFFF4F4F1), body: SafeArea(child: Column(children: [
      _Header(state: state),
      _Transport(state: state),
      Expanded(child: Row(children: [
        SizedBox(width: 230, child: _TrackList(state: state)),
        Expanded(child: _Timeline(state: state)),
      ])),
      _BottomBar(state: state),
    ])));
  }
}

class _Header extends StatelessWidget {
  final DawState state; const _Header({required this.state});
  @override Widget build(BuildContext context) => Container(height: 58, padding: const EdgeInsets.symmetric(horizontal: 18), decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE1E1DC))),), child: Row(children: [const Icon(Icons.graphic_eq_rounded), const SizedBox(width: 10), const Text('SOUND BANK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)), const SizedBox(width: 18), const Text('Late Night', style: TextStyle(color: Colors.black54)), const Spacer(), IconButton(tooltip: 'Zoom out', onPressed: () { state.zoom = (state.zoom - 8).clamp(36, 120); state.notifyListeners(); }, icon: const Icon(Icons.zoom_out)), Text('${state.zoom.round()} px/bar', style: const TextStyle(fontSize: 11)), IconButton(tooltip: 'Zoom in', onPressed: () { state.zoom = (state.zoom + 8).clamp(36, 120); state.notifyListeners(); }, icon: const Icon(Icons.zoom_in)),]);
}

class _Transport extends StatelessWidget {
  final DawState state; const _Transport({required this.state});
  @override Widget build(BuildContext context) => Container(height: 70, padding: const EdgeInsets.symmetric(horizontal: 18), decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE1E1DC))),), child: Row(children: [IconButton(onPressed: state.stop, icon: const Icon(Icons.stop_rounded)), IconButton(onPressed: state.togglePlay, icon: Icon(state.playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded, size: 38)), IconButton(onPressed: () { state.loop = !state.loop; state.notifyListeners(); }, icon: Icon(Icons.repeat_rounded, color: state.loop ? Colors.black : Colors.black26)), const SizedBox(width: 20), _Number('BPM', '${state.bpm}', () => _editBpm(context)), _Number('KEY', state.key, () {}), _Number('TIME', state.timeSignature, () {}), const Spacer(), Text('BAR ${state.playhead.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])), const SizedBox(width: 16)]));
  void _editBpm(BuildContext context) { showDialog(context: context, builder: (_) { final c = TextEditingController(text: '${state.bpm}'); return AlertDialog(title: const Text('Tempo'), content: TextField(controller: c, keyboardType: TextInputType.number, autofocus: true, decoration: const InputDecoration(suffixText: 'BPM')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { state.setBpm(int.tryParse(c.text) ?? state.bpm); Navigator.pop(context); }, child: const Text('Set'))]); }); }
}

class _Number extends StatelessWidget { final String label, value; final VoidCallback onTap; const _Number(this.label, this.value, this.onTap); @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: const TextStyle(fontSize: 8, color: Colors.black38, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))]))); }

class _TrackList extends StatelessWidget {
  final DawState state; const _TrackList({required this.state});
  @override Widget build(BuildContext context) => Container(decoration: const BoxDecoration(color: Color(0xFFF9F9F6), border: Border(right: BorderSide(color: Color(0xFFE1E1DC)))), child: Column(children: [Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.centerLeft, child: const Text('TRACKS', style: TextStyle(fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w800, color: Colors.black45))), Expanded(child: ListView.builder(itemCount: state.tracks.length, itemBuilder: (_, i) => _TrackHeader(track: state.tracks[i], state: state))), Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _add(context), icon: const Icon(Icons.add), label: const Text('Add Track'))))]));
  void _add(BuildContext context) { showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Add Track', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 14), ListTile(leading: const Icon(Icons.piano), title: const Text('Software Instrument / MIDI'), onTap: () { state.addTrack(TrackType.midi); Navigator.pop(context); }), ListTile(leading: const Icon(Icons.mic), title: const Text('Audio'), onTap: () { state.addTrack(TrackType.audio); Navigator.pop(context); })]))); }
}

class _TrackHeader extends StatelessWidget {
  final Track track; final DawState state; const _TrackHeader({required this.track, required this.state});
  @override Widget build(BuildContext context) { final selected = state.selectedTrackId == track.id; return Container(height: 72, padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: selected ? track.themeColor.withOpacity(.08) : null, border: const Border(bottom: BorderSide(color: Color(0xFFE4E4DF)))), child: Column(children: [Row(children: [Icon(track.icon, size: 17), const SizedBox(width: 8), Expanded(child: GestureDetector(onDoubleTap: () => _rename(context), child: Text(track.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)))), _Mini('M', track.isMuted, () => state.toggleMute(track)), _Mini('S', track.isSoloed, () => state.toggleSolo(track))]), Row(children: [Expanded(child: Slider(value: track.volume, onChanged: (v) => state.setVolume(track, v))), Text('${(track.volume * 100).round()}%', style: const TextStyle(fontSize: 9))]) ])); }
  void _rename(BuildContext context) { final c = TextEditingController(text: track.name); showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Rename track'), content: TextField(controller: c, autofocus: true), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { state.rename(track, c.text); Navigator.pop(context); }, child: const Text('Save'))])); }
}
class _Mini extends StatelessWidget { final String text; final bool active; final VoidCallback tap; const _Mini(this.text, this.active, this.tap); @override Widget build(BuildContext context) => IconButton(onPressed: tap, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28), icon: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: active ? Colors.redAccent : Colors.black38))); }

class _Timeline extends StatelessWidget {
  final DawState state; const _Timeline({required this.state});
  @override Widget build(BuildContext context) { final width = 64 * state.zoom; return Container(color: const Color(0xFFF8F8F5), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: width, child: Column(children: [_Ruler(state: state), Expanded(child: Stack(children: [_Grid(state: state), ...state.tracks.asMap().entries.map((e) => _TrackLane(track: e.value, state: state, index: e.key)), Positioned(left: (state.playhead - 1) * state.zoom, top: 0, bottom: 0, child: IgnorePointer(child: Container(width: 2, color: const Color(0xFF222222))))]))]))); }
}

class _Ruler extends StatelessWidget { final DawState state; const _Ruler({required this.state}); @override Widget build(BuildContext context) => GestureDetector(onTapDown: (d) => state.setPlayhead(d.localPosition.dx / state.zoom + 1), child: SizedBox(height: 38, child: Row(children: List.generate(64, (i) => Container(width: state.zoom, padding: const EdgeInsets.only(left: 6, top: 8), decoration: BoxDecoration(border: Border(left: BorderSide(color: i % 4 == 0 ? Colors.black12 : Colors.black.withOpacity(.04)))), child: i % 4 == 0 ? Text('${i + 1}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)) : null)))); }
}
class _Grid extends StatelessWidget { final DawState state; const _Grid({required this.state}); @override Widget build(BuildContext context) => Row(children: List.generate(64, (i) => Container(width: state.zoom, decoration: BoxDecoration(border: Border(right: BorderSide(color: i % 4 == 3 ? Colors.black12 : Colors.black.withOpacity(.035))))))); }

class _TrackLane extends StatelessWidget {
  final Track track; final DawState state; final int index; const _TrackLane({required this.track, required this.state, required this.index});
  @override Widget build(BuildContext context) => Positioned(top: index * 72.0, left: 0, right: 0, height: 72, child: Stack(children: [Container(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E5E0))))), ...track.regions.map((region) => _Region(track: track, region: region, state: state))]));
}

class _Region extends StatelessWidget {
  final Track track; final AudioRegion region; final DawState state; const _Region({required this.track, required this.region, required this.state});
  @override Widget build(BuildContext context) { final selected = state.selectedRegionId == region.id; return Positioned(left: (region.startBar - 1) * state.zoom, top: 8, width: region.durationBars * state.zoom, height: 56, child: GestureDetector(onTap: () => state.select(track, region), onDoubleTap: () => track.type == TrackType.midi ? showDialog(context: context, builder: (_) => MidiEditor(track: track, region: region, state: state)) : null, onHorizontalDragUpdate: (d) { final delta = d.delta.dx / state.zoom; state.moveRegion(track, region, region.startBar + delta); }, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: track.themeColor.withOpacity(.78), borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? Colors.black : Colors.transparent, width: 2)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(region.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)), const SizedBox(height: 5), Expanded(child: track.type == TrackType.midi ? _MidiPreview(region: region) : _Waveform(region: region)), Align(alignment: Alignment.bottomRight, child: GestureDetector(onHorizontalDragUpdate: (d) { state.resizeRegion(region, region.durationBars + d.delta.dx / state.zoom); }, child: const Icon(Icons.drag_handle, size: 12, color: Colors.white70))) ])))); }
}
class _Waveform extends StatelessWidget { final AudioRegion region; const _Waveform({required this.region}); @override Widget build(BuildContext context) => CustomPaint(painter: _WavePainter(region.waveformPoints)); }
class _WavePainter extends CustomPainter { final List<double> p; _WavePainter(this.p); @override void paint(Canvas c, Size s) { final paint = Paint()..color = Colors.white.withOpacity(.7)..strokeWidth = 1; if (p.isEmpty) return; for (var i = 0; i < p.length; i++) { final x = i / p.length * s.width; final a = p[i] * s.height * .45; c.drawLine(Offset(x, s.height / 2 - a), Offset(x, s.height / 2 + a), paint); } } @override bool shouldRepaint(covariant _WavePainter old) => false; }
class _MidiPreview extends StatelessWidget { final AudioRegion region; const _MidiPreview({required this.region}); @override Widget build(BuildContext context) => CustomPaint(painter: _MidiPainter(region.midiNotes, region.durationBars)); }
class _MidiPainter extends CustomPainter { final List<MidiNote> notes; final double duration; _MidiPainter(this.notes, this.duration); @override void paint(Canvas c, Size s) { final p = Paint()..color = Colors.white.withOpacity(.8); for (final n in notes) { final x = n.startBar / duration * s.width; final w = n.durationBars / duration * s.width; final y = ((84 - n.pitch).clamp(0, 48)) / 48 * s.height; c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w.clamp(3, s.width), 5), const Radius.circular(2)), p); } } @override bool shouldRepaint(covariant _MidiPainter old) => true; }

class _BottomBar extends StatelessWidget { final DawState state; const _BottomBar({required this.state}); @override Widget build(BuildContext context) => Container(height: 54, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE1E1DC)))), child: Row(children: [Text(state.selectedTrackId == 'keys' ? 'MIDI REGION SELECTED' : 'SELECT A MIDI REGION TO EDIT', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black45)), const Spacer(), if (state.selectedTrackId == 'keys') FilledButton.icon(onPressed: () { final track = state.tracks.firstWhere((t) => t.id == state.selectedTrackId); final region = track.regions.firstWhere((r) => r.id == state.selectedRegionId); showDialog(context: context, builder: (_) => MidiEditor(track: track, region: region, state: state)); }, icon: const Icon(Icons.piano, size: 16), label: const Text('Piano Roll')), if (state.selectedTrackId == 'keys') const SizedBox(width: 8), if (state.selectedTrackId == 'keys') OutlinedButton.icon(onPressed: () { final track = state.tracks.firstWhere((t) => t.id == state.selectedTrackId); final region = track.regions.firstWhere((r) => r.id == state.selectedRegionId); showDialog(context: context, builder: (_) => NotationView(region: region, keyName: state.key)); }, icon: const Icon(Icons.music_note, size: 16), label: const Text('Notation'))]));
}

class MidiEditor extends StatefulWidget { final Track track; final AudioRegion region; final DawState state; const MidiEditor({super.key, required this.track, required this.region, required this.state}); @override State<MidiEditor> createState() => _MidiEditorState(); }
class _MidiEditorState extends State<MidiEditor> { int selectedPitch = 60; @override Widget build(BuildContext context) { final r = widget.region; return Dialog(child: SizedBox(width: 920, height: 610, child: Column(children: [Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Text('Piano Roll', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(width: 14), Text('Chord: ${MusicTheory.detectChord(r.midiNotes.map((n) => n.pitch))}', style: const TextStyle(fontWeight: FontWeight.w700)), const Spacer(), Text('Double-click: add note  •  Drag: move  •  Shift+drag: resize'),])), Expanded(child: GestureDetector(onDoubleTapDown: (d) { final pitch = (84 - (d.localPosition.dy / 12).floor()).clamp(36, 84); final bar = (d.localPosition.dx / 90).floorToDouble(); setState(() => r.midiNotes.add(MidiNote(pitch: pitch, startBar: bar, durationBars: 1))); }, child: CustomPaint(painter: _PianoRollPainter(r.midiNotes)))), Padding(padding: const EdgeInsets.all(12), child: Row(children: [Text('Suggestions: ${MusicTheory.suggestChords(widget.state.key).join('  •  ')}'), const Spacer(), TextButton(onPressed: () => setState(() => r.midiNotes.clear()), child: const Text('Clear')), FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))]))])); } }
class _PianoRollPainter extends CustomPainter { final List<MidiNote> notes; _PianoRollPainter(this.notes); @override void paint(Canvas c, Size s) { final bg = Paint()..color = const Color(0xFFF9F9F7); c.drawRect(Offset.zero & s, bg); final grid = Paint()..color = Colors.black.withOpacity(.07)..strokeWidth = 1; for (var y = 0; y < s.height; y += 12) c.drawLine(Offset(0, y.toDouble()), Offset(s.width, y.toDouble()), grid); for (var x = 0; x < s.width; x += 90) c.drawLine(Offset(x.toDouble(), 0), Offset(x.toDouble(), s.height), grid); final notePaint = Paint()..color = const Color(0xFF4EAD96); for (final n in notes) { final x = n.startBar * 90; final y = (84 - n.pitch) * 12.0; c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, n.durationBars * 90, 10), const Radius.circular(3)), notePaint); } } @override bool shouldRepaint(covariant _PianoRollPainter old) => true; }

class NotationView extends StatelessWidget { final AudioRegion region; final String keyName; const NotationView({super.key, required this.region, required this.keyName}); @override Widget build(BuildContext context) => Dialog(child: SizedBox(width: 850, height: 430, child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Notation  •  $keyName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 20), Expanded(child: CustomPaint(painter: _StaffPainter(region.midiNotes), child: const SizedBox.expand())), Align(alignment: Alignment.bottomRight, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')))]))); }
class _StaffPainter extends CustomPainter { final List<MidiNote> notes; _StaffPainter(this.notes); @override void paint(Canvas c, Size s) { final p = Paint()..color = Colors.black..strokeWidth = 1; final top = s.height / 2 - 40; for (var i = 0; i < 5; i++) c.drawLine(Offset(0, top + i * 12), Offset(s.width, top + i * 12), p); for (final n in notes) { final x = 50 + n.startBar * 45; final y = top + 48 - ((n.pitch - 60) * 3); c.drawOval(Rect.fromCenter(center: Offset(x, y), width: 14, height: 10), p); c.drawLine(Offset(x + 7, y), Offset(x + 7, y - 30), p); } } @override bool shouldRepaint(covariant _StaffPainter old) => true; }
