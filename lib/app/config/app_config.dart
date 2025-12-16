class AppConfig {
  final Flavor flavor;
  final String? openaiApiKey;

  const AppConfig({
    required this.flavor,
    this.openaiApiKey,
  });
}

enum Flavor { dev, prod }
