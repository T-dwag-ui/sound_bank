# AURA UI redesign

Replace these files in your Flutter project:

lib/main.dart
lib/views/new_song_screen.dart
lib/views/music_editor_screen.dart
lib/view_models/editor_view_model.dart
lib/views/widgets/timeline_view.dart
lib/views/widgets/track_header.dart

The existing sound_library_browser.dart can stay in place. It is now an advanced
browser and is not forced into the default editor layout.

Design changes:
- App launches into New Song instead of directly into a 9-track demo.
- Genre -> starting mode -> template flow.
- Blank projects contain zero tracks.
- Templates create only intentional starter tracks.
- Editor defaults to no inspector, no library, no advanced bottom panel.
- Add Track is contextual and simple.
- AI remains available without dominating the editor.
- Track controls are reduced to name/type/menu.
- Timeline is lighter and less Logic-like.
- Advanced sampler/mastering/pitch tools remain accessible from More.
