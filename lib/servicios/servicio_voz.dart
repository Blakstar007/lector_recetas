import 'package:flutter_tts/flutter_tts.dart';

class ServicioVoz {
  final FlutterTts _flutterTts = FlutterTts();

  ServicioVoz() {
    _configurarVoz();
  }

  Future<void> _configurarVoz() async {
    await _flutterTts.setLanguage('es-MX');
    await _flutterTts.setSpeechRate(0.60);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> hablar(String texto) async {
    if (texto.trim().isEmpty) return;

    final textoParaVoz = _normalizarTextoParaVoz(texto);

    await _flutterTts.stop();
    await _flutterTts.speak(textoParaVoz);
  }

 String _normalizarTextoParaVoz(String texto) {
  var resultado = texto;

  // Corrección de nombres y abreviaturas de ácido fólico.
  resultado = resultado.replaceAll(
    RegExp(
      r'\bac\.?\s*f[oó]lico\b',
      caseSensitive: false,
    ),
    'ácido fólico',
  );

  resultado = resultado.replaceAll(
    RegExp(
      r'\bacido\s+folico\b',
      caseSensitive: false,
    ),
    'ácido fólico',
  );

  resultado = resultado.replaceAll(
    RegExp(
      r'\bácido\s+folico\b',
      caseSensitive: false,
    ),
    'ácido fólico',
  );

  // Unidades de medida.
  resultado = resultado.replaceAllMapped(
    RegExp(r'(?<=\d)\s*mg\b', caseSensitive: false),
    (coincidencia) => ' miligramos',
  );

  resultado = resultado.replaceAllMapped(
    RegExp(r'(?<=\d)\s*mcg\b', caseSensitive: false),
    (coincidencia) => ' microgramos',
  );

  resultado = resultado.replaceAllMapped(
    RegExp(r'(?<=\d)\s*ml\b', caseSensitive: false),
    (coincidencia) => ' mililitros',
  );

  resultado = resultado.replaceAllMapped(
    RegExp(r'(?<=\d)\s*g\b', caseSensitive: false),
    (coincidencia) => ' gramos',
  );

  // Normaliza "h", "hr", "hrs", "hora" y "horas".
  // Después de una cantidad mayor que uno usamos "horas".
  resultado = resultado.replaceAllMapped(
    RegExp(
      r'\b(\d+)\s*(?:h|hr|hrs|hora|horas)\b',
      caseSensitive: false,
    ),
    (coincidencia) {
      final cantidad = coincidencia.group(1);

      return cantidad == '1'
          ? '$cantidad hora'
          : '$cantidad horas';
    },
  );

  // Corrige "dia" y "dias" sin acento.
  resultado = resultado.replaceAll(
    RegExp(r'\bdias\b', caseSensitive: false),
    'días',
  );

  resultado = resultado.replaceAll(
    RegExp(r'\bdia\b', caseSensitive: false),
    'día',
  );

  // Corrige expresiones como "por 7 dia" o "durante 7 dia".
  resultado = resultado.replaceAllMapped(
    RegExp(
      r'\b(por|durante)\s+(\d+)\s+día\b',
      caseSensitive: false,
    ),
    (coincidencia) {
      final preposicion = coincidencia.group(1);
      final cantidad = coincidencia.group(2);

      return cantidad == '1'
          ? '$preposicion $cantidad día'
          : '$preposicion $cantidad días';
    },
  );

  // Limpieza de espacios repetidos.
  resultado = resultado.replaceAll(RegExp(r'\s{2,}'), ' ');

  return resultado.trim();
}

  Future<void> detener() async {
    await _flutterTts.stop();
  }

  Future<void> liberar() async {
    await _flutterTts.stop();
  }
}