import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/editor_view_model.dart';

class AiGeneratorView extends StatefulWidget {
  const AiGeneratorView({super.key});

  @override
  State<AiGeneratorView> createState() => _AiGeneratorViewState();
}

class _AiGeneratorViewState extends State<AiGeneratorView> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _presetPrompts = [
    '80s Synthwave lead synth with heavy reverb',
    'Lo-Fi chill beats with dusty vinyl crackle',
    'Cyberpunk dark arpeggiated bassline',
    'Epic Orchestral strings crescendo',
    'Futuristic AI Vocoder Vocals'
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
      height: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F4), // Dark Violet Studio Plugin Metal
        border: Border(
          top: BorderSide(color: const Color(0xFFEC4899).withValues(alpha: 0.6), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFFEC4899), size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'AURA AI STEM GENERATOR (PLUGIN)',
                style: TextStyle(
                  color: Color.fromARGB(255, 56, 55, 55),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                onPressed: () => vm.setBottomTab(BottomTab.none),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Preset Style Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _presetPrompts.map((preset) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    backgroundColor: const Color(0xFF2C163D),
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

          const SizedBox(height: 10),

          // Prompt Text Input Field
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.black, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Describe music style or instrument stem e.g., "80s Synthwave lead melody"...',
              hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.4), fontSize: 12),
              filled: true,
              fillColor: const Color.fromARGB(255, 232, 230, 234),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: const Color.fromARGB(255, 38, 37, 38).withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: const Color.fromARGB(255, 74, 73, 74).withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color.fromARGB(255, 82, 77, 79), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),

          const Spacer(),

          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: vm.isGeneratingAi
                  ? null
                  : () {
                      vm.generateAiTrack(_controller.text);
                    },
              icon: vm.isGeneratingAi
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.bolt, size: 16),
              label: Text(
                vm.isGeneratingAi ? 'Generating AI Stem...' : 'Generate New Stem',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
