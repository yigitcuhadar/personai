import '../app.dart';
import '../config/app_config.dart';

Future<void> main() async {
  await PersonAIApp.bootstrap(
    const AppConfig(
      flavor: Flavor.dev,
      openaiApiKey:
          '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',
    ),
  );
}
