import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/track_model.dart';
import '../../view_models/editor_view_model.dart';

class TimelineViewWidget extends StatelessWidget {
  final List<Track> tracks;
  final int totalBars;
  final double currentBar;
  final double zoomLevel;

  const TimelineViewWidget({
    super.key,
    required this.tracks,
    required this.totalBars,
    required this.currentBar,
    required this.zoomLevel,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditorViewModel>();
    final totalWidth = totalBars * zoomLevel;

    return Container(
      color: const Color(0xFFF8F8F5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: totalWidth,
          child: Column(
            children: [
              _Ruler(
                totalBars: totalBars,
                zoomLevel: zoomLevel,
                currentBar: currentBar,
                onTap: vm.updatePlayhead,
              ),
              Expanded(
                child: Stack(
                  children: [
                    _Grid(totalBars: totalBars, zoomLevel: zoomLevel),
                    Column(
                      children: tracks.map((track) {
                        final selected = vm.selectedTrackId == track.id;
                        return Container(
                          height: 62,
                          decoration: BoxDecoration(
                            color: selected ? track.themeColor.withValues(alpha: .035) : null,
                            border: const Border(
                              bottom: BorderSide(color: Color(0xFFE8E8E3)),
                            ),
                          ),
                          child: Stack(
                            children: track.regions.map((region) {
                              final left = (region.startBar - 1) * zoomLevel;
                              final width = (region.durationBars * zoomLevel).clamp(36.0, double.infinity);
                              final regionSelected = vm.selectedRegionId == region.id;

                              return Positioned(
                                left: left,
                                top: 7,
                                bottom: 7,
                                width: width,
                                child: GestureDetector(
                                  onTap: () {
                                    vm.selectTrack(track.id);
                                    vm.selectRegion(region.id);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 120),
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: track.themeColor.withValues(alpha: .72),
                                      borderRadius: BorderRadius.circular(9),
                                      border: Border.all(
                                        color: regionSelected ? const Color(0xFF262626) : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          region.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Expanded(
                                          child: track.type == TrackType.midi || track.type == TrackType.sampler
                                              ? CustomPaint(
                                                  size: Size.infinite,
                                                  painter: _MidiRegionPainter(
                                                    notes: region.midiNotes,
                                                    regionDuration: region.durationBars,
                                                  ),
                                                )
                                              : CustomPaint(
                                                  size: Size.infinite,
                                                  painter: _AudioWaveformPainter(
                                                    waveformPoints: region.waveformPoints,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                    Positioned(
                      left: (currentBar - 1) * zoomLevel,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          width: 1.5,
                          color: const Color(0xFF262626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ruler extends StatelessWidget {
  final int totalBars;
  final double zoomLevel;
  final double currentBar;
  final ValueChanged<double> onTap;

  const _Ruler({
    required this.totalBars,
    required this.zoomLevel,
    required this.currentBar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        onTap((details.localPosition.dx / zoomLevel) + 1);
      },
      child: Container(
        height: 38,
        color: const Color(0xFFFDFDFC),
        child: Stack(
          children: [
            ...List.generate(totalBars, (index) {
              final major = index % 4 == 0;
              return Positioned(
                left: index * zoomLevel,
                width: zoomLevel,
                top: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.only(left: 6, top: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: major ? Colors.black12 : Colors.black.withValues(alpha: .035),
                        width: major ? 1 : .5,
                      ),
                    ),
                  ),
                  child: major
                      ? Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black45),
                        )
                      : null,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final int totalBars;
  final double zoomLevel;

  const _Grid({required this.totalBars, required this.zoomLevel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalBars, (index) {
        return Container(
          width: zoomLevel,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: index % 4 == 3 ? Colors.black12 : Colors.black.withValues(alpha: .035),
                width: index % 4 == 3 ? 1 : .5,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _AudioWaveformPainter extends CustomPainter {
  final List<double> waveformPoints;

  _AudioWaveformPainter({required this.waveformPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformPoints.isEmpty || size.width <= 0 || size.height <= 0) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .72)
      ..strokeWidth = 1.2;

    final middle = size.height / 2;
    final step = size.width / waveformPoints.length;

    for (var i = 0; i < waveformPoints.length; i++) {
      final x = i * step;
      final amplitude = waveformPoints[i] * (middle - 1);
      canvas.drawLine(
        Offset(x, middle - amplitude),
        Offset(x, middle + amplitude),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MidiRegionPainter extends CustomPainter {
  final List<MidiNote> notes;
  final double regionDuration;

  _MidiRegionPainter({required this.notes, required this.regionDuration});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .78);
    if (notes.isEmpty || regionDuration <= 0) {
      for (var i = 0; i < 10; i++) {
        final x = (i / 10) * size.width;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, (i % 3) * size.height / 3, 14, 4),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      return;
    }

    for (final note in notes) {
      final x = (note.startBar / regionDuration) * size.width;
      final width = (note.durationBars / regionDuration) * size.width;
      final y = ((127 - note.pitch) % 16) * (size.height / 16);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, width.clamp(4.0, size.width), 4),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
