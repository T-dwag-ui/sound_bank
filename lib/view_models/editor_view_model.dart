import 'dart:async';
import 'package:flutter/material.dart';
import '../models/track_model.dart';
import '../models/mastering_model.dart';
import '../models/sound_library_model.dart';

enum BottomTab { none, sampler, mastering, flexPitch, aiGenerator }

class EditorViewModel extends ChangeNotifier {
  // Navigation & Logic Pro UI State
  BottomTab _activeBottomTab = BottomTab.flexPitch;
  bool _isInspectorOpen = true;
  bool _isLibraryOpen = false;
  final bool _isSmartControlsOpen = false;
  final bool _isMixerOpen = false;

  // Playback & Project State
  bool _isPlaying = false;
  bool _isLooping = true;
  double _currentBar = 52.3; // Matches Logic reference (Bar 52, beat 3)
  int _bpm = 127;
  String _keySignature = 'C min';
  String _timeSignature = '4/4';
  final int _totalBars = 68;
  double _zoomLevel = 65.0; // pixels per bar
  Timer? _playbackTimer;

  // Selection
  String _selectedTrackId = '1'; // Lead Vocal
  String? _selectedRegionId = 'r1';

  // Master Bus Volume & VU Meter
  double _masterVolume = 0.90;
  final double _masterPeakL = -0.5;
  final double _masterPeakR = -0.8;

  // Auto Audio Sampler State
  final String _sampleName = 'Vocal_Chop_Lead.wav';
  final String _sampleRootKey = 'C3';
  final int _sampleRootMidi = 60;
  double _sampleAttack = 0.02; // seconds
  double _sampleDecay = 0.35;
  double _sampleSustain = 0.75;
  double _sampleRelease = 0.50;
  int _samplePitchShift = 0; // semitones
  int _sliceCount = 8;
  int? _activePianoNote;

  // AI Mixing & Mastering State
  final MasteringChainState _masteringState = MasteringChainState();
  bool _isAnalyzingMaster = false;
  String _aiMasterDiagnostic = 'Project spectrum analyzed. High-mid clarity boost applied (+2.0dB @ 4kHz). Dynamic headroom normalized to -14.0 LUFS.';

  // Flex Pitch Fine Tuning State
  FlexPitchNode? _selectedPitchNode;
  double _globalPitchCorrection = 85.0; // 85%
  String _scaleQuantize = 'Major';
  int _globalFormantShift = 0;

  // Suno AI Prompt State
  final String _aiPrompt = '80s Synthwave lead synth with heavy reverb';
  bool _isGeneratingAi = false;

