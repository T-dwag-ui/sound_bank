import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sound_library_model.dart';
import '../../view_models/editor_view_model.dart';

class SoundLibraryBrowser extends StatefulWidget {
  const SoundLibraryBrowser({super.key});

  @override
  State<SoundLibraryBrowser> createState() => _SoundLibraryBrowserState();
}

class _SoundLibraryBrowserState extends State<SoundLibraryBrowser> {
  String _selectedCategory = 'All';
  DawSource? _selectedSource;
  String _searchQuery = '';
  String? _selectedPresetId;
  String _pluginTab = 'Presets'; // 'Presets' or 'Plugins'

  final List<String> _categories = [
    'All',
    'Drums',
    'Synth',
    'Keys',
    'Strings',
    'Guitar',
    'Bass',
    'Vox',
  ];

  List<SoundLibraryPreset> get _filteredPresets {
    return SoundLibraryData.presets.where((p) {
      if (_selectedCategory != 'All' && p.category != _selectedCategory) return false;
      if (_selectedSource != null && p.source != _selectedSource) return false;
      if (_searchQuery.isNotEmpty &&
          !p.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !p.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  List<AudioPluginDefinition> get _filteredPlugins {
    if (_searchQuery.isEmpty) return SoundLibraryData.allPlugins;
    return SoundLibraryData.allPlugins.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<EditorViewModel>();

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        border: Border(
          right: BorderSide(color: Colors.black.withValues(alpha: 0.7), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // 1. Library Header
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF242428),
              border: Border(
                bottom: BorderSide(color: Colors.black54),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.library_music_rounded, color: Colors.cyanAccent, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'SOUND LIBRARY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white38, size: 16),
                  onPressed: vm.toggleLibrary,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search presets & plugins...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11),
                filled: true,
                fillColor: const Color(0xFF0E0E12),
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 16),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                ),
              ),
            ),
          ),

          // 3. Tab Toggle: Presets / Plugins
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildTabPill('Presets', _pluginTab == 'Presets', () => setState(() => _pluginTab = 'Presets')),
                const SizedBox(width: 4),
                _buildTabPill('Plugins', _pluginTab == 'Plugins', () => setState(() => _pluginTab = 'Plugins')),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // 4. Source Toggle Filter (Logic Pro / GarageBand / All)
          if (_pluginTab == 'Presets')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  _buildSourceChip('All', _selectedSource == null, () => setState(() => _selectedSource = null)),
                  const SizedBox(width: 4),
                  _buildSourceChip(
                    'Logic Pro',
                    _selectedSource == DawSource.logicPro,
                    () => setState(() => _selectedSource = DawSource.logicPro),
                  ),
                  const SizedBox(width: 4),
                  _buildSourceChip(
                    'GarageBand',
                    _selectedSource == DawSource.garageBand,
                    () => setState(() => _selectedSource = DawSource.garageBand),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 6),

          // 5. Category Sidebar + Preset/Plugin List
          Expanded(
            child: _pluginTab == 'Presets' ? _buildPresetsPanel(vm) : _buildPluginsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsPanel(EditorViewModel vm) {
    final presets = _filteredPresets;

    return Row(
      children: [
        // Category Sidebar
        Container(
          width: 70,
          color: const Color(0xFF141416),
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isActive = _selectedCategory == cat;

              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
                    ),
                  ),
                  child: Text(
                    cat,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white60,
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Container(width: 1, color: Colors.black54),

        // Preset List
        Expanded(
          child: presets.isEmpty
              ? const Center(
                  child: Text(
                    'No presets found',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                )
              : ListView.builder(
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    final isSelected = _selectedPresetId == preset.id;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedPresetId = preset.id),
                      onDoubleTap: () {
                        // Load preset into a new track
                        vm.loadPresetAsTrack(preset);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
                            left: BorderSide(
                              color: isSelected ? preset.themeColor : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon Badge
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: preset.themeColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: preset.themeColor.withValues(alpha: 0.5)),
                              ),
                              child: Icon(preset.icon, color: preset.themeColor, size: 14),
                            ),

                            const SizedBox(width: 8),

                            // Name + Source Badge
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    preset.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      _buildSourceBadge(preset.source),
                                      const SizedBox(width: 4),
                                      Text(
                                        preset.defaultTrackType,
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPluginsPanel() {
    final plugins = _filteredPlugins;

    // Group plugins by category
    final Map<String, List<AudioPluginDefinition>> grouped = {};
    for (final plugin in plugins) {
      grouped.putIfAbsent(plugin.category, () => []).add(plugin);
    }

    return ListView(
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: const Color(0xFF1C1C20),
              child: Text(
                entry.key.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            // Plugin Items
            ...entry.value.map((plugin) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(plugin.icon, color: const Color(0xFF38BDF8), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plugin.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            plugin.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        plugin.category,
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTabPill(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF161618),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isActive ? const Color(0xFF60A5FA) : Colors.white12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white60,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceChip(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1E3A5F) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive ? const Color(0xFF38BDF8) : Colors.white12,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.cyanAccent : Colors.white54,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 9,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceBadge(DawSource source) {
    final isLogic = source == DawSource.logicPro;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: isLogic
            ? const Color(0xFF1E3A5F)
            : const Color(0xFF1E3D1E),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        isLogic ? 'Logic Pro' : 'GarageBand',
        style: TextStyle(
          color: isLogic ? Colors.cyanAccent : Colors.greenAccent,
          fontSize: 7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
