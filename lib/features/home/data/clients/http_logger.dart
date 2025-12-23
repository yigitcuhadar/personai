import 'package:http/http.dart' as http;

typedef HttpLogger =
    void Function(String label, Uri uri, http.Response response);
