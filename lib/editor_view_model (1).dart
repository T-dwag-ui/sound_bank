import 'dart:async';
import 'package:flutter/material.dart';
import '../models/track_model.dart';
import '../models/mastering_model.dart';
import '../models/sound_library_model.dart';

enum BottomTab { none, sampler, mastering, flexPitch, aiGenerator }

class EditorViewModel extends ChangeNotifier {
  // Navigation & Logic Pro UI State
  BottomTab _activeBottomTab = BottomTab.none;
  bool _isInspectorOpen = false;
  bool _isLibraryOpen = false;
  bool _isSmartControlsOpen = false;
  bool _isMixerOpen = false;

  // Playback & Project State
  bool _isPlaying = false;
  bool _isLooping = true;
  double _currentBar = 1.0;
  int _bpm = 92;
  String _keySignature = 'C min';
  String _timeSignature = '4/4';
  int _totalBars = 64;
  double _zoomLevel = 72.0; // pixels per bar
  Timer? _playbackTimer;

  // Selection
  String _selectedTrackId = '';
  String? _selectedRegionId;

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

  // Tracks are created by the New Song/template flow instead of being
  // hard-coded into every new project.
  final List<Track> _tracks = [];

  EditorViewModel({
    int? bpm,
    String? keySignature,
    String? timeSignature,
    List<Track>? initialTracks,
  }) {
    if (bpm != null) _bpm = bpm;
    if (keySignature != null) _keySignature = keySignature;
    if (timeSignature != null) _timeSignature = timeSignature;
    if (initialTracks != null) {
      _tracks.addAll(initialTracks);
      _renumberTracks();
      if (_tracks.isNotEmpty) {
        _selectedTrackId = _tracks.first.id;
        _selectedRegionId =
            _tracks.first.regions.isNotEmpty ? _tracks.first.regions.first.id : null;
        _selectedPitchNode = _tracks.first.regions.isNotEmpty &&
                _tracks.first.regions.first.flexPitchNodes.isNotEmpty
            ? _tracks.first.regions.first.flexPitchNodes.first
            : null;
      }
    }
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

  Track? get selectedTrackOrNull {
    if (_tracks.isEmpty) return null;
    if (_selectedTrackId.isEmpty) return _tracks.first;
    for (final track in _tracks) {
      if (track.id == _selectedTrackId) return track;
    }
    return _tracks.first;
  }

  Track get selectedTrack {
    final track = selectedTrackOrNull;
    if (track == null) {
      throw StateError('No track exists in the current project.');
    }
    return track;
  }

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


  // ---------------------------------------------------------------------------
  // Project creation
  // ---------------------------------------------------------------------------

  void initializeProject({
    required String templateId,
    required int bpm,
    required String keySignature,
    required String timeSignature,
    required List<Track> tracks,
  }) {
    _tracks
      ..clear()
      ..addAll(tracks);
    _bpm = bpm;
    _keySignature = keySignature;
    _timeSignature = timeSignature;
    _currentBar = 1.0;
    _totalBars = 64;
    _selectedTrackId = _tracks.isNotEmpty ? _tracks.first.id : '';
    _selectedRegionId = _tracks.isNotEmpty && _tracks.first.regions.isNotEmpty
        ? _tracks.first.regions.first.id
        : null;
    _activeBottomTab = BottomTab.none;
    _isInspectorOpen = false;
    _isLibraryOpen = false;
    _isSmartControlsOpen = false;
    _isMixerOpen = false;
    _renumberTracks();
    notifyListeners();
  }

  void clearProject() {
    _tracks.clear();
    _selectedTrackId = '';
    _selectedRegionId = null;
    _selectedPitchNode = null;
    _currentBar = 1.0;
    notifyListeners();
  }

  void _renumberTracks() {
    for (var i = 0; i < _tracks.length; i++) {
      // Track.trackNumber is final in the current model, so this method is
      // intentionally left as a no-op. New tracks use the correct number.
    }
  }

  void addTrack({
    required String name,
    required TrackType type,
    required IconData icon,
    required Color themeColor,
    List<String>? plugins,
    String? regionName,
    double durationBars = 8.0,
  }) {
    final newId = DateTime.now().microsecondsSinceEpoch.toString();
    final regionId = 'region_$newId';
    final track = Track(
      id: newId,
      trackNumber: _tracks.length + 1,
      name: name,
      type: type,
      icon: icon,
      themeColor: themeColor,
      plugins: plugins,
      regions: [
        AudioRegion(
          id: regionId,
          name: regionName ?? name,
          startBar: 1.0,
          durationBars: durationBars,
          color: themeColor,
        ),
      ],
    );
    _tracks.add(track);
    _selectedTrackId = newId;
    _selectedRegionId = regionId;
    notifyListeners();
  }

  void removeTrack(String trackId) {
    _tracks.removeWhere((track) => track.id == trackId);
    if (_selectedTrackId == trackId) {
      _selectedTrackId = _tracks.isNotEmpty ? _tracks.first.id : '';
      _selectedRegionId = _tracks.isNotEmpty && _tracks.first.regions.isNotEmpty
          ? _tracks.first.regions.first.id
          : null;
    }
    notifyListeners();
  }

  void setProjectLength(int bars) {
    _totalBars = bars.clamp(16, 256);
    if (_currentBar > _totalBars) _currentBar = 1.0;
    notifyListeners();
  }

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

  void toggleMixer() {
    _isMixerOpen = !_isMixerOpen;
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
      name: 'AI • ${_friendlyAiName(trimmed)}',
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


  String _friendlyAiName(String prompt) {
    final normalized = prompt.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 28) return normalized;
    return '${normalized.substring(0, 25)}...';
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
