import 'package:flutter/material.dart';

enum DawSource { logicPro, garageBand }

class PluginParameter {
  final String name;
  double value; // 0.0 to 1.0 or specific scale
  final double min;
  final double max;
  final String unit;

  PluginParameter({
    required this.name,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.unit = '%',
  });
}

class AudioPluginDefinition {
  final String id;
  final String name;
  final String category; // Instrument, EQ, Dynamics, Reverb, Delay, Modulation, Distortion
  final String description;
  final IconData icon;
  final List<PluginParameter> parameters;

  AudioPluginDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
    required this.parameters,
  });
}

class SoundLibraryPreset {
  final String id;
  final String name;
  final String category; // Drums, Synth, Keys, Strings, Bass, Guitar, Vox, Cinematic
  final DawSource source;
  final IconData icon;
  final Color themeColor;
  final String description;
  final List<String> defaultPlugins;
  final String defaultTrackType; // Audio or MIDI

  const SoundLibraryPreset({
    required this.id,
    required this.name,
    required this.category,
    required this.source,
    required this.icon,
    required this.themeColor,
    required this.description,
    required this.defaultPlugins,
    this.defaultTrackType = 'MIDI',
  });
}

class SoundLibraryData {
  static final List<AudioPluginDefinition> allPlugins = [
    // ────────────────── INSTRUMENTS ──────────────────
    AudioPluginDefinition(
      id: 'alchemy', name: 'Alchemy', category: 'Instrument',
      description: 'Flagship sample-manipulation synthesizer with additive, granular, spectral & virtual analog engines.',
      icon: Icons.blur_on_rounded,
      parameters: [
        PluginParameter(name: 'Cutoff', value: 0.75, unit: 'kHz'),
        PluginParameter(name: 'Resonance', value: 0.40),
        PluginParameter(name: 'Morph XY', value: 0.60),
        PluginParameter(name: 'LFO Rate', value: 0.25, unit: 'Hz'),
      ],
    ),
    AudioPluginDefinition(
      id: 'es2', name: 'ES2 Synthesizer', category: 'Instrument',
      description: 'Powerful 3-oscillator virtual analog synth with vector pad morphing.',
      icon: Icons.graphic_eq_rounded,
      parameters: [
        PluginParameter(name: 'Osc Mix', value: 0.50),
        PluginParameter(name: 'Filter Cutoff', value: 0.65, unit: 'kHz'),
        PluginParameter(name: 'Env Depth', value: 0.40),
      ],
    ),
    AudioPluginDefinition(
      id: 'retro_synth', name: 'Retro Synth', category: 'Instrument',
      description: 'Classic synth with Analog, Sync, Table & FM synthesis modes.',
      icon: Icons.waves_rounded,
      parameters: [
        PluginParameter(name: 'Shape', value: 0.50),
        PluginParameter(name: 'Filter', value: 0.60, unit: 'kHz'),
      ],
    ),
    AudioPluginDefinition(
      id: 'drum_kit_designer', name: 'Drum Kit Designer', category: 'Instrument',
      description: 'Multi-layered acoustic drum kits with full mixing controls.',
      icon: Icons.album_rounded,
      parameters: [
        PluginParameter(name: 'Tuning', value: 0.50, unit: 'st'),
        PluginParameter(name: 'Damping', value: 0.35),
      ],
    ),
    AudioPluginDefinition(
      id: 'drum_machine_designer', name: 'Drum Machine Designer', category: 'Instrument',
      description: 'Electronic drum pad sampler with per-pad processing.',
      icon: Icons.grid_view_rounded,
      parameters: [
        PluginParameter(name: 'Drive', value: 0.35),
        PluginParameter(name: 'Pitch', value: 0.50, unit: 'st'),
        PluginParameter(name: 'Decay', value: 0.65, unit: 's'),
      ],
    ),
    AudioPluginDefinition(
      id: 'vintage_b3', name: 'Vintage B3', category: 'Instrument',
      description: 'Tonewheel organ with rotary Leslie speaker cabinet.',
      icon: Icons.music_note_rounded,
      parameters: [
        PluginParameter(name: 'Rotor Speed', value: 0.80),
        PluginParameter(name: 'Drive', value: 0.30),
      ],
    ),
    AudioPluginDefinition(
      id: 'vintage_ep', name: 'Vintage Electric Piano', category: 'Instrument',
      description: 'Rhodes Mark I/II, Wurlitzer & FM DX7 electric pianos.',
      icon: Icons.piano_rounded,
      parameters: [
        PluginParameter(name: 'Tremolo', value: 0.45),
        PluginParameter(name: 'Chorus Mix', value: 0.30),
      ],
    ),
    AudioPluginDefinition(
      id: 'vintage_clav', name: 'Vintage Clav', category: 'Instrument',
      description: 'Hohner Clavinet D6 with pickup & filter variations.',
      icon: Icons.piano,
      parameters: [
        PluginParameter(name: 'Pickup', value: 0.60),
        PluginParameter(name: 'Filter', value: 0.55),
      ],
    ),
    AudioPluginDefinition(
      id: 'studio_piano', name: 'Studio Grand Piano', category: 'Instrument',
      description: 'Steinway D concert grand sampled with up to 8 velocity layers.',
      icon: Icons.piano_rounded,
      parameters: [
        PluginParameter(name: 'Lid Position', value: 0.80),
        PluginParameter(name: 'Release', value: 0.40),
      ],
    ),
    AudioPluginDefinition(
      id: 'studio_strings', name: 'Studio Strings', category: 'Instrument',
      description: 'Full orchestral string section with legato, spiccato, staccato & tremolo.',
      icon: Icons.music_video_rounded,
      parameters: [
        PluginParameter(name: 'Expression', value: 0.80),
        PluginParameter(name: 'Vibrato', value: 0.40),
      ],
    ),
    AudioPluginDefinition(
      id: 'studio_brass', name: 'Studio Horns', category: 'Instrument',
      description: 'Trumpets, trombones, French horns & tuba with ensemble articulations.',
      icon: Icons.surround_sound_rounded,
      parameters: [
        PluginParameter(name: 'Expression', value: 0.75),
        PluginParameter(name: 'Vibrato', value: 0.30),
      ],
    ),
    AudioPluginDefinition(
      id: 'studio_woodwinds', name: 'Studio Woodwinds', category: 'Instrument',
      description: 'Flute, clarinet, oboe, bassoon with legato & staccato patches.',
      icon: Icons.air_rounded,
      parameters: [
        PluginParameter(name: 'Expression', value: 0.70),
        PluginParameter(name: 'Breath', value: 0.45),
      ],
    ),
    AudioPluginDefinition(
      id: 'evoc_20', name: 'EVOC 20 PolySynth / Vocoder', category: 'Instrument',
      description: 'Classic vocoder with 20-band analysis & synthesis.',
      icon: Icons.record_voice_over_rounded,
      parameters: [
        PluginParameter(name: 'Bands', value: 0.80),
        PluginParameter(name: 'Formant Shift', value: 0.50, unit: 'st'),
      ],
    ),
    AudioPluginDefinition(
      id: 'quick_sampler', name: 'Quick Sampler', category: 'Instrument',
      description: 'Drag-and-drop audio to MIDI sampler with slicing, looping & one-shot modes.',
      icon: Icons.keyboard_rounded,
      parameters: [
        PluginParameter(name: 'Attack', value: 0.02, unit: 's'),
        PluginParameter(name: 'Release', value: 0.50, unit: 's'),
      ],
    ),
    AudioPluginDefinition(
      id: 'sampler', name: 'Sampler (EXS24)', category: 'Instrument',
      description: 'Multi-zone sample-playback instrument with velocity layering.',
      icon: Icons.layers_rounded,
      parameters: [
        PluginParameter(name: 'Filter', value: 0.65, unit: 'kHz'),
        PluginParameter(name: 'Glide', value: 0.15, unit: 's'),
      ],
    ),
    AudioPluginDefinition(
      id: 'ultrabeat', name: 'Ultrabeat', category: 'Instrument',
      description: 'Drum synth & sequencer with FM, sample and physical modelling.',
      icon: Icons.space_dashboard_rounded,
      parameters: [
        PluginParameter(name: 'Volume', value: 0.80),
        PluginParameter(name: 'Pitch', value: 0.50, unit: 'st'),
      ],
    ),
    AudioPluginDefinition(
      id: 'esx24_mellotron', name: 'Mellotron', category: 'Instrument',
      description: 'Classic Mellotron tape-replay sampled flutes, strings & choirs.',
      icon: Icons.audiotrack_rounded,
      parameters: [
        PluginParameter(name: 'Tape Speed', value: 0.50),
        PluginParameter(name: 'Tone', value: 0.60),
      ],
    ),

    // ────────────────── EQ ──────────────────
    AudioPluginDefinition(
      id: 'channel_eq', name: 'Channel EQ', category: 'EQ',
      description: '8-band parametric EQ with real-time FFT analyzer.',
      icon: Icons.equalizer_rounded,
      parameters: [
        PluginParameter(name: 'High Cut', value: 0.90, unit: 'kHz'),
        PluginParameter(name: 'Low Cut', value: 0.10, unit: 'Hz'),
        PluginParameter(name: 'Mid Boost', value: 0.55, unit: 'dB'),
      ],
    ),
    AudioPluginDefinition(
      id: 'linear_phase_eq', name: 'Linear Phase EQ', category: 'EQ',
      description: 'Phase-coherent mastering EQ for transparent tonal shaping.',
      icon: Icons.equalizer_rounded,
      parameters: [
        PluginParameter(name: 'High Shelf', value: 0.65, unit: 'dB'),
        PluginParameter(name: 'Low Shelf', value: 0.40, unit: 'dB'),
      ],
    ),
    AudioPluginDefinition(
      id: 'vintage_eq', name: 'Vintage Console EQ', category: 'EQ',
      description: 'Neve 1073, API 550A & SSL channel-strip EQ models.',
      icon: Icons.tune_rounded,
      parameters: [
        PluginParameter(name: 'HF Boost', value: 0.55, unit: 'dB'),
        PluginParameter(name: 'LF Boost', value: 0.40, unit: 'dB'),
      ],
    ),
    AudioPluginDefinition(
      id: 'match_eq', name: 'Match EQ', category: 'EQ',
      description: 'Analyze a reference track and apply matching EQ curve.',
      icon: Icons.auto_fix_high_rounded,
      parameters: [
        PluginParameter(name: 'Apply Amount', value: 0.80),
        PluginParameter(name: 'Smoothing', value: 0.50),
      ],
    ),

    // ────────────────── DYNAMICS ──────────────────
    AudioPluginDefinition(
      id: 'logic_compressor', name: 'Compressor', category: 'Dynamics',
      description: '7 circuit models: Platinum, VCA, FET, Opto, Vintage VCA, Vintage Opto, Class A.',
      icon: Icons.compress_rounded,
      parameters: [
        PluginParameter(name: 'Threshold', value: 0.40, unit: 'dB'),
        PluginParameter(name: 'Ratio', value: 0.60, unit: ':1'),
        PluginParameter(name: 'Attack', value: 0.20, unit: 'ms'),
        PluginParameter(name: 'Release', value: 0.50, unit: 'ms'),
      ],
    ),
    AudioPluginDefinition(
      id: 'multipressor', name: 'Multipressor', category: 'Dynamics',
      description: 'Multiband compressor with 4 crossover bands.',
      icon: Icons.compress_rounded,
      parameters: [
        PluginParameter(name: 'Band 1 Thresh', value: 0.40, unit: 'dB'),
        PluginParameter(name: 'Band 2 Thresh', value: 0.45, unit: 'dB'),
      ],
    ),
    AudioPluginDefinition(
      id: 'limiter', name: 'Adaptive Limiter', category: 'Dynamics',
      description: 'Brickwall limiter with look-ahead for transparent peak limiting.',
      icon: Icons.vertical_align_top_rounded,
      parameters: [
        PluginParameter(name: 'Gain', value: 0.60, unit: 'dB'),
        PluginParameter(name: 'Out Ceiling', value: 0.97, unit: 'dB'),
      ],
    ),
    AudioPluginDefinition(
      id: 'noise_gate', name: 'Noise Gate', category: 'Dynamics',
      description: 'Gate with sidechain, hysteresis & lookahead.',
      icon: Icons.do_not_disturb_on_rounded,
      parameters: [
        PluginParameter(name: 'Threshold', value: 0.30, unit: 'dB'),
        PluginParameter(name: 'Hold', value: 0.20, unit: 'ms'),
      ],
    ),
    AudioPluginDefinition(
      id: 'deesser', name: 'DeEsser 2', category: 'Dynamics',
      description: 'Intelligent sibilance reduction with spectral display.',
      icon: Icons.mic_off_rounded,
      parameters: [
        PluginParameter(name: 'Sensitivity', value: 0.55),
        PluginParameter(name: 'Frequency', value: 0.70, unit: 'kHz'),
      ],
    ),
    AudioPluginDefinition(
      id: 'enveloper', name: 'Enveloper', category: 'Dynamics',
      description: 'Transient shaper to boost or reduce attack & sustain.',
      icon: Icons.show_chart_rounded,
      parameters: [
        PluginParameter(name: 'Attack Gain', value: 0.60, unit: 'dB'),
        PluginParameter(name: 'Sustain Gain', value: 0.40, unit: 'dB'),
      ],
    ),

    // ────────────────── REVERB ──────────────────
    AudioPluginDefinition(
      id: 'chromaverb', name: 'ChromaVerb', category: 'Reverb',
      description: 'Algorithmic reverb with 14 room models & colorful visualizer.',
      icon: Icons.graphic_eq_rounded,
      parameters: [
        PluginParameter(name: 'Decay', value: 0.60, unit: 's'),
        PluginParameter(name: 'Mix', value: 0.35),
        PluginParameter(name: 'Pre-Delay', value: 0.15, unit: 'ms'),
        PluginParameter(name: 'Damping', value: 0.50),
      ],
    ),
    AudioPluginDefinition(
      id: 'space_designer', name: 'Space Designer', category: 'Reverb',
      description: 'Convolution reverb with 1000+ impulse responses from real spaces.',
      icon: Icons.surround_sound_rounded,
      parameters: [
        PluginParameter(name: 'IR Length', value: 0.70),
        PluginParameter(name: 'Dry/Wet', value: 0.40),
      ],
    ),
    AudioPluginDefinition(
      id: 'silververb', name: 'SilverVerb', category: 'Reverb',
      description: 'Lightweight algorithmic reverb with modulation.',
      icon: Icons.blur_circular_rounded,
      parameters: [
        PluginParameter(name: 'Room Size', value: 0.55),
        PluginParameter(name: 'Mix', value: 0.30),
      ],
    ),

    // ────────────────── DELAY ──────────────────
    AudioPluginDefinition(
      id: 'stereo_delay', name: 'Stereo Delay', category: 'Delay',
      description: 'Dual-channel tempo-synced delay with filter & cross-feedback.',
      icon: Icons.hourglass_bottom_rounded,
      parameters: [
        PluginParameter(name: 'Left', value: 0.25, unit: '1/8d'),
        PluginParameter(name: 'Right', value: 0.33, unit: '1/4'),
        PluginParameter(name: 'Feedback', value: 0.40),
      ],
    ),
    AudioPluginDefinition(
      id: 'tape_delay', name: 'Tape Delay', category: 'Delay',
      description: 'Vintage analog tape echo with wow, flutter & saturation.',
      icon: Icons.album_rounded,
      parameters: [
        PluginParameter(name: 'Time', value: 0.45, unit: 'ms'),
        PluginParameter(name: 'Flutter', value: 0.20),
        PluginParameter(name: 'Saturation', value: 0.35),
      ],
    ),
    AudioPluginDefinition(
      id: 'echo', name: 'Echo', category: 'Delay',
      description: 'Simple mono/stereo echo with filter.',
      icon: Icons.replay_rounded,
      parameters: [
        PluginParameter(name: 'Time', value: 0.40, unit: 'ms'),
        PluginParameter(name: 'Repeats', value: 0.50),
      ],
    ),
    AudioPluginDefinition(
      id: 'delay_designer', name: 'Delay Designer', category: 'Delay',
      description: 'Multi-tap delay with up to 26 independent taps.',
      icon: Icons.timeline_rounded,
      parameters: [
        PluginParameter(name: 'Taps', value: 0.60),
        PluginParameter(name: 'Mix', value: 0.40),
      ],
    ),

    // ────────────────── MODULATION ──────────────────
    AudioPluginDefinition(
      id: 'chorus', name: 'Chorus', category: 'Modulation',
      description: 'Classic stereo chorus with rate & depth.',
      icon: Icons.waves_rounded,
      parameters: [
        PluginParameter(name: 'Rate', value: 0.35, unit: 'Hz'),
        PluginParameter(name: 'Mix', value: 0.45),
      ],
    ),
    AudioPluginDefinition(
      id: 'flanger', name: 'Flanger', category: 'Modulation',
      description: 'Jet-swoosh flanging effect with feedback.',
      icon: Icons.waves_rounded,
      parameters: [
        PluginParameter(name: 'Rate', value: 0.30, unit: 'Hz'),
        PluginParameter(name: 'Feedback', value: 0.60),
      ],
    ),
    AudioPluginDefinition(
      id: 'phaser', name: 'Phaser', category: 'Modulation',
      description: 'Multi-stage phase shifter with warm sweep.',
      icon: Icons.waves_rounded,
      parameters: [
        PluginParameter(name: 'Rate', value: 0.25, unit: 'Hz'),
        PluginParameter(name: 'Stages', value: 0.50),
      ],
    ),
    AudioPluginDefinition(
      id: 'tremolo', name: 'Tremolo', category: 'Modulation',
      description: 'Amplitude modulation with multiple waveform shapes.',
      icon: Icons.show_chart_rounded,
      parameters: [
        PluginParameter(name: 'Rate', value: 0.40, unit: 'Hz'),
        PluginParameter(name: 'Depth', value: 0.70),
      ],
    ),
    AudioPluginDefinition(
      id: 'ringshifter', name: 'Ringshifter', category: 'Modulation',
      description: 'Ring modulator & frequency shifter for metallic textures.',
      icon: Icons.change_circle_rounded,
      parameters: [
        PluginParameter(name: 'Frequency', value: 0.50, unit: 'Hz'),
        PluginParameter(name: 'Mix', value: 0.35),
      ],
    ),
    AudioPluginDefinition(
      id: 'ensemble', name: 'Ensemble (Rotor Cabinet)', category: 'Modulation',
      description: 'Leslie rotary speaker simulation for organ & guitar.',
      icon: Icons.autorenew_rounded,
      parameters: [
        PluginParameter(name: 'Speed', value: 0.70),
        PluginParameter(name: 'Drive', value: 0.30),
      ],
    ),

    // ────────────────── DISTORTION & AMPS ──────────────────
    AudioPluginDefinition(
      id: 'amp_designer', name: 'Amp Designer', category: 'Guitar/Amp',
      description: '25 guitar amp models, 25 cabinets, 3 mic types & positions.',
      icon: Icons.speaker_rounded,
      parameters: [
        PluginParameter(name: 'Gain', value: 0.70),
        PluginParameter(name: 'Bass', value: 0.50),
        PluginParameter(name: 'Treble', value: 0.65),
        PluginParameter(name: 'Presence', value: 0.45),
      ],
    ),
    AudioPluginDefinition(
      id: 'bass_amp_designer', name: 'Bass Amp Designer', category: 'Guitar/Amp',
      description: '3 bass amp models with DI blend & cabinet simulation.',
      icon: Icons.speaker_group_rounded,
      parameters: [
        PluginParameter(name: 'Drive', value: 0.60),
        PluginParameter(name: 'Compressor', value: 0.45),
      ],
    ),
    AudioPluginDefinition(
      id: 'pedalboard', name: 'Pedalboard', category: 'Guitar/Amp',
      description: '35 stompbox pedals: wah, fuzz, overdrive, chorus, delay & more.',
      icon: Icons.settings_input_svideo_rounded,
      parameters: [
        PluginParameter(name: 'Drive', value: 0.55),
        PluginParameter(name: 'Tone', value: 0.60),
      ],
    ),
    AudioPluginDefinition(
      id: 'overdrive', name: 'Overdrive', category: 'Distortion',
      description: 'Tube-style warm overdrive saturation.',
      icon: Icons.flash_on_rounded,
      parameters: [
        PluginParameter(name: 'Drive', value: 0.50),
        PluginParameter(name: 'Tone', value: 0.55),
      ],
    ),
    AudioPluginDefinition(
      id: 'distortion', name: 'Distortion', category: 'Distortion',
      description: 'Hard-clipping distortion with tone control.',
      icon: Icons.flash_on_rounded,
      parameters: [
        PluginParameter(name: 'Drive', value: 0.65),
        PluginParameter(name: 'Tone', value: 0.50),
      ],
    ),
    AudioPluginDefinition(
      id: 'bitcrusher', name: 'Bitcrusher', category: 'Distortion',
      description: 'Lo-fi bit-depth & sample-rate reduction.',
      icon: Icons.broken_image_rounded,
      parameters: [
        PluginParameter(name: 'Resolution', value: 0.30, unit: 'bit'),
        PluginParameter(name: 'Downsampling', value: 0.40),
      ],
    ),
    AudioPluginDefinition(
      id: 'clip_distortion', name: 'Clip Distortion', category: 'Distortion',
      description: 'Non-linear waveshaping distortion.',
      icon: Icons.content_cut_rounded,
      parameters: [
        PluginParameter(name: 'Drive', value: 0.55),
        PluginParameter(name: 'Mix', value: 0.40),
      ],
    ),

    // ────────────────── UTILITY & METERING ──────────────────
    AudioPluginDefinition(
      id: 'gain', name: 'Gain', category: 'Utility',
      description: 'Simple gain, phase invert & balance control.',
      icon: Icons.tune_rounded,
      parameters: [
        PluginParameter(name: 'Gain', value: 0.50, unit: 'dB'),
      ],
    ),
    AudioPluginDefinition(
      id: 'exciter', name: 'Exciter', category: 'Utility',
      description: 'Harmonic exciter for adding presence & sparkle.',
      icon: Icons.auto_awesome_rounded,
      parameters: [
        PluginParameter(name: 'Frequency', value: 0.70, unit: 'kHz'),
        PluginParameter(name: 'Amount', value: 0.40),
      ],
    ),
    AudioPluginDefinition(
      id: 'stereo_spread', name: 'Stereo Spread', category: 'Utility',
      description: 'Frequency-dependent stereo widening.',
      icon: Icons.open_in_full_rounded,
      parameters: [
        PluginParameter(name: 'Amount', value: 0.60),
        PluginParameter(name: 'Freq', value: 0.50, unit: 'kHz'),
      ],
    ),
    AudioPluginDefinition(
      id: 'direction_mixer', name: 'Direction Mixer', category: 'Utility',
      description: 'Mid-side encoding/decoding & stereo balance.',
      icon: Icons.swap_horiz_rounded,
      parameters: [
        PluginParameter(name: 'Spread', value: 0.50),
        PluginParameter(name: 'Direction', value: 0.50),
      ],
    ),
    AudioPluginDefinition(
      id: 'pitch_correction', name: 'Pitch Correction', category: 'Utility',
      description: 'Real-time chromatic & scale-based pitch correction.',
      icon: Icons.mic_external_on_rounded,
      parameters: [
        PluginParameter(name: 'Response', value: 0.65, unit: 'ms'),
        PluginParameter(name: 'Amount', value: 0.80),
      ],
    ),
    AudioPluginDefinition(
      id: 'loudness_meter', name: 'Loudness Meter', category: 'Metering',
      description: 'LUFS integrated, short-term & momentary loudness metering.',
      icon: Icons.speed_rounded,
      parameters: [
        PluginParameter(name: 'Target LUFS', value: 0.58, unit: 'LUFS'),
      ],
    ),
    AudioPluginDefinition(
      id: 'multimeter', name: 'MultiMeter', category: 'Metering',
      description: 'Analyzer, goniometer, level meter & correlation meter.',
      icon: Icons.analytics_rounded,
      parameters: [],
    ),
  ];

