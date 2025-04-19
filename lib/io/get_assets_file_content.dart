import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> getAssetsFileContent(String assetsFileName) async {
  try {
    final jsonString = await rootBundle.loadString(
      'lib/assets/$assetsFileName',
    );

    return json.decode(jsonString);
  } catch (e) {
    print('Erro ao ler dados de configuração do shee: $e');
    rethrow; // Rejoga a exceção para o chamador saber que houve um erro
  }
}
