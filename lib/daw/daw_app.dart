import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track_model.dart';
import 'music_theory.dart';

class DawState extends ChangeNotifier {
  final tracks = <Track>[];
  double playhead = 1, zoom = 64;
  int bpm = 92;
  String key = 'C min', timeSignature = '4/4';
  bool playing = false, loop = true;
  String? selectedTrackId, selectedRegionId;
  Timer? _timer;

  DawState() { resetProject(); }

  void resetProject() {
    tracks..clear()..addAll([
      _track('drums', 1, 'Drums', TrackType.audio, Icons.grid_view_rounded, const Color(0xFFE39A32), 'Main Groove'),
      _track('bass', 2, 'Bass', TrackType.audio, Icons.graphic_eq_rounded, const Color(0xFF9C72C9), 'Bassline'),
      _keys(),
      _track('vocal', 4, 'Lead Vocal', TrackType.audio, Icons.mic_rounded, const Color(0xFF6F91D0), 'Verse + Hook', start: 9),
    ]);
    playhead = 1; selectedTrackId = tracks.first.id; selectedRegionId = tracks.first.regions.first.id; notifyListeners();
  }

  Track _track(String id, int n, String name, TrackType type, IconData icon, Color color, String regionName, {double start = 1}) => Track(id: id, trackNumber: n, name: name, type: type, icon: icon, themeColor: color, regions: [AudioRegion(id: '${id}_r', name: regionName, startBar: start, durationBars: 8, color: color)]);
  Track _keys() => Track(id: 'keys', trackNumber: 3, name: 'Keys', type: TrackType.midi, icon: Icons.piano_rounded, themeColor: const Color(0xFF4EAD96), regions: [AudioRegion(id: 'keys_r', name: 'Chord Progression', startBar: 1, durationBars: 8, color: const Color(0xFF4EAD96), midiNotes: [
    MidiNote(pitch: 60, startBar: 0, durationBars: 2), MidiNote(pitch: 64, startBar: 0, durationBars: 2), MidiNote(pitch: 67, startBar: 0, durationBars: 2),
    MidiNote(pitch: 65, startBar: 2, durationBars: 2), MidiNote(pitch: 69, startBar: 2, durationBars: 2), MidiNote(pitch: 72, startBar: 2, durationBars: 2),
    MidiNote(pitch: 62, startBar: 4, durationBars: 2), MidiNote(pitch: 65, startBar: 4, durationBars: 2), MidiNote(pitch: 69, startBar: 4, durationBars: 2),
  ])]);

  void togglePlay() {
    playing = !playing; _timer?.cancel();
    if (playing) _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      playhead += (bpm / 60 / 4) * .03;
      if (playhead > 65) { if (loop) playhead = 1; else { playing = false; playhead = 1; _timer?.cancel(); } }
      notifyListeners();
    });
    notifyListeners();
  }
  void stop() { playing = false; _timer?.cancel(); playhead = 1; notifyListeners(); }
  void setPlayhead(double v) { playhead = v.clamp(1, 65).toDouble(); notifyListeners(); }
  void setBpm(int v) { bpm = v.clamp(40, 240).toInt(); notifyListeners(); }
  void select(Track t, AudioRegion r) { selectedTrackId = t.id; selectedRegionId = r.id; notifyListeners(); }
  void toggleMute(Track t) { t.isMuted = !t.isMuted; notifyListeners(); }
  void toggleSolo(Track t) { t.isSoloed = !t.isSoloed; notifyListeners(); }
  void setVolume(Track t, double v) { t.volume = v; notifyListeners(); }
  void rename(Track t, String name) { if (name.trim().isNotEmpty) t.name = name.trim(); notifyListeners(); }
  void addTrack(TrackType type) {
    final n = tracks.length + 1, id = 'track_$n';
    final colors = [const Color(0xFF5A9CC8), const Color(0xFFB779B8), const Color(0xFFCB875C), const Color(0xFF5DAE82)];
    final color = colors[n % colors.length];
    final t = Track(id: id, trackNumber: n, name: type == TrackType.midi ? 'Instrument $n' : 'Audio $n', type: type, icon: type == TrackType.midi ? Icons.piano_rounded : Icons.audiotrack_rounded, themeColor: color, regions: [AudioRegion(id: '${id}_r', name: 'New Region', startBar: 1, durationBars: 4, color: color)]);
    tracks.add(t); select(t, t.regions.first);
  }
  void moveRegion(Track t, AudioRegion r, double start) { r.startBar = _snap(start.clamp(1, 64 - r.durationBars).toDouble()); select(t, r); }
  void resizeRegion(AudioRegion r, double duration) { r.durationBars = _snap(duration.clamp(1, 32).toDouble()); notifyListeners(); }
  double _snap(double v) => (v * 4).round() / 4;
  @override void dispose() { _timer?.cancel(); super.dispose(); }
}

