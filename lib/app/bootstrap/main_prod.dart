import '../app.dart';
import '../config/app_config.dart';

Future<void> main() async {
  await PersonAIApp.bootstrap(
    AppConfig.fromEnvironment(flavor: Flavor.prod),
  );
}
