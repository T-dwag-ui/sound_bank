import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/editor_view_model.dart';

class SunoPromptDrawer extends StatefulWidget {
  const SunoPromptDrawer({super.key});

  @override
  State<SunoPromptDrawer> createState() => _SunoPromptDrawerState();
}

class _SunoPromptDrawerState extends State<SunoPromptDrawer> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _presetPrompts = [
    '80s Synthwave lead synth with heavy reverb',
    'Lo-Fi chill beats with dusty vinyl crackle',
    'Cyberpunk dark arpeggiated bassline',
    'Epic Orchestral strings crescendo',
    'Futuristic AI Vocoder Vocals',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditorViewModel>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0E27),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
        border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFFEC4899), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Suno AI Music Stem Generator',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => vm.setBottomTab(BottomTab.none),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Preset Prompt Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _presetPrompts.map((preset) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: const Color(0xFF2D163F),
                    side: BorderSide(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
                    label: Text(
                      preset,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    onPressed: () {
                      _controller.text = preset;
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Text Field Input
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Describe music style e.g., "80s Synthwave lead melody with dark bass"...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF12081C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFEC4899), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 14),

          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                elevation: 4,
                shadowColor: const Color(0xFFEC4899).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: vm.isGeneratingAi
                  ? null
                  : () {
                      vm.generateAiTrack(_controller.text);
                    },
              icon: vm.isGeneratingAi
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.bolt, size: 18),
              label: Text(
                vm.isGeneratingAi ? 'Generating Stem...' : 'Generate Stem',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
