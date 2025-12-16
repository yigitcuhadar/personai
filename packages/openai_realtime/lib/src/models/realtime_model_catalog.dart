/// Known realtime-capable model ids, ordered by recency and capability.
const List<String> realtimeModelNames = [
  'gpt-realtime',
  'gpt-realtime-2025-08-28',
  'gpt-realtime-mini-2025-12-15',
  'gpt-realtime-mini-2025-10-06',
  'gpt-realtime-mini',
  'gpt-4o-realtime-preview',
  'gpt-4o-realtime-preview-2025-06-03',
  'gpt-4o-realtime-preview-2024-12-17',
  'gpt-4o-mini-realtime-preview',
  'gpt-4o-mini-realtime-preview-2024-12-17',
];

/// Supported realtime voices. Favorited voices are commonly recommended defaults.
const List<String> realtimeVoiceNames = ['alloy', 'ash', 'ballad', 'coral', 'echo', 'sage', 'shimmer', 'verse', 'marin', 'cedar'];

/// Voices we highlight as preferred defaults in UIs.
const Set<String> realtimeFavoriteVoices = {'marin', 'cedar'};
