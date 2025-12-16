class AppConfig {
  final Flavor flavor;

  const AppConfig({required this.flavor});
}

enum Flavor { dev, prod }