class DawApp extends StatelessWidget {
  const DawApp({super.key});
  @override Widget build(BuildContext context) => ChangeNotifierProvider(create: (_) => DawState(), child: MaterialApp(debugShowCheckedModeBanner: false, title: 'Sound Bank', theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF202020)), scaffoldBackgroundColor: const Color(0xFFF4F4F1)), home: const DawEditor()));
}

class DawEditor extends StatelessWidget {
  const DawEditor({super.key});
  @override Widget build(BuildContext context) { final s = context.watch<DawState>(); return Scaffold(body: SafeArea(child: Column(children: [
    _Header(s), _Transport(s), Expanded(child: Row(children: [SizedBox(width: 230, child: _Tracks(s)), Expanded(child: _Timeline(s))])), _Bottom(s),
  ]))); }
}

class _Header extends StatelessWidget { final DawState s; const _Header(this.s); @override Widget build(BuildContext c) => Container(height: 58, padding: const EdgeInsets.symmetric(horizontal: 18), decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE1E1DC)))), child: Row(children: [const Icon(Icons.graphic_eq_rounded), const SizedBox(width: 10), const Text('SOUND BANK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)), const SizedBox(width: 18), const Text('Late Night', style: TextStyle(color: Colors.black54)), const Spacer(), IconButton(onPressed: () { s.zoom = (s.zoom - 8).clamp(36, 120).toDouble(); s.notifyListeners(); }, icon: const Icon(Icons.zoom_out)), Text('${s.zoom.round()} px/bar', style: const TextStyle(fontSize: 11)), IconButton(onPressed: () { s.zoom = (s.zoom + 8).clamp(36, 120).toDouble(); s.notifyListeners(); }, icon: const Icon(Icons.zoom_in))]); }

class _Transport extends StatelessWidget { final DawState s; const _Transport(this.s); @override Widget build(BuildContext c) => Container(height: 70, padding: const EdgeInsets.symmetric(horizontal: 18), decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE1E1DC)))), child: Row(children: [IconButton(onPressed: s.stop, icon: const Icon(Icons.stop_rounded)), IconButton(onPressed: s.togglePlay, icon: Icon(s.playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded, size: 38)), IconButton(onPressed: () { s.loop = !s.loop; s.notifyListeners(); }, icon: Icon(Icons.repeat_rounded, color: s.loop ? Colors.black : Colors.black26)), const SizedBox(width: 18), _Value('BPM', '${s.bpm}', () => _bpm(c)), _Value('KEY', s.key, () {}), _Value('TIME', s.timeSignature, () {}), const Spacer(), Text('BAR ${s.playhead.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(width: 16)])); void _bpm(BuildContext c) { final x = TextEditingController(text: '${s.bpm}'); showDialog(context: c, builder: (_) => AlertDialog(title: const Text('Tempo'), content: TextField(controller: x, keyboardType: TextInputType.number, autofocus: true), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')), FilledButton(onPressed: () { s.setBpm(int.tryParse(x.text) ?? s.bpm); Navigator.pop(c); }, child: const Text('Set'))])); } }
class _Value extends StatelessWidget { final String label, value; final VoidCallback tap; const _Value(this.label, this.value, this.tap); @override Widget build(BuildContext c) => InkWell(onTap: tap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: const TextStyle(fontSize: 8, color: Colors.black38, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))]))); }

