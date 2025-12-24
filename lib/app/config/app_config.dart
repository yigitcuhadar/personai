class AppConfig {
  final Flavor flavor;
  final String? openaiApiKey;
  final String? alphaVantageApiKey;
  final String? allSportsApiKey;
  final String? googleApiKey;
  final String? googleOAuthClientId;

  const AppConfig({
    required this.flavor,
    this.openaiApiKey,
    this.alphaVantageApiKey,
    this.allSportsApiKey,
    this.googleApiKey,
    this.googleOAuthClientId,
  });

  factory AppConfig.fromEnvironment({required Flavor flavor}) {
    return AppConfig(
      flavor: flavor,
      openaiApiKey: _resolveOpenAiApiKey(flavor),
      alphaVantageApiKey: _resolveAlphaVantageApiKey(flavor),
      allSportsApiKey: _resolveAllSportsApiKey(flavor),
      googleApiKey: _resolveGoogleApiKey(flavor),
      googleOAuthClientId: _resolveGoogleOAuthClientId(flavor),
    );
  }
}

enum Flavor { dev, prod }

String? _resolveOpenAiApiKey(Flavor flavor) {
  const defaultKey = String.fromEnvironment('OPENAI_API_KEY');

  return defaultKey.isEmpty ? null : defaultKey;
}

String? _resolveAlphaVantageApiKey(Flavor flavor) {
  const defaultKey = String.fromEnvironment('ALPHAVANTAGE_API_KEY');

  return defaultKey.isEmpty ? null : defaultKey;
}

String? _resolveAllSportsApiKey(Flavor flavor) {
  const defaultKey = String.fromEnvironment('ALLSPORTS_API_KEY');

  return defaultKey.isEmpty ? null : defaultKey;
}

String? _resolveGoogleApiKey(Flavor flavor) {
  const defaultKey = String.fromEnvironment('GOOGLE_API_KEY');

  return defaultKey.isEmpty ? null : defaultKey;
}

String? _resolveGoogleOAuthClientId(Flavor flavor) {
  const defaultKey = String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID');

  return defaultKey.isEmpty ? null : defaultKey;
}