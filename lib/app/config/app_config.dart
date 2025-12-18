class AppConfig {
  final Flavor flavor;
  final String? openaiApiKey;

  const AppConfig({
    required this.flavor,
    this.openaiApiKey,
  });

  factory AppConfig.fromEnvironment({required Flavor flavor}) {
    return AppConfig(
      flavor: flavor,
      openaiApiKey: _resolveApiKey(flavor),
    );
  }
}

enum Flavor { dev, prod }

String? _resolveApiKey(Flavor flavor) {
  const defaultKey = String.fromEnvironment('OPENAI_API_KEY');
  const devKey = String.fromEnvironment('OPENAI_API_KEY_DEV');
  const prodKey = String.fromEnvironment('OPENAI_API_KEY_PROD');

  final key = switch (flavor) {
    Flavor.dev => devKey.isNotEmpty ? devKey : defaultKey,
    Flavor.prod => prodKey.isNotEmpty ? prodKey : defaultKey,
  };
  if (key.isEmpty) return null;
  return key;
}
