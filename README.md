# personai

## OpenAI API key (secure usage)
- API anahtarını kaynak koda gömmek yerine `dart-define` ile geç: `flutter run -t lib/app/bootstrap/main_dev.dart --dart-define=OPENAI_API_KEY=sk-xxx`.
- Prod derlemesi için flavor bazlı anahtar kullanabilirsin: `flutter build apk -t lib/app/bootstrap/main_prod.dart --dart-define=OPENAI_API_KEY_PROD=sk-xxx`.
- `.env.example` dosyasını kopyalayıp `.env` oluştur, değerlerini doldur ve `flutter run --dart-define-from-file=.env -t lib/app/bootstrap/main_dev.dart` komutuyla anahtarı yükle.
- `AppConfig.fromEnvironment` sırasıyla `OPENAI_API_KEY_DEV`, `OPENAI_API_KEY_PROD` ve `OPENAI_API_KEY` tanımlarını okur; biri doluysa otomatik kullanılır.
- `.env` ve gerçek anahtarların repo'ya girmemesi için `.gitignore` güncellendi.
