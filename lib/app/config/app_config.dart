class AppConfig {
  final Flavor flavor;
  final String? openaiApiKey;
  final String? alphaVantageApiKey;
  final String? apiFootballApiKey;
  final String? allSportsApiKey;

  const AppConfig({
    required this.flavor,
    this.openaiApiKey,
    this.alphaVantageApiKey,
    this.apiFootballApiKey,
    this.allSportsApiKey,
  });

  factory AppConfig.fromEnvironment({required Flavor flavor}) {
    return AppConfig(
      flavor: flavor,
      openaiApiKey: _resolveOpenAiApiKey(flavor),
      alphaVantageApiKey: _resolveAlphaVantageApiKey(flavor),
      apiFootballApiKey: _resolveApiFootballApiKey(flavor),
      allSportsApiKey: _resolveAllSportsApiKey(flavor),
    );
  }
}

enum Flavor { dev, prod }

String? _resolveOpenAiApiKey(Flavor flavor) {
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

String? _resolveAlphaVantageApiKey(Flavor flavor) {
  const defaultKey = String.fromEnvironment('ALPHAVANTAGE_API_KEY');
  const devKey = String.fromEnvironment('ALPHAVANTAGE_API_KEY_DEV');
  const prodKey = String.fromEnvironment('ALPHAVANTAGE_API_KEY_PROD');

  final key = switch (flavor) {
    Flavor.dev => devKey.isNotEmpty ? devKey : defaultKey,
    Flavor.prod => prodKey.isNotEmpty ? prodKey : defaultKey,
  };
  if (key.isEmpty) return null;
  return key;
}

String? _resolveApiFootballApiKey(Flavor flavor) {
  const defaultKey = String.fromEnvironment('API_FOOTBALL_API_KEY');
  const devKey = String.fromEnvironment('API_FOOTBALL_API_KEY_DEV');
  const prodKey = String.fromEnvironment('API_FOOTBALL_API_KEY_PROD');

  final key = switch (flavor) {
    Flavor.dev => devKey.isNotEmpty ? devKey : defaultKey,
    Flavor.prod => prodKey.isNotEmpty ? prodKey : defaultKey,
  };
  if (key.isEmpty) return null;
  return key;
}

String? _resolveAllSportsApiKey(Flavor flavor) {
  const defaultKey = String.fromEnvironment('ALLSPORTS_API_KEY');
  const devKey = String.fromEnvironment('ALLSPORTS_API_KEY_DEV');
  const prodKey = String.fromEnvironment('ALLSPORTS_API_KEY_PROD');

  final key = switch (flavor) {
    Flavor.dev => devKey.isNotEmpty ? devKey : defaultKey,
    Flavor.prod => prodKey.isNotEmpty ? prodKey : defaultKey,
  };
  if (key.isEmpty) return null;
  return key;
}