class _Tracks extends StatelessWidget { final DawState s; const _Tracks(this.s); @override Widget build(BuildContext c) => Container(decoration: const BoxDecoration(color: Color(0xFFF9F9F6), border: Border(right: BorderSide(color: Color(0xFFE1E1DC)))), child: Column(children: [Container(height: 38, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 14), child: const Text('TRACKS', style: TextStyle(fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w800, color: Colors.black45))), Expanded(child: ListView.builder(itemCount: s.tracks.length, itemBuilder: (_, i) => _TrackHeader(s.tracks[i], s))), Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _add(c), icon: const Icon(Icons.add), label: const Text('Add Track'))))])); void _add(BuildContext c) => showModalBottomSheet(context: c, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [const Padding(padding: EdgeInsets.all(18), child: Text('Add Track', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))), ListTile(leading: const Icon(Icons.piano), title: const Text('Software Instrument / MIDI'), onTap: () { s.addTrack(TrackType.midi); Navigator.pop(c); }), ListTile(leading: const Icon(Icons.mic), title: const Text('Audio'), onTap: () { s.addTrack(TrackType.audio); Navigator.pop(c); })]))); }
class _TrackHeader extends StatelessWidget { final Track t; final DawState s; const _TrackHeader(this.t, this.s); @override Widget build(BuildContext c) { final selected = s.selectedTrackId == t.id; return Container(height: 72, padding: const EdgeInsets.symmetric(horizontal: 9), decoration: BoxDecoration(color: selected ? t.themeColor.withOpacity(.08) : null, border: const Border(bottom: BorderSide(color: Color(0xFFE4E4DF)))), child: Column(children: [Row(children: [Icon(t.icon, size: 17), const SizedBox(width: 7), Expanded(child: GestureDetector(onDoubleTap: () => _rename(c), child: Text(t.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))), _Button('M', t.isMuted, () => s.toggleMute(t)), _Button('S', t.isSoloed, () => s.toggleSolo(t))]), Row(children: [Expanded(child: Slider(value: t.volume, onChanged: (v) => s.setVolume(t, v))), Text('${(t.volume * 100).round()}%', style: const TextStyle(fontSize: 9))]) ])); } void _rename(BuildContext c) { final x = TextEditingController(text: t.name); showDialog(context: c, builder: (_) => AlertDialog(title: const Text('Rename track'), content: TextField(controller: x, autofocus: true), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')), FilledButton(onPressed: () { s.rename(t, x.text); Navigator.pop(c); }, child: const Text('Save'))])); } }
class _Button extends StatelessWidget { final String text; final bool active; final VoidCallback tap; const _Button(this.text, this.active, this.tap); @override Widget build(BuildContext c) => IconButton(onPressed: tap, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 27), icon: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: active ? Colors.redAccent : Colors.black38))); }

class _Timeline extends StatelessWidget { final DawState s; const _Timeline(this.s); @override Widget build(BuildContext c) { final width = 64 * s.zoom; return Container(color: const Color(0xFFF8F8F5), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: width, child: Column(children: [_Ruler(s), Expanded(child: Stack(children: [_Grid(s), ...s.tracks.asMap().entries.map((e) => _Lane(e.value, s, e.key)), Positioned(left: (s.playhead - 1) * s.zoom, top: 0, bottom: 0, child: IgnorePointer(child: Container(width: 2, color: const Color(0xFF222222))))]))]))); } }
class _Ruler extends StatelessWidget { final DawState s; const _Ruler(this.s); @override Widget build(BuildContext c) => GestureDetector(onTapDown: (d) => s.setPlayhead(d.localPosition.dx / s.zoom + 1), child: SizedBox(height: 38, child: Row(children: List.generate(64, (i) => Container(width: s.zoom, padding: const EdgeInsets.only(left: 6, top: 8), decoration: BoxDecoration(border: Border(left: BorderSide(color: i % 4 == 0 ? Colors.black12 : Colors.black.withOpacity(.04)))), child: i % 4 == 0 ? Text('${i + 1}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)) : null)))); }
class _Grid extends StatelessWidget { final DawState s; const _Grid(this.s); @override Widget build(BuildContext c) => Row(children: List.generate(64, (i) => Container(width: s.zoom, decoration: BoxDecoration(border: Border(right: BorderSide(color: i % 4 == 3 ? Colors.black12 : Colors.black.withOpacity(.035))))))); }
class _Lane extends StatelessWidget { final Track t; final DawState s; final int index; const _Lane(this.t, this.s, this.index); @override Widget build(BuildContext c) => Positioned(top: index * 72.0, left: 0, right: 0, height: 72, child: Stack(children: [Container(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E5E0))))), ...t.regions.map((r) => _Region(t, r, s))])); }

class _Region extends StatelessWidget { final Track t; final AudioRegion r; final DawState s; const _Region(this.t, this.r, this.s); @override Widget build(BuildContext c) { final selected = s.selectedRegionId == r.id; return Positioned(left: (r.startBar - 1) * s.zoom, top: 8, width: r.durationBars * s.zoom, height: 56, child: GestureDetector(onTap: () => s.select(t, r), onDoubleTap: () => t.type == TrackType.midi ? showDialog(context: c, builder: (_) => MidiEditor(r, s)) : null, onHorizontalDragUpdate: (d) => s.moveRegion(t, r, r.startBar + d.delta.dx / s.zoom), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: t.themeColor.withOpacity(.78), borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? Colors.black : Colors.transparent, width: 2)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Expanded(child: t.type == TrackType.midi ? CustomPaint(painter: _MidiPreviewPainter(r)) : CustomPaint(painter: _WavePainter(r.waveformPoints))), Align(alignment: Alignment.bottomRight, child: GestureDetector(onHorizontalDragUpdate: (d) => s.resizeRegion(r, r.durationBars + d.delta.dx / s.zoom), child: const Icon(Icons.drag_handle, size: 12, color: Colors.white70))) ])))); } }
class _WavePainter extends CustomPainter { final List<double> p; _WavePainter(this.p); @override void paint(Canvas c, Size z) { final q = Paint()..color = Colors.white.withOpacity(.7); for (var i = 0; i < p.length; i++) { final x = i / p.length * z.width, a = p[i] * z.height * .4; c.drawLine(Offset(x, z.height / 2 - a), Offset(x, z.height / 2 + a), q); } } @override bool shouldRepaint(covariant _WavePainter old) => false; }
class _MidiPreviewPainter extends CustomPainter { final AudioRegion r; _MidiPreviewPainter(this.r); @override void paint(Canvas c, Size z) { final q = Paint()..color = Colors.white.withOpacity(.8); for (final n in r.midiNotes) { final x = n.startBar / r.durationBars * z.width, y = ((84 - n.pitch).clamp(0, 48).toDouble()) / 48 * z.height; c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, (n.durationBars / r.durationBars * z.width).clamp(3, z.width).toDouble(), 5), const Radius.circular(2)), q); } } @override bool shouldRepaint(covariant _MidiPreviewPainter old) => true; }