  // Track List (Logic Pro Classic Palette & Data)
  final List<Track> _tracks = [
    Track(
      id: '1',
      trackNumber: 1,
      name: 'Lead Vocal',
      type: TrackType.audio,
      icon: Icons.mic,
      themeColor: const Color(0xFF3B82F6), // Royal Blue
      volume: 0.85,
      pan: -0.1,
      plugins: ['Channel EQ', 'Compressor', 'DeEsser', 'ChromaVerb'],
      regions: [
        AudioRegion(
          id: 'r1',
          name: 'Lead Vocal: Main Hook',
          startBar: 45.0,
          durationBars: 12.0,
          color: const Color(0xFF3B82F6),
        ),
      ],
    ),
    Track(
      id: '2',
      trackNumber: 2,
      name: 'Drummer',
      type: TrackType.audio,
      icon: Icons.grid_view_rounded,
      themeColor: const Color(0xFFF59E0B), // Amber Gold
      volume: 0.90,
      pan: 0.0,
      plugins: ['Drum Kit Designer', 'Compressor', 'Limiter'],
      regions: [
        AudioRegion(
          id: 'r2_1',
          name: 'Chorus Drums',
          startBar: 45.0,
          durationBars: 8.0,
          color: const Color(0xFFF59E0B),
        ),
        AudioRegion(
          id: 'r2_2',
          name: 'Pre-verse Drums',
          startBar: 53.0,
          durationBars: 6.0,
          color: const Color(0xFFF59E0B),
        ),
        AudioRegion(
          id: 'r2_3',
          name: 'Verse 2 Drums',
          startBar: 61.0,
          durationBars: 7.0,
          color: const Color(0xFFF59E0B),
        ),
      ],
    ),
    Track(
      id: '3',
      trackNumber: 3,
      name: 'Synth Pad Layers',
      type: TrackType.midi,
      icon: Icons.piano,
      themeColor: const Color(0xFF10B981), // Lime Green
      volume: 0.78,
      pan: 0.2,
      plugins: ['Alchemy', 'Channel EQ', 'Tape Delay'],
      regions: [
        AudioRegion(
          id: 'r3_1',
          name: 'Synth Pad Chords',
          startBar: 45.0,
          durationBars: 16.0,
          color: const Color(0xFF10B981),
          midiNotes: [
            MidiNote(pitch: 60, startBar: 45.0, durationBars: 4.0),
            MidiNote(pitch: 64, startBar: 45.0, durationBars: 4.0),
            MidiNote(pitch: 67, startBar: 45.0, durationBars: 4.0),
            MidiNote(pitch: 62, startBar: 49.0, durationBars: 4.0),
            MidiNote(pitch: 65, startBar: 49.0, durationBars: 4.0),
          ],
        ),
      ],
    ),
    Track(
      id: '4',
      trackNumber: 4,
      name: 'Vintage B3 Organ',
      type: TrackType.midi,
      icon: Icons.music_note,
      themeColor: const Color(0xFF84CC16), // Emerald Yellow-Green
      volume: 0.80,
      pan: -0.25,
      plugins: ['Vintage B3', 'Rotor Cabinet'],
      regions: [
        AudioRegion(
          id: 'r4',
          name: 'Vintage B3 Groove',
          startBar: 45.0,
          durationBars: 16.0,
          color: const Color(0xFF84CC16),
        ),
      ],
    ),
    Track(
      id: '5',
      trackNumber: 5,
      name: 'Crunchy Synth',
      type: TrackType.midi,
      icon: Icons.blur_on,
      themeColor: const Color(0xFF22C55E), // Bright Green
      volume: 0.82,
      pan: 0.15,
      plugins: ['ES2 Synth', 'Distortion', 'Channel EQ'],
      regions: [
        AudioRegion(
          id: 'r5',
          name: 'Crunchy Lead Riff',
          startBar: 45.0,
          durationBars: 12.0,
          color: const Color(0xFF22C55E),
        ),
      ],
    ),
    Track(
      id: '6',
      trackNumber: 6,
      name: 'Electric Piano',
      type: TrackType.midi,
      icon: Icons.piano,
      themeColor: const Color(0xFF14B8A6), // Teal
      volume: 0.75,
      pan: 0.0,
      plugins: ['Vintage Electric Piano', 'Chorus', 'Stereo Delay'],
      regions: [
        AudioRegion(
          id: 'r6',
          name: 'E-Piano Arp',
          startBar: 45.0,
          durationBars: 14.0,
          color: const Color(0xFF14B8A6),
        ),
      ],
    ),
    Track(
      id: '7',
      trackNumber: 7,
      name: 'Drum Machine',
      type: TrackType.audio,
      icon: Icons.space_dashboard_rounded,
      themeColor: const Color(0xFF06B6D4), // Cyan Blue
      volume: 0.88,
      pan: 0.0,
      plugins: ['Drum Machine Designer', 'Overdrive'],
      regions: [
        AudioRegion(
          id: 'r7_1',
          name: 'Beat Loop A',
          startBar: 45.0,
          durationBars: 8.0,
          color: const Color(0xFF06B6D4),
        ),
        AudioRegion(
          id: 'r7_2',
          name: 'Beat Loop B',
          startBar: 61.0,
          durationBars: 7.0,
          color: const Color(0xFF06B6D4),
        ),
      ],
    ),
    Track(
      id: '8',
      trackNumber: 8,
      name: 'Backing Vocal',
      type: TrackType.audio,
      icon: Icons.record_voice_over,
      themeColor: const Color(0xFF4F46E5), // Indigo
      volume: 0.70,
      pan: 0.35,
      plugins: ['Channel EQ', 'Compressor', 'Pitch Correction'],
      regions: [
        AudioRegion(
          id: 'r8',
          name: 'Harmonies Fill',
          startBar: 49.0,
          durationBars: 6.0,
          color: const Color(0xFF4F46E5),
        ),
      ],
    ),
    Track(
      id: '9',
      trackNumber: 9,
      name: 'Funk Bass',
      type: TrackType.audio,
      icon: Icons.graphic_eq,
      themeColor: const Color(0xFFD946EF), // Magenta / Purple
      volume: 0.86,
      pan: 0.0,
      plugins: ['Bass Amp Designer', 'Compressor'],
      regions: [
        AudioRegion(
          id: 'r9',
          name: 'Slap Bassline',
          startBar: 47.0,
          durationBars: 14.0,
          color: const Color(0xFFD946EF),
        ),
      ],
    ),
  ];

