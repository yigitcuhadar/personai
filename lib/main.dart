import 'app/bootstrap/main_dev.dart' as dev;
import 'app/bootstrap/main_prod.dart' as prod;

Future<void> main() async {
  await dev.main();
}
