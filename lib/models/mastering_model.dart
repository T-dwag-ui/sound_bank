class EqBand {
  final double frequency; // Hz e.g. 60, 250, 1000, 4000, 12000
  double gainDb; // -12 to +12 dB
  double qFactor;

  EqBand({
    required this.frequency,
    this.gainDb = 0.0,
    this.qFactor = 1.0,
  });
}

class MasteringPreset {
  final String id;
  final String title;
  final String description;
  final double targetLufs;

  const MasteringPreset({
    required this.id,
    required this.title,
    required this.description,
    required this.targetLufs,
  });
}

class MasteringChainState {
  double targetLufs; // e.g. -14.0
  String selectedGenre;
  bool isMastered;
  bool isAbBypass;
  
  // FX Parameters
  double thresholdDb; // Compressor threshold
  double ratio; // Compressor ratio
  double stereoWidth; // 1.0 = normal, 1.5 = wide
  double exciterDrive; // 0.0 to 1.0
  double ceilingDb; // Brickwall Limiter ceiling e.g. -0.3 dB

  List<EqBand> eqBands;

  MasteringChainState({
    this.targetLufs = -14.0,
    this.selectedGenre = 'Hip Hop / Modern Pop',
    this.isMastered = false,
    this.isAbBypass = false,
    this.thresholdDb = -18.0,
    this.ratio = 3.5,
    this.stereoWidth = 1.25,
    this.exciterDrive = 0.3,
    this.ceilingDb = -0.3,
    List<EqBand>? eqBands,
  }) : eqBands = eqBands ?? [
          EqBand(frequency: 60, gainDb: 1.5, qFactor: 0.8),
          EqBand(frequency: 250, gainDb: -1.0, qFactor: 1.2),
          EqBand(frequency: 1000, gainDb: 0.5, qFactor: 1.0),
          EqBand(frequency: 4000, gainDb: 2.0, qFactor: 1.1),
          EqBand(frequency: 12000, gainDb: 2.5, qFactor: 0.7),
        ];
}
