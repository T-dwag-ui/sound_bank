import 'package:flutter/material.dart';
// import 'package:music_editor_app/lib/widgets/timeline_view.dart';
import 'package:music_editor_app/views/widgets/sound_library_browser%20copy.dart';
import 'package:music_editor_app/views/widgets/timeline_view.dart';
import 'package:provider/provider.dart';
import '../view_models/editor_view_model.dart';
import 'widgets/transport_bar.dart';
import 'widgets/inspector_panel.dart';
import 'widgets/track_header.dart';
import 'widgets/audio_sampler_view.dart';
import 'widgets/ai_mastering_view.dart';
import 'widgets/flex_pitch_view.dart';
import 'widgets/ai_generator_view.dart';
import 'widgets/sound_library_browser.dart';
import 'widgets/sound_library_browser.dart';

class MusicEditorScreen extends StatelessWidget {
  const MusicEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditorViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFF161618), // Logic Titanium Metal Background
        body: SafeArea(
          child: Column(
            children: [
              // 1. Top Logic Pro Control & LCD Transport Bar
              const TransportBar(),

              // 2. Main DAW Workspace (Inspector + Track Arranger Canvas)
              Expanded(
                child: Consumer<EditorViewModel>(
                  builder: (context, vm, child) {
                    return Column(
                      children: [
                        // Upper Arranger Area
                        Expanded(
                          child: Row(
                            children: [
                              // Left Sound Library Browser Panel
                               if (vm.isLibraryOpen) const SoundLibraryBrowser(),

                              // Left Logic Dual Channel Strip Inspector Panel
                              if (vm.isInspectorOpen) const InspectorPanel(),

                              // Center-Left Track Headers Column (Fixed Width 210px)
                              SizedBox(
                                width: 210,
                                child: Column(
                                  children: [
                                    // Track Header Ruler
                                    Container(
                                      height: 32,
                                      color: const Color(0xFF1E1E22),
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      alignment: Alignment.centerLeft,
                                      child: const Row(
                                        children: [
                                          Icon(Icons.tune_rounded, color: Colors.white54, size: 14),
                                          SizedBox(width: 6),
                                          Text(
                                            'TRACKS',
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Track List Headers
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: vm.tracks.length,
                                        itemBuilder: (context, index) {
                                          return TrackHeaderWidget(
                                            track: vm.tracks[index],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Vertical Separator Line
                              Container(
                                width: 1,
                                color: Colors.black.withValues(alpha: 0.8),
                              ),

                              // Timeline Canvas (Scrollable Grid + Audio/MIDI Waveforms)
                              Expanded(
                                child: TimelineViewWidget(
                                  tracks: vm.tracks,
                                  totalBars: vm.totalBars,
                                  currentBar: vm.currentBar,
                                  zoomLevel: vm.zoomLevel,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. Bottom Multi-Tab Workbench (Sampler, Mastering, Flex Pitch, AI Generator)
                        _buildBottomWorkbench(vm.activeBottomTab),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWorkbench(BottomTab tab) {
    switch (tab) {
      case BottomTab.sampler:
        return const AudioSamplerView();
      case BottomTab.mastering:
        return const AiMasteringView();
      case BottomTab.flexPitch:
        return const FlexPitchView();
      case BottomTab.aiGenerator:
        return const AiGeneratorView();
      case BottomTab.none:
        return const SizedBox.shrink();
    }
  }
}
