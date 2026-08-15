class MusicTheory {
  static const _names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  static const _major = [0, 2, 4, 5, 7, 9, 11];
  static const _minor = [0, 2, 3, 5, 7, 8, 10];

  static String noteName(int midi) => '${_names[midi % 12]}${(midi ~/ 12) - 1}';

  static String detectChord(Iterable<int> pitches) {
    final pcs = pitches.map((p) => p % 12).toSet().toList()..sort();
    if (pcs.length < 2) return '—';
    for (var root = 0; root < 12; root++) {
      final intervals = pcs.map((p) => (p - root + 12) % 12).toSet();
      if (intervals.containsAll({0, 4, 7}) && intervals.length <= 4) return _names[root];
      if (intervals.containsAll({0, 3, 7}) && intervals.length <= 4) return '${_names[root]}m';
      if (intervals.containsAll({0, 3, 6}) && intervals.length <= 4) return '${_names[root]}dim';
      if (intervals.containsAll({0, 4, 7, 11})) return '${_names[root]}maj7';
      if (intervals.containsAll({0, 4, 7, 10})) return '${_names[root]}7';
    }
    return 'Unknown chord';
  }

  static List<String> suggestChords(String key) {
    final match = RegExp(r'^([A-G]#?)\s+(maj|min)$').firstMatch(key);
    if (match == null) return const ['I', 'IV', 'V', 'vi'];
    final root = _names.indexOf(match.group(1)!);
    final scale = match.group(2) == 'min' ? _minor : _major;
    return [0, 3, 4, 5].map((degree) => _names[(root + scale[degree]) % 12]).toList();
  }
}