  EditorViewModel() {
    _selectedPitchNode = _tracks.first.regions.first.flexPitchNodes.first;
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  // Getters
  BottomTab get activeBottomTab => _activeBottomTab;
  bool get isInspectorOpen => _isInspectorOpen;
  bool get isLibraryOpen => _isLibraryOpen;
  bool get isSmartControlsOpen => _isSmartControlsOpen;
  bool get isMixerOpen => _isMixerOpen;

  bool get isPlaying => _isPlaying;
  bool get isLooping => _isLooping;
  double get currentBar => _currentBar;
  int get bpm => _bpm;
  String get keySignature => _keySignature;
  String get timeSignature => _timeSignature;
  int get totalBars => _totalBars;
  double get zoomLevel => _zoomLevel;
  List<Track> get tracks => _tracks;

  String get selectedTrackId => _selectedTrackId;
  String? get selectedRegionId => _selectedRegionId;

  Track get selectedTrack =>
      _tracks.firstWhere((t) => t.id == _selectedTrackId, orElse: () => _tracks.first);

  double get masterVolume => _masterVolume;
  double get masterPeakL => _masterPeakL;
  double get masterPeakR => _masterPeakR;

  // Sampler Getters
  String get sampleName => _sampleName;
  String get sampleRootKey => _sampleRootKey;
  int get sampleRootMidi => _sampleRootMidi;
  double get sampleAttack => _sampleAttack;
  double get sampleDecay => _sampleDecay;
  double get sampleSustain => _sampleSustain;
  double get sampleRelease => _sampleRelease;
  int get samplePitchShift => _samplePitchShift;
  int get sliceCount => _sliceCount;
  int? get activePianoNote => _activePianoNote;

  // AI Mastering Getters
  MasteringChainState get masteringState => _masteringState;
  bool get isAnalyzingMaster => _isAnalyzingMaster;
  String get aiMasterDiagnostic => _aiMasterDiagnostic;

  // Flex Pitch Getters
  FlexPitchNode? get selectedPitchNode => _selectedPitchNode;
  double get globalPitchCorrection => _globalPitchCorrection;
  String get scaleQuantize => _scaleQuantize;
  int get globalFormantShift => _globalFormantShift;

  // AI Generator Getters
  String get aiPrompt => _aiPrompt;
  bool get isGeneratingAi => _isGeneratingAi;

  // Actions
  void setBottomTab(BottomTab tab) {
    if (_activeBottomTab == tab) {
      _activeBottomTab = BottomTab.none;
    } else {
      _activeBottomTab = tab;
    }
    notifyListeners();
  }

  void toggleInspector() {
    _isInspectorOpen = !_isInspectorOpen;
    notifyListeners();
  }

  void toggleLibrary() {
    _isLibraryOpen = !_isLibraryOpen;
    notifyListeners();
  }

  void selectTrack(String trackId) {
    _selectedTrackId = trackId;
    notifyListeners();
  }

  void selectRegion(String regionId) {
    _selectedRegionId = regionId;
    notifyListeners();
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startPlaybackTimer();
    } else {
      _playbackTimer?.cancel();
    }
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    _playbackTimer?.cancel();
    _currentBar = 1.0;
    notifyListeners();
  }