class _Bottom extends StatelessWidget { final DawState s; const _Bottom(this.s); @override Widget build(BuildContext c) { final midi = s.selectedTrackId == 'keys'; return Container(height: 54, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE1E1DC)))), child: Row(children: [Text(midi ? 'MIDI REGION SELECTED' : 'SELECT A MIDI REGION', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black45)), const Spacer(), if (midi) FilledButton.icon(onPressed: () => _midi(c), icon: const Icon(Icons.piano, size: 16), label: const Text('Piano Roll')), if (midi) const SizedBox(width: 8), if (midi) OutlinedButton.icon(onPressed: () => _notation(c), icon: const Icon(Icons.music_note, size: 16), label: const Text('Notation'))])); } void _midi(BuildContext c) { final t = s.tracks.firstWhere((x) => x.id == s.selectedTrackId), r = t.regions.firstWhere((x) => x.id == s.selectedRegionId); showDialog(context: c, builder: (_) => MidiEditor(r, s)); } void _notation(BuildContext c) { final t = s.tracks.firstWhere((x) => x.id == s.selectedTrackId), r = t.regions.firstWhere((x) => x.id == s.selectedRegionId); showDialog(context: c, builder: (_) => NotationView(r, s.key)); } }

class MidiEditor extends StatefulWidget { final AudioRegion r; final DawState s; const MidiEditor(this.r, this.s, {super.key}); @override State<MidiEditor> createState() => _MidiEditorState(); }
class _MidiEditorState extends State<MidiEditor> { @override Widget build(BuildContext c) => Dialog(child: SizedBox(width: 900, height: 600, child: Column(children: [Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Text('Piano Roll', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(width: 16), Text('Chord: ${MusicTheory.detectChord(widget.r.midiNotes.map((n) => n.pitch))}'), const Spacer(), const Text('Double-click to add') ])), Expanded(child: GestureDetector(onDoubleTapDown: (d) { final p = (84 - (d.localPosition.dy / 12).floor()).clamp(36, 84).toInt(); final bar = (d.localPosition.dx / 90).floorToDouble(); setState(() => widget.r.midiNotes.add(MidiNote(pitch: p, startBar: bar, durationBars: 1))); }, child: CustomPaint(painter: _PianoPainter(widget.r.midiNotes)))), Padding(padding: const EdgeInsets.all(12), child: Row(children: [Text('Suggestions: ${MusicTheory.suggestChords(widget.s.key).join(' • ')}'), const Spacer(), TextButton(onPressed: () => setState(() => widget.r.midiNotes.clear()), child: const Text('Clear')), FilledButton(onPressed: () { widget.s.notifyListeners(); Navigator.pop(c); }, child: const Text('Done'))]))])); }
class _PianoPainter extends CustomPainter { final List<MidiNote> notes; _PianoPainter(this.notes); @override void paint(Canvas c, Size z) { c.drawRect(Offset.zero & z, Paint()..color = const Color(0xFFF9F9F7)); final g = Paint()..color = Colors.black.withOpacity(.07); for (var y = 0; y < z.height; y += 12) c.drawLine(Offset(0, y.toDouble()), Offset(z.width, y.toDouble()), g); for (var x = 0; x < z.width; x += 90) c.drawLine(Offset(x.toDouble(), 0), Offset(x.toDouble(), z.height), g); final n = Paint()..color = const Color(0xFF4EAD96); for (final note in notes) c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(note.startBar * 90, (84 - note.pitch) * 12.0, note.durationBars * 90, 10), const Radius.circular(3)), n); } @override bool shouldRepaint(covariant _PianoPainter old) => true; }

class NotationView extends StatelessWidget { final AudioRegion r; final String keyName; const NotationView(this.r, this.keyName, {super.key}); @override Widget build(BuildContext c) => Dialog(child: SizedBox(width: 850, height: 420, child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Notation • $keyName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 20), Expanded(child: CustomPaint(painter: _StaffPainter(r.midiNotes), child: const SizedBox.expand())), Align(alignment: Alignment.bottomRight, child: FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Done')))]))); }
class _StaffPainter extends CustomPainter { final List<MidiNote> notes; _StaffPainter(this.notes); @override void paint(Canvas c, Size z) { final p = Paint()..color = Colors.black..strokeWidth = 1, top = z.height / 2 - 40; for (var i = 0; i < 5; i++) c.drawLine(Offset(0, top + i * 12), Offset(z.width, top + i * 12), p); for (final n in notes) { final x = 50 + n.startBar * 45, y = top + 48 - (n.pitch - 60) * 3; c.drawOval(Rect.fromCenter(center: Offset(x, y), width: 14, height: 10), p); c.drawLine(Offset(x + 7, y), Offset(x + 7, y - 30), p); } } @override bool shouldRepaint(covariant _StaffPainter old) => true; }
