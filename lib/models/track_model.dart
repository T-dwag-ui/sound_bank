import 'package:flutter/material.dart';

enum TrackType { audio, midi, aiGenerated, sampler }

class MidiNote {
  int pitch;
  double startBar;
  double durationBars;
  int velocity;

  MidiNote({
    required this.pitch,
    required this.startBar,
    required this.durationBars,
    this.velocity = 100,
  });
}

class FlexPitchNode {
  final String id;
  final String noteName;
  final int midiNote;
  final double startBar;
  final double durationBars;
  final List<double> pitchDriftCurve;
  double correctionAmount;
  int formantShift;
  int finePitch;

  FlexPitchNode({
    required this.id,
    required this.noteName,
    required this.midiNote,
    required this.startBar,
    required this.durationBars,
    List<double>? pitchDriftCurve,
    this.correctionAmount = 0.0,
    this.formantShift = 0,
    this.finePitch = 0,
  }) : pitchDriftCurve = pitchDriftCurve ?? _generateSamplePitchDrift();

  static List<double> _generateSamplePitchDrift() =>
      [2.0, -8.0, 15.0, 4.0, -3.0, 0.0, 6.0, -10.0, 2.0];
}

class AudioRegion {
  final String id;
  String name;
  double startBar;
  double durationBars;
  final Color color;
  final List<double> waveformPoints;
  final List<MidiNote> midiNotes;
  final List<FlexPitchNode> flexPitchNodes;

  AudioRegion({
    required this.id,
    required this.name,
    required this.startBar,
    required this.durationBars,
    required this.color,
    List<double>? waveformPoints,
    List<MidiNote>? midiNotes,
    List<FlexPitchNode>? flexPitchNodes,
  })  : waveformPoints = waveformPoints ?? _generateSampleWaveform(),
        midiNotes = midiNotes ?? [],
        flexPitchNodes = flexPitchNodes ?? _generateSampleFlexNodes(startBar);

  static List<double> _generateSampleWaveform() {
    final list = <double>[];
    for (int i = 0; i < 40; i++) {
      list.add(0.15 + (0.85 * ((i * 7 + 3) % 13) / 13.0));
    }
    return list;
  }

  static List<FlexPitchNode> _generateSampleFlexNodes(double baseBar) => [
        FlexPitchNode(id: 'fp1', noteName: 'C3', midiNote: 60, startBar: baseBar, durationBars: .75),
        FlexPitchNode(id: 'fp2', noteName: 'D3', midiNote: 62, startBar: baseBar + .75, durationBars: .75),
        FlexPitchNode(id: 'fp3', noteName: 'E3', midiNote: 64, startBar: baseBar + 1.5, durationBars: 1),
        FlexPitchNode(id: 'fp4', noteName: 'G3', midiNote: 67, startBar: baseBar + 2.5, durationBars: 1.25),
        FlexPitchNode(id: 'fp5', noteName: 'A3', midiNote: 69, startBar: baseBar + 3.75, durationBars: 1),
      ];
}

class Track {
  final String id;
  int trackNumber;
  String name;
  final TrackType type;
  final IconData icon;
  final Color themeColor;
  bool isMuted;
  bool isSoloed;
  bool isRecordArmed;
  bool isInputMonitored;
  double volume;
  double pan;
  List<String> plugins;
  List<AudioRegion> regions;

  Track({
    required this.id,
    required this.trackNumber,
    required this.name,
    required this.type,
    required this.icon,
    required this.themeColor,
    this.isMuted = false,
    this.isSoloed = false,
    this.isRecordArmed = false,
    this.isInputMonitored = false,
    this.volume = 0.8,
    this.pan = 0.0,
    List<String>? plugins,
    required this.regions,
  }) : plugins = plugins ?? ['Channel EQ', 'Compressor', 'ChromaVerb'];
}