  void toggleLooping() {
    _isLooping = !_isLooping;
    notifyListeners();
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    const intervalMs = 30;
    _playbackTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      double secondsPerBar = (60.0 / _bpm) * 4.0;
      double barsPerStep = (intervalMs / 1000.0) / secondsPerBar;
      _currentBar += barsPerStep;
      if (_currentBar > _totalBars + 1) {
        if (_isLooping) {
          _currentBar = 1.0;
        } else {
          _isPlaying = false;
          _currentBar = 1.0;
          timer.cancel();
        }
      }
      notifyListeners();
    });
  }

  void setBpm(int newBpm) {
    _bpm = newBpm.clamp(40, 240);
    notifyListeners();
  }

  void setKeySignature(String key) {
    _keySignature = key;
    notifyListeners();
  }

  void setTimeSignature(String ts) {
    _timeSignature = ts;
    notifyListeners();
  }

  void setZoomLevel(double zoom) {
    _zoomLevel = zoom.clamp(35.0, 160.0);
    notifyListeners();
  }

  void updatePlayhead(double bar) {
    _currentBar = bar.clamp(1.0, _totalBars.toDouble() + 1.0);
    notifyListeners();
  }

  void toggleMute(String trackId) {
    final track = _tracks.firstWhere((t) => t.id == trackId);
    track.isMuted = !track.isMuted;
    notifyListeners();
  }

  void toggleSolo(String trackId) {
    final track = _tracks.firstWhere((t) => t.id == trackId);
    track.isSoloed = !track.isSoloed;
    notifyListeners();
  }

  void toggleRecordArm(String trackId) {
    final track = _tracks.firstWhere((t) => t.id == trackId);
    track.isRecordArmed = !track.isRecordArmed;
    notifyListeners();
  }

  void toggleInputMonitoring(String trackId) {
    final track = _tracks.firstWhere((t) => t.id == trackId);
    track.isInputMonitored = !track.isInputMonitored;
    notifyListeners();
  }

  void setTrackVolume(String trackId, double volume) {
    final track = _tracks.firstWhere((t) => t.id == trackId);
    track.volume = volume;
    notifyListeners();
  }

  void setTrackPan(String trackId, double pan) {
    final track = _tracks.firstWhere((t) => t.id == trackId);
    track.pan = pan.clamp(-1.0, 1.0);
    notifyListeners();
  }

  void setMasterVolume(double vol) {
    _masterVolume = vol.clamp(0.0, 1.0);
    notifyListeners();
  }

  // --- Sampler Actions ---
  void setSampleAdsr({double? attack, double? decay, double? sustain, double? release}) {
    if (attack != null) _sampleAttack = attack;
    if (decay != null) _sampleDecay = decay;
    if (sustain != null) _sampleSustain = sustain;
    if (release != null) _sampleRelease = release;
    notifyListeners();
  }

  void setSamplePitchShift(int semitones) {
    _samplePitchShift = semitones.clamp(-24, 24);
    notifyListeners();
  }

  void setSliceCount(int count) {
    _sliceCount = count.clamp(2, 32);
    notifyListeners();
  }

  void pressPianoNote(int midiNote) {
    _activePianoNote = midiNote;
    notifyListeners();
  }

  void releasePianoNote() {
    _activePianoNote = null;
    notifyListeners();
  }

  void convertAudioToMidiSampler() {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newTrack = Track(
      id: newId,
      trackNumber: _tracks.length + 1,
      name: 'MIDI Sampler (${selectedTrack.name})',
      type: TrackType.sampler,
      icon: Icons.keyboard,
      themeColor: const Color(0xFFEC4899),
      regions: [
        AudioRegion(
          id: 'sr_$newId',
          name: 'Sampled Chromatic Sequence',
          startBar: _currentBar.floorToDouble(),
          durationBars: 8.0,
          color: const Color(0xFFEC4899),
          midiNotes: [
            MidiNote(pitch: 60, startBar: _currentBar, durationBars: 1.0),
            MidiNote(pitch: 62, startBar: _currentBar + 1, durationBars: 1.0),
            MidiNote(pitch: 64, startBar: _currentBar + 2, durationBars: 1.0),
            MidiNote(pitch: 67, startBar: _currentBar + 3, durationBars: 2.0),
          ],
        ),
      ],
    );
    _tracks.add(newTrack);
    _selectedTrackId = newId;
    _activeBottomTab = BottomTab.sampler;
    notifyListeners();
  }

  // --- AI Mastering Actions ---
  void setTargetLufs(double lufs) {
    _masteringState.targetLufs = lufs;
    notifyListeners();
  }

  void setMasteringGenre(String genre) {
    _masteringState.selectedGenre = genre;
    notifyListeners();
  }

  void toggleAbBypass() {
    _masteringState.isAbBypass = !_masteringState.isAbBypass;
    notifyListeners();
  }

  Future<void> runAiAutoMaster() async {
    _isAnalyzingMaster = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1400));

    _masteringState.isMastered = true;
    _masteringState.thresholdDb = -16.5;
    _masteringState.ratio = 4.0;
    _masteringState.stereoWidth = 1.35;
    _masteringState.exciterDrive = 0.45;
    _masteringState.ceilingDb = -0.2;

    _aiMasterDiagnostic =
        'Auto-Mastering Complete! Match Target: ${_masteringState.targetLufs} LUFS. Applied Dynamic Multi-band Compression, Mid-Side Stereo Expansion (+35%), and Harmonic Tape Warmth.';
    _isAnalyzingMaster = false;
    notifyListeners();
  }

  // --- Flex Pitch Actions ---
  void selectPitchNode(FlexPitchNode node) {
    _selectedPitchNode = node;
    notifyListeners();
  }

  void setGlobalPitchCorrection(double value) {
    _globalPitchCorrection = value;
    if (_selectedPitchNode != null) {
      _selectedPitchNode!.correctionAmount = value / 100.0;
    }
    notifyListeners();
  }

  void setScaleQuantize(String scale) {
    _scaleQuantize = scale;
    notifyListeners();
  }

  void setFormantShift(int semitones) {
    _globalFormantShift = semitones;
    if (_selectedPitchNode != null) {
      _selectedPitchNode!.formantShift = semitones;
    }
    notifyListeners();
  }

  // --- AI Stem Generator Actions ---
  Future<void> generateAiTrack(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return;

    _isGeneratingAi = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    final colors = [
      const Color(0xFFEC4899),
      const Color(0xFFA855F7),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];
    final color = colors[_tracks.length % colors.length];

    final newTrack = Track(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      trackNumber: _tracks.length + 1,
      name: 'AI Stem: "$trimmed"',
      type: TrackType.aiGenerated,
      icon: Icons.auto_awesome,
      themeColor: color,
      regions: [
        AudioRegion(
          id: DateTime.now().toString(),
          name: trimmed,
          startBar: _currentBar.floorToDouble(),
          durationBars: 8.0,
          color: color,
        ),
      ],
    );

    _tracks.insert(0, newTrack);
    _isGeneratingAi = false;
    notifyListeners();
  }

  // --- Sound Library Actions ---
  void loadPresetAsTrack(SoundLibraryPreset preset) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final trackType = preset.defaultTrackType == 'Audio' ? TrackType.audio : TrackType.midi;

    final newTrack = Track(
      id: newId,
      trackNumber: _tracks.length + 1,
      name: preset.name,
      type: trackType,
      icon: preset.icon,
      themeColor: preset.themeColor,
      plugins: List<String>.from(preset.defaultPlugins),
      regions: [
        AudioRegion(
          id: 'lr_$newId',
          name: preset.name,
          startBar: _currentBar.floorToDouble(),
          durationBars: 8.0,
          color: preset.themeColor,
        ),
      ],
    );

    _tracks.add(newTrack);
    _selectedTrackId = newId;
    notifyListeners();
  }
}