  static final List<SoundLibraryPreset> presets = [
    // ────── LOGIC PRO DRUMS ──────
    const SoundLibraryPreset(
      id: 'lp_d1', name: 'SoCal Producer Kit', category: 'Drums', source: DawSource.logicPro,
      icon: Icons.grid_view_rounded, themeColor: Color(0xFFF59E0B),
      description: 'Warm analog studio drum kit recorded in Los Angeles.',
      defaultPlugins: ['Drum Kit Designer', 'Compressor', 'Channel EQ'], defaultTrackType: 'Audio',
    ),
    const SoundLibraryPreset(
      id: 'lp_d2', name: 'Cyberpunk 808 Trap Kit', category: 'Drums', source: DawSource.logicPro,
      icon: Icons.space_dashboard_rounded, themeColor: Color(0xFF06B6D4),
      description: 'Heavy sub-bass kicks, crisp snares & pitched hi-hats.',
      defaultPlugins: ['Drum Machine Designer', 'Overdrive', 'Stereo Delay'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_d3', name: 'Brooklyn Hip Hop Kit', category: 'Drums', source: DawSource.logicPro,
      icon: Icons.grid_view_rounded, themeColor: Color(0xFFEAB308),
      description: 'Boom-bap drums with vinyl-sampled snares & kicks.',
      defaultPlugins: ['Drum Machine Designer', 'Compressor', 'Tape Delay'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_d4', name: 'Modern R&B Producer Kit', category: 'Drums', source: DawSource.logicPro,
      icon: Icons.grid_view_rounded, themeColor: Color(0xFFD97706),
      description: 'Tight, tuned drums with layered claps & snaps.',
      defaultPlugins: ['Drum Machine Designer', 'Compressor', 'Channel EQ'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_d5', name: 'East Bay Drummer', category: 'Drums', source: DawSource.logicPro,
      icon: Icons.album_rounded, themeColor: Color(0xFFF97316),
      description: 'Funky acoustic kit with overhead mics & room tone.',
      defaultPlugins: ['Drum Kit Designer', 'ChromaVerb'], defaultTrackType: 'Audio',
    ),

    // ────── GARAGEBAND DRUMS ──────
    const SoundLibraryPreset(
      id: 'gb_d1', name: 'GarageBand Stadium Rock Kit', category: 'Drums', source: DawSource.garageBand,
      icon: Icons.album_rounded, themeColor: Color(0xFFEF4444),
      description: 'Punchy arena drums with ambient room reverb.',
      defaultPlugins: ['Drum Kit Designer', 'ChromaVerb'], defaultTrackType: 'Audio',
    ),
    const SoundLibraryPreset(
      id: 'gb_d2', name: 'GarageBand Bluebird Kit', category: 'Drums', source: DawSource.garageBand,
      icon: Icons.album_rounded, themeColor: Color(0xFF38BDF8),
      description: 'Vintage jazz brush kit with warm overhead tone.',
      defaultPlugins: ['Drum Kit Designer', 'Space Designer'], defaultTrackType: 'Audio',
    ),
    const SoundLibraryPreset(
      id: 'gb_d3', name: 'GarageBand EDM Beat Machine', category: 'Drums', source: DawSource.garageBand,
      icon: Icons.space_dashboard_rounded, themeColor: Color(0xFFA855F7),
      description: 'Festival-ready electronic drum patterns & fills.',
      defaultPlugins: ['Drum Machine Designer', 'Compressor'], defaultTrackType: 'MIDI',
    ),

    // ────── LOGIC PRO SYNTHS ──────
    const SoundLibraryPreset(
      id: 'lp_s1', name: 'Alchemy Evolving Ambient Pad', category: 'Synth', source: DawSource.logicPro,
      icon: Icons.blur_on_rounded, themeColor: Color(0xFF10B981),
      description: 'Deep lush atmospheric pad with granular motion.',
      defaultPlugins: ['Alchemy', 'ChromaVerb', 'Stereo Delay'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_s2', name: 'ES2 80s Synthwave Lead', category: 'Synth', source: DawSource.logicPro,
      icon: Icons.waves_rounded, themeColor: Color(0xFF22C55E),
      description: 'Iconic retro sawtooth lead with tape chorus.',
      defaultPlugins: ['ES2 Synthesizer', 'Chorus', 'Tape Delay'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_s3', name: 'Retro Synth FM Bells', category: 'Synth', source: DawSource.logicPro,
      icon: Icons.waves_rounded, themeColor: Color(0xFF6EE7B7),
      description: 'DX7-style crystalline FM bell tones.',
      defaultPlugins: ['Retro Synth', 'ChromaVerb'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_s4', name: 'Alchemy Cinematic Tension Drone', category: 'Synth', source: DawSource.logicPro,
      icon: Icons.blur_on_rounded, themeColor: Color(0xFF059669),
      description: 'Dark atmospheric tension drones for film scoring.',
      defaultPlugins: ['Alchemy', 'Space Designer'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_s5', name: 'Alchemy Cyberpunk Pluck Lead', category: 'Synth', source: DawSource.logicPro,
      icon: Icons.blur_on_rounded, themeColor: Color(0xFF34D399),
      description: 'Bright aggressive pluck synth for electronic leads.',
      defaultPlugins: ['Alchemy', 'Stereo Delay', 'Distortion'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_s6', name: 'ES2 Supersaw Trance Stack', category: 'Synth', source: DawSource.logicPro,
      icon: Icons.graphic_eq_rounded, themeColor: Color(0xFF14B8A6),
      description: 'Massive detuned supersaw stack for trance anthems.',
      defaultPlugins: ['ES2 Synthesizer', 'Chorus', 'ChromaVerb'], defaultTrackType: 'MIDI',
    ),

    // ────── GARAGEBAND SYNTHS ──────
    const SoundLibraryPreset(
      id: 'gb_s1', name: 'GarageBand Modern Synth Bass', category: 'Synth', source: DawSource.garageBand,
      icon: Icons.waves_rounded, themeColor: Color(0xFF0D9488),
      description: 'Punchy mono synth bass for pop & dance tracks.',
      defaultPlugins: ['Retro Synth', 'Compressor'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'gb_s2', name: 'GarageBand Chillwave Pad', category: 'Synth', source: DawSource.garageBand,
      icon: Icons.blur_on_rounded, themeColor: Color(0xFF5EEAD4),
      description: 'Warm detuned analog pad with tape wobble.',
      defaultPlugins: ['Retro Synth', 'Chorus', 'ChromaVerb'], defaultTrackType: 'MIDI',
    ),

    // ────── LOGIC PRO KEYS ──────
    const SoundLibraryPreset(
      id: 'lp_k1', name: 'Steinway Grand Piano', category: 'Keys', source: DawSource.logicPro,
      icon: Icons.piano_rounded, themeColor: Color(0xFF3B82F6),
      description: 'Concert grand piano with full dynamic range.',
      defaultPlugins: ['Studio Grand Piano', 'ChromaVerb'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_k2', name: 'Vintage B3 Organ Groove', category: 'Keys', source: DawSource.logicPro,
      icon: Icons.music_note_rounded, themeColor: Color(0xFF84CC16),
      description: 'Full drawbar organ with fast Leslie rotor.',
      defaultPlugins: ['Vintage B3', 'Ensemble (Rotor Cabinet)', 'Channel EQ'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_k3', name: 'Vintage Electric Piano Mark II', category: 'Keys', source: DawSource.logicPro,
      icon: Icons.piano_rounded, themeColor: Color(0xFF2563EB),
      description: 'Rhodes Mark II with stereo tremolo & warm drive.',
      defaultPlugins: ['Vintage Electric Piano', 'Chorus', 'Tape Delay'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_k4', name: 'Wurlitzer Electric Piano', category: 'Keys', source: DawSource.logicPro,
      icon: Icons.piano,  themeColor: Color(0xFF60A5FA),
      description: 'Classic Wurly with built-in tremolo & bite.',
      defaultPlugins: ['Vintage Electric Piano', 'Overdrive'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_k5', name: 'Vintage Clav Funk', category: 'Keys', source: DawSource.logicPro,
      icon: Icons.piano,  themeColor: Color(0xFF818CF8),
      description: 'Hohner Clavinet D6 with wah auto-filter.',
      defaultPlugins: ['Vintage Clav', 'Phaser', 'Amp Designer'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_k6', name: 'Mellotron Flutes & Strings', category: 'Keys', source: DawSource.logicPro,
      icon: Icons.audiotrack_rounded, themeColor: Color(0xFF93C5FD),
      description: 'Iconic 60s tape-replay mellotron sounds.',
      defaultPlugins: ['Mellotron', 'ChromaVerb'], defaultTrackType: 'MIDI',
    ),

    // ────── GARAGEBAND KEYS ──────
    const SoundLibraryPreset(
      id: 'gb_k1', name: 'GarageBand Classic Suitcase', category: 'Keys', source: DawSource.garageBand,
      icon: Icons.piano, themeColor: Color(0xFF14B8A6),
      description: 'Warm electric piano with vintage stereo tremolo.',
      defaultPlugins: ['Vintage Electric Piano', 'Chorus'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'gb_k2', name: 'GarageBand Bright Grand', category: 'Keys', source: DawSource.garageBand,
      icon: Icons.piano_rounded, themeColor: Color(0xFF7DD3FC),
      description: 'Bright pop grand piano for singer-songwriter tracks.',
      defaultPlugins: ['Studio Grand Piano', 'Channel EQ'], defaultTrackType: 'MIDI',
    ),

    // ────── LOGIC PRO STRINGS & ORCHESTRAL ──────
    const SoundLibraryPreset(
      id: 'lp_o1', name: 'Studio Strings Ensemble', category: 'Strings', source: DawSource.logicPro,
      icon: Icons.music_video_rounded, themeColor: Color(0xFF3B82F6),
      description: 'Full 50-piece orchestral string section.',
      defaultPlugins: ['Studio Strings', 'Space Designer', 'Channel EQ'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_o2', name: 'Studio Horns Section', category: 'Strings', source: DawSource.logicPro,
      icon: Icons.surround_sound_rounded, themeColor: Color(0xFF1D4ED8),
      description: 'Trumpet, trombone & French horn brass section.',
      defaultPlugins: ['Studio Horns', 'ChromaVerb'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'lp_o3', name: 'Cinematic Woodwinds Ensemble', category: 'Strings', source: DawSource.logicPro,
      icon: Icons.air_rounded, themeColor: Color(0xFF4F46E5),
      description: 'Flute, clarinet, oboe & bassoon for film scoring.',
      defaultPlugins: ['Studio Woodwinds', 'ChromaVerb', 'Channel EQ'], defaultTrackType: 'MIDI',
    ),
    const SoundLibraryPreset(
      id: 'gb_o1', name: 'GarageBand Cinematic Cello Solo', category: 'Strings', source: DawSource.garageBand,
      icon: Icons.graphic_eq_rounded, themeColor: Color(0xFF6366F1),
      description: 'Expressive solo cello with natural vibrato.',
      defaultPlugins: ['Studio Strings', 'ChromaVerb'], defaultTrackType: 'MIDI',
    ),

    // ────── LOGIC PRO GUITAR & BASS ──────
    const SoundLibraryPreset(
      id: 'lp_g1', name: 'Amp Designer British Stack', category: 'Guitar', source: DawSource.logicPro,
      icon: Icons.speaker_rounded, themeColor: Color(0xFF8B5CF6),
      description: 'High-gain British tube head & 4x12 cab.',
      defaultPlugins: ['Amp Designer', 'Stereo Delay', 'Compressor'], defaultTrackType: 'Audio',
    ),
    const SoundLibraryPreset(
      id: 'lp_g2', name: 'Clean Sparkle Amp', category: 'Guitar', source: DawSource.logicPro,
      icon: Icons.speaker_rounded, themeColor: Color(0xFFA78BFA),
      description: 'Pristine clean Fender-style amp with spring reverb.',
      defaultPlugins: ['Amp Designer', 'ChromaVerb'], defaultTrackType: 'Audio',
    ),
    const SoundLibraryPreset(
      id: 'lp_g3', name: 'Pedalboard Ambient Guitar', category: 'Guitar', source: DawSource.logicPro,
      icon: Icons.settings_input_svideo_rounded, themeColor: Color(0xFFC084FC),
      description: 'Shimmer reverb, modulated delay & chorus pedalboard.',
      defaultPlugins: ['Pedalboard', 'ChromaVerb', 'Stereo Delay'], defaultTrackType: 'Audio',
    ),
    const SoundLibraryPreset(
      id: 'lp_b1', name: 'Slap Funk Bass', category: 'Bass', source: DawSource.logicPro,
      icon: Icons.graphic_eq, themeColor: Color(0xFFD946EF),
      description: 'Punchy active slap bass with sub-boost.',
      defaultPlugins: ['Bass Amp Designer', 'Compressor'], defaultTrackType: 'Audio',
    ),
    const SoundLibraryPreset(
      id: 'lp_b2', name: 'Fingerstyle Jazz Bass', category: 'Bass', source: DawSource.logicPro,
      icon: Icons.graphic_eq, themeColor: Color(0xFFE879F9),
      description: 'Warm round-wound jazz bass with flat wound option.',
      defaultPlugins: ['Bass Amp Designer', 'Channel EQ'], defaultTrackType: 'Audio',
    ),
    const SoundLibraryPreset(
      id: 'gb_b1', name: 'GarageBand Deep 808 Sub Bass', category: 'Bass', source: DawSource.garageBand,
      icon: Icons.subtitles_rounded, themeColor: Color(0xFFEC4899),
      description: 'Clean sine-wave sub bass for Hip Hop & R&B.',
      defaultPlugins: ['Retro Synth', 'Compressor'], defaultTrackType: 'MIDI',
    ),

    // ────── VOCALS / CHOIRS ──────
    const SoundLibraryPreset(
      id: 'lp_v1', name: 'EVOC Vocoder Vox', category: 'Vox', source: DawSource.logicPro,
      icon: Icons.record_voice_over_rounded, themeColor: Color(0xFF4F46E5),
      description: 'Robotic vocoder harmonies synced to MIDI.',
      defaultPlugins: ['EVOC 20 PolySynth / Vocoder', 'Channel EQ', 'ChromaVerb'], defaultTrackType: 'Audio',
    ),
    const SoundLibraryPreset(
      id: 'lp_v2', name: 'Lead Vocal Chain', category: 'Vox', source: DawSource.logicPro,
      icon: Icons.mic_rounded, themeColor: Color(0xFF6366F1),
      description: 'Professional vocal chain: EQ, compression, de-ess, reverb.',
      defaultPlugins: ['Channel EQ', 'Compressor', 'DeEsser 2', 'ChromaVerb'], defaultTrackType: 'Audio',
    ),
    const SoundLibraryPreset(
      id: 'gb_v1', name: 'GarageBand Vocal Harmonizer', category: 'Vox', source: DawSource.garageBand,
      icon: Icons.mic, themeColor: Color(0xFF818CF8),
      description: 'Auto-harmony vocal doubler with pitch correction.',
      defaultPlugins: ['Pitch Correction', 'ChromaVerb'], defaultTrackType: 'Audio',
    ),
  ];
}
