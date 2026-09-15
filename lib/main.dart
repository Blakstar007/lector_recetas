import 'dart:io';

import 'package:flutter/material.dart';
import 'servicios/servicio_voz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const LectorRecetasApp());
}

// =====================================================
// APLICACIÓN PRINCIPAL
// =====================================================

class LectorRecetasApp extends StatelessWidget {
  const LectorRecetasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lector de Recetas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const PantallaInicio(),
    );
  }
}

// =====================================================
// PANTALLA PRINCIPAL
// =====================================================

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lector de Recetas'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.medical_services_outlined,
                size: 80,
                color: Colors.teal,
              ),

              const SizedBox(height: 20),

              const Text(
                'Comprende tu receta médica',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Toma una fotografía de tu receta y recibe ayuda para leer y comprender sus indicaciones.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 35),

              BotonMenu(
                icono: Icons.camera_alt_outlined,
                texto: 'Leer receta',
                color: Colors.teal,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaLeerReceta(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              BotonMenu(
                icono: Icons.medication_outlined,
                texto: 'Mis medicamentos',
                color: Colors.blue,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Esta sección se agregará más adelante.',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              BotonMenu(
                icono: Icons.alarm_outlined,
                texto: 'Recordatorios',
                color: Colors.orange,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Esta sección se agregará más adelante.',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              BotonMenu(
                icono: Icons.info_outline,
                texto: 'Información importante',
                color: Colors.grey.shade700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PantallaInformacionImportante(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              const Text(
                'Esta aplicación es una herramienta de apoyo. No sustituye al personal médico, no diagnostica y no prescribe medicamentos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// BOTÓN REUTILIZABLE DEL MENÚ
// =====================================================

class BotonMenu extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback onPressed;

  const BotonMenu({
    super.key,
    required this.icono,
    required this.texto,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icono,
          size: 32,
        ),
        label: Text(
          texto,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// PANTALLA PARA LEER LA RECETA
// =====================================================

class PantallaLeerReceta extends StatefulWidget {
  const PantallaLeerReceta({super.key});

  @override
  State<PantallaLeerReceta> createState() => _PantallaLeerRecetaState();
}

class _PantallaLeerRecetaState extends State<PantallaLeerReceta> {
  final ServicioVoz _servicioVoz = ServicioVoz();

  final ImagePicker _selectorImagen = ImagePicker();

  final TextRecognizer _reconocedorTexto = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  XFile? _imagenReceta;

  String _textoReconocido = '';

  bool _leyendoTexto = false;

  bool _procesandoOCR = false;

  // ---------------------------------------------------
  // LEER DATOS IMPORTANTES EN VOZ ALTA
  // ---------------------------------------------------

  Future<void> _leerRecetaEnVozAlta() async {
    if (_textoReconocido.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero debes reconocer una receta.',
          ),
        ),
      );
      return;
    }

    final textoParaLeer = _crearTextoImportanteParaVoz();

    if (textoParaLeer.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se identificaron datos suficientes para realizar la lectura.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _leyendoTexto = true;
    });

    try {
      await _servicioVoz.hablar(textoParaLeer);
    } finally {
      if (mounted) {
        setState(() {
          _leyendoTexto = false;
        });
      }
    }
  }

  // ---------------------------------------------------
  // DETENER LECTURA EN VOZ ALTA
  // ---------------------------------------------------

  Future<void> _detenerLectura() async {
    await _servicioVoz.detener();

    if (mounted) {
      setState(() {
        _leyendoTexto = false;
      });
    }
  }

  // ---------------------------------------------------
  // CREAR TEXTO SEGURO PARA LA LECTURA
  // ---------------------------------------------------

  String _crearTextoImportanteParaVoz() {
  final texto = _textoReconocido;

  String buscarCoincidencia(List<RegExp> patrones) {
    for (final patron in patrones) {
      final coincidencia = patron.firstMatch(texto);

      if (coincidencia != null) {
        return coincidencia.group(0)!.trim();
      }
    }

    return '';
  }

  String detectarMedicamento() {
    final acidoFolico = RegExp(
      r'\b(?:ácido\s+fólico|acido\s+folico|ac\.\s*f[oó]lico|ac\s*f[oó]lico)\b',
      caseSensitive: false,
    ).firstMatch(texto);

    if (acidoFolico != null) {
      return 'ácido fólico';
    }

    final otrosMedicamentos = RegExp(
      r'\b(paracetamol|ibuprofeno|amoxicilina|metformina|omeprazol|losartán|losartan|diclofenaco|naproxeno|azitromicina|insulina)\b',
      caseSensitive: false,
    ).firstMatch(texto);

    if (otrosMedicamentos != null) {
      return otrosMedicamentos.group(0)!.trim();
    }

    return '';
  }

  final medicamento = detectarMedicamento();

  final concentracion = buscarCoincidencia([
    RegExp(
      r'\b\d+(?:[.,]\d+)?\s*(?:mg|g|mcg|ml|mL|gramos?|miligramos?)\b',
      caseSensitive: false,
    ),
  ]);

  final frecuencia = buscarCoincidencia([
    RegExp(
      r'\bcada\s+\d+\s*(?:h|hr|hrs|hora|horas)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(?:una|dos|tres)\s+veces\s+al\s+d[ií]a\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\buna\s+vez\s+al\s+d[ií]a\b',
      caseSensitive: false,
    ),
  ]);

  final duracion = buscarCoincidencia([
    RegExp(
      r'\bdurante\s+\d+\s*(?:d[ií]as?|semanas?|meses?)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bpor\s+\d+\s*(?:d[ií]as?|semanas?|meses?)\b',
      caseSensitive: false,
    ),
  ]);

  final presentacion = buscarCoincidencia([
    RegExp(
      r'\b(tableta|tabletas|cápsula|cápsulas|capsula|capsulas|gotas|jarabe|ampolleta|ampolletas|sobres|solución|solucion)\b',
      caseSensitive: false,
    ),
  ]);

  final partes = <String>[];

  void agregarDato(String titulo, String valor) {
    if (valor.trim().isNotEmpty) {
      partes.add('$titulo: $valor');
    }
  }

  agregarDato('Medicamento', medicamento);
  agregarDato('Concentración', concentracion);
  agregarDato('Frecuencia', frecuencia);
  agregarDato('Duración', duracion);
  agregarDato('Presentación', presentacion);

  if (partes.isEmpty) {
    return '''
No se identificaron con suficiente claridad los datos importantes de la receta.

Consulta la imagen original con un médico o farmacéutico.
''';
  }

  return '''
Lectura de los datos importantes de la receta.

${partes.join('. ')}.

Advertencia: estos datos fueron extraídos de una imagen y pueden contener errores. Confirma siempre el medicamento, la dosis, la frecuencia y la duración con el médico o farmacéutico. No cambies el tratamiento basándote únicamente en esta lectura.
''';
}

  // ---------------------------------------------------
  // BUSCAR UN DATO DENTRO DEL TEXTO RECONOCIDO
  // ---------------------------------------------------

  String _buscarDato(String texto, List<String> patrones) {
    final textoMinusculas = texto.toLowerCase();

    for (final patron in patrones) {
      final posicion = textoMinusculas.indexOf(
        patron.toLowerCase(),
      );

      if (posicion != -1) {
        final textoDesdeCoincidencia = texto.substring(posicion);

        final finLinea = textoDesdeCoincidencia.indexOf('\n');

        if (finLinea != -1) {
          return textoDesdeCoincidencia
              .substring(0, finLinea)
              .trim();
        }

        // Limita el resultado cuando el OCR no devuelve saltos de línea.
        final limite = textoDesdeCoincidencia.length > 80
            ? 80
            : textoDesdeCoincidencia.length;

        return textoDesdeCoincidencia
            .substring(0, limite)
            .trim();
      }
    }

    return 'No identificado con seguridad';
  }

  // ---------------------------------------------------
  // TARJETA PARA MOSTRAR CADA DATO DE LA RECETA
  // ---------------------------------------------------

  Widget _tarjetaDatoRevision(String titulo, String valor) {
  final valorLimpio = valor.trim();

  final noIdentificado = valorLimpio.isEmpty ||
      valorLimpio.toLowerCase() == 'no encontrado' ||
      valorLimpio.toLowerCase() == 'no identificado';

  return Card(
    margin: const EdgeInsets.only(bottom: 10),
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            noIdentificado
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            color: noIdentificado ? Colors.orange : Colors.teal,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  noIdentificado ? 'No identificado' : valorLimpio,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: noIdentificado
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: noIdentificado
                        ? Colors.orange.shade800
                        : Colors.black87,
                  ),
                ),
                if (noIdentificado) ...[
                  const SizedBox(height: 5),
                  const Text(
                    'Verifica este dato en la receta original.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // ---------------------------------------------------
  // MOSTRAR CONFIRMACIÓN DE RECETA
  // ---------------------------------------------------

  void _mostrarConfirmacionReceta() {
    final medicamento = _buscarDato(_textoReconocido, [
      'ácido fólico',
      'acido folico',
      'paracetamol',
      'ibuprofeno',
      'amoxicilina',
      'metformina',
      'omeprazol',
      'losartán',
      'losartan',
      'diclofenaco',
      'naproxeno',
      'azitromicina',
      'insulina',
    ]);

    final concentracion = _buscarDato(_textoReconocido, [
      '0.4 mg',
      '0,4 mg',
      '500 mg',
      '250 mg',
      '100 mg',
      '40 mg',
      '5 mg',
      '10 mg',
      '20 mg',
      '50 mg',
      '1000 mg',
      '5 ml',
      '10 ml',
    ]);

    final via = _buscarDato(_textoReconocido, [
      'oral',
      'intramuscular',
      'intravenosa',
      'intravenoso',
      'sublingual',
      'tópica',
      'topica',
      'cutánea',
      'cutanea',
    ]);

    final frecuencia = _buscarDato(_textoReconocido, [
      'cada 24',
      'cada 12',
      'cada 8',
      'cada 6',
      'cada 4',
      'una vez al día',
      'una vez al dia',
      'dos veces al día',
      'dos veces al dia',
      'tres veces al día',
      'tres veces al dia',
    ]);

    final duracion = _buscarDato(_textoReconocido, [
      'durante',
      'por',
    ]);

    final presentacion = _buscarDato(_textoReconocido, [
      'tableta',
      'tabletas',
      'cápsula',
      'cápsulas',
      'capsula',
      'capsulas',
      'gotas',
      'jarabe',
      'ampolleta',
      'ampolletas',
      'sobres',
      'solución',
      'solucion',
      'envase',
      'caja',
      'frasco',
    ]);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (contexto) {
        return AlertDialog(
          title: const Text(
            'Confirmar receta',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Revisa estos datos comparándolos con la imagen original. La aplicación no modifica las indicaciones médicas.',
                  style: TextStyle(
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 18),

                _datoConfirmacion(
                  'Medicamento',
                  medicamento,
                ),

                _datoConfirmacion(
                  'Concentración',
                  concentracion,
                ),

                _datoConfirmacion(
                  'Vía de administración',
                  via,
                ),

                _datoConfirmacion(
                  'Frecuencia',
                  frecuencia,
                ),

                _datoConfirmacion(
                  'Duración',
                  duracion,
                ),

                _datoConfirmacion(
                  'Presentación',
                  presentacion,
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.amber.shade700,
                    ),
                  ),
                  child: const Text(
                    'Antes de continuar, confirma los datos con el médico o farmacéutico. No cambies dosis, horarios ni duración basándote únicamente en esta lectura.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(contexto).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(contexto).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'La receta fue revisada. El guardado se agregará en el siguiente paso.',
                    ),
                  ),
                );
              },
              child: const Text('Confirmar revisión'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------
  // MOSTRAR DATO EN LA CONFIRMACIÓN
  // ---------------------------------------------------

  Widget _datoConfirmacion(String titulo, String valor) {
    final valorLimpio = valor.trim();

    final noIdentificado =
        valorLimpio.isEmpty ||
        valorLimpio.toLowerCase() == 'no encontrado' ||
        valorLimpio.toLowerCase() == 'no identificado' ||
        valorLimpio.toLowerCase() == 'no identificado con seguridad';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            noIdentificado ? 'No identificado' : valorLimpio,
            style: TextStyle(
              fontSize: 16,
              color: noIdentificado
                  ? Colors.orange.shade800
                  : Colors.black87,
              fontWeight: noIdentificado
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
          if (noIdentificado)
            const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                'Verifica este dato en la receta original.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // SELECCIONAR IMAGEN DESDE CÁMARA O GALERÍA
  // ---------------------------------------------------

  Future<void> _seleccionarImagen(
    ImageSource origen,
  ) async {
    try {
      final XFile? imagen = await _selectorImagen.pickImage(
        source: origen,
        imageQuality: 90,
      );

      if (imagen == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _imagenReceta = imagen;
        _textoReconocido = '';
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo obtener la imagen. Inténtalo nuevamente.',
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------
  // RECONOCER TEXTO DE LA IMAGEN
  // ---------------------------------------------------

  Future<void> _leerTextoDeImagen() async {
    if (_imagenReceta == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _procesandoOCR = true;
      _textoReconocido = '';
    });

    try {
      final InputImage imagenParaLeer = InputImage.fromFilePath(
        _imagenReceta!.path,
      );

      final RecognizedText resultado =
          await _reconocedorTexto.processImage(
        imagenParaLeer,
      );

      if (!mounted) return;

      setState(() {
        _textoReconocido = resultado.text;
        _procesandoOCR = false;
      });

      if (resultado.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se encontró texto claro en la imagen.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _procesandoOCR = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo leer el texto de la imagen.',
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------
  // LIBERAR RECURSOS
  // ---------------------------------------------------

  @override
  void dispose() {
    _servicioVoz.liberar();
    _reconocedorTexto.close();
    super.dispose();
  }

  // ---------------------------------------------------
  // INTERFAZ DE LA PANTALLA
  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leer receta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // ---------------------------------------------------
              // CUANDO TODAVÍA NO HAY IMAGEN
              // ---------------------------------------------------

              if (_imagenReceta == null) ...[
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 90,
                  color: Colors.teal,
                ),

                const SizedBox(height: 24),

                const Text(
                  '¿Cómo deseas agregar tu receta?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Puedes tomar una fotografía de la receta o seleccionar una imagen que ya tengas guardada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  height: 75,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _seleccionarImagen(ImageSource.camera);
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      size: 34,
                    ),
                    label: const Text(
                      'Tomar fotografía',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  height: 75,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _seleccionarImagen(ImageSource.gallery);
                    },
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      size: 34,
                    ),
                    label: const Text(
                      'Elegir de la galería',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ]

              // ---------------------------------------------------
              // CUANDO YA HAY UNA IMAGEN
              // ---------------------------------------------------

              else ...[
                const Text(
                  'Revisa tu fotografía',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(_imagenReceta!.path),
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 65,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _imagenReceta = null;
                        _textoReconocido = '';
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Elegir otra imagen',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 65,
                  child: ElevatedButton.icon(
                    onPressed: _procesandoOCR
                        ? null
                        : _leerTextoDeImagen,
                    icon: _procesandoOCR
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.menu_book_outlined,
                            size: 28,
                          ),
                    label: Text(
                      _procesandoOCR
                          ? 'Analizando receta...'
                          : 'Continuar con la lectura',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.teal.shade300,
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                // ---------------------------------------------------
                // RESULTADO DE LA LECTURA
                // ---------------------------------------------------

                if (_textoReconocido.isNotEmpty) ...[
                  const SizedBox(height: 30),

                  const Text(
                    'Revisión de lectura',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Estos datos fueron localizados automáticamente en el texto de la receta. Deben compararse con la imagen original.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _tarjetaDatoRevision(
                    'Medicamento',
                    _buscarDato(_textoReconocido, [
                      'ácido fólico',
                      'acido folico',
                      'paracetamol',
                      'ibuprofeno',
                      'amoxicilina',
                      'metformina',
                      'omeprazol',
                      'losartán',
                      'losartan',
                      'diclofenaco',
                      'naproxeno',
                      'azitromicina',
                      'insulina',
                    ]),
                  ),

                  _tarjetaDatoRevision(
                    'Concentración',
                    _buscarDato(_textoReconocido, [
                      '0.4 mg',
                      '0,4 mg',
                      '500 mg',
                      '250 mg',
                      '100 mg',
                      '40 mg',
                      '5 mg',
                      '10 mg',
                      '20 mg',
                      '50 mg',
                      '1000 mg',
                      '5 ml',
                      '10 ml',
                    ]),
                  ),

                  _tarjetaDatoRevision(
                    'Vía de administración',
                    _buscarDato(_textoReconocido, [
                      'oral',
                      'intramuscular',
                      'intravenosa',
                      'intravenoso',
                      'sublingual',
                      'tópica',
                      'topica',
                      'cutánea',
                      'cutanea',
                    ]),
                  ),

                  _tarjetaDatoRevision(
                    'Frecuencia',
                    _buscarDato(_textoReconocido, [
                      'cada 24',
                      'cada 12',
                      'cada 8',
                      'cada 6',
                      'cada 4',
                      'una vez al día',
                      'una vez al día',
                      'dos veces al día',
                      'dos veces al día',
                      'tres veces al día',
                      'tres veces al dia',
                    ]),
                  ),

                  _tarjetaDatoRevision(
                    'Duración',
                    _buscarDato(_textoReconocido, [
                      'durante',
                      'por',
                    ]),
                  ),

                  _tarjetaDatoRevision(
                    'Presentación',
                    _buscarDato(_textoReconocido, [
                      'tableta',
                      'tabletas',
                      'cápsula',
                      'cápsulas',
                      'capsula',
                      'capsulas',
                      'gotas',
                      'jarabe',
                      'ampolleta',
                      'ampolletas',
                      'sobres',
                      'solución',
                      'solucion',
                      'envase',
                      'caja',
                      'frasco',
                    ]),
                  ),

                  const SizedBox(height: 12),

                  ExpansionTile(
                    title: const Text(
                      'Ver texto completo detectado',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.all(12),
                    children: [
                      SelectableText(
                        _textoReconocido,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      border: Border.all(
                        color: Colors.amber.shade700,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Importante: la lectura automática puede contener errores. No utilices como confirmadas las dosis, concentraciones, horarios o duraciones que no sean claramente legibles. Si existe alguna duda, consulta al médico o farmacéutico.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                                    SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _mostrarConfirmacionReceta();
                      },
                      icon: const Icon(Icons.medication_outlined),
                      label: const Text(
                        'Registrar esta receta',
                        style: TextStyle(fontSize: 17),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---------------------------------------------------
                  // BOTÓN DE LECTURA / DETENER LECTURA
                  // ---------------------------------------------------

                  if (!_leyendoTexto)
                    SizedBox(
                      height: 65,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _leerRecetaEnVozAlta,
                        icon: const Icon(
                          Icons.volume_up,
                          size: 30,
                        ),
                        label: const Text(
                          'Leer receta en voz alta',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 65,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _detenerLectura,
                        icon: const Icon(
                          Icons.stop,
                          size: 30,
                        ),
                        label: const Text(
                          'Detener lectura',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 35),

                  const Text(
                    'Procura que la receta aparezca completa, enfocada y con buena iluminación. Si alguna indicación no se puede leer con claridad, deberá confirmarse con un profesional de la salud.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// INFORMACIÓN IMPORTANTE
// =====================================================

class PantallaInformacionImportante extends StatelessWidget {
  const PantallaInformacionImportante({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información importante'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.health_and_safety_outlined,
                size: 80,
                color: Colors.teal,
              ),

              const SizedBox(height: 24),

              const Text(
                'Información importante',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              _TarjetaInformacion(
                titulo: 'Herramienta de apoyo',
                texto:
                    'Esta aplicación ayuda a leer y comprender información escrita en una receta médica.',
                icono: Icons.info_outline,
              ),

              const SizedBox(height: 14),

              _TarjetaInformacion(
                titulo: 'No realiza diagnósticos',
                texto:
                    'La aplicación no diagnostica enfermedades ni determina qué medicamento necesita una persona.',
                icono: Icons.medical_information_outlined,
              ),

              const SizedBox(height: 14),

              _TarjetaInformacion(
                titulo: 'No modifica indicaciones',
                texto:
                    'Nunca cambia dosis, horarios, duración o instrucciones indicadas por el personal médico.',
                icono: Icons.warning_amber_outlined,
              ),

              const SizedBox(height: 14),

              _TarjetaInformacion(
                titulo: 'Confirma las dudas',
                texto:
                    'Si la receta está borrosa, incompleta o contiene una indicación dudosa, consulta al médico o farmacéutico.',
                icono: Icons.support_agent_outlined,
              ),

              const SizedBox(height: 30),

              const Text(
                'Ayudar a comprender, nunca inventar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// TARJETA DE INFORMACIÓN
// =====================================================

class _TarjetaInformacion extends StatelessWidget {
  final String titulo;
  final String texto;
  final IconData icono;

  const _TarjetaInformacion({
    required this.titulo,
    required this.texto,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            color: Colors.teal,
            size: 30,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}