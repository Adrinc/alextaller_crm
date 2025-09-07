import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/sucursal_model.dart';
import 'package:nethive_neo/models/talleralex/vw_mapa_sucursales_model.dart';

class SucursalesProvider extends ChangeNotifier {
  List<Sucursal> _sucursales = [];
  List<VwMapaSucursales> _sucursalesMapa = [];
  Sucursal? _sucursalSeleccionada;
  String? _sucursalSeleccionadaId; // Para el mapa
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Sucursal> get sucursales => _sucursales;
  List<VwMapaSucursales> get sucursalesMapa => _sucursalesMapa;
  Sucursal? get sucursalSeleccionada => _sucursalSeleccionada;
  String? get sucursalSeleccionadaId => _sucursalSeleccionadaId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Lista de filas para PlutoGrid
  List<PlutoRow> sucursalesRows = [];

  // Variables para formularios de imagen
  String? imagenFileName;
  Uint8List? imagenToUpload;

  SucursalesProvider() {
    cargarSucursales();
    cargarSucursalesMapa();
  }

  // Cargar todas las sucursales
  Future<void> cargarSucursales() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await supabaseLU
          .from('sucursales')
          .select('*')
          .eq('activa', true) // Solo cargar sucursales activas
          .order('nombre');

      _sucursales = (response as List)
          .map((sucursal) => Sucursal.fromJson(sucursal))
          .toList();

      // Cargar datos del mapa
      await cargarSucursalesMapa();

      // Construir filas para PlutoGrid
      _buildSucursalesRows();

      log('✅ Sucursales cargadas: ${_sucursales.length}');
    } catch (e) {
      _error = 'Error al cargar sucursales: $e';
      log('❌ Error cargando sucursales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar datos específicos para el mapa
  Future<void> cargarSucursalesMapa() async {
    try {
      // Si tenemos sucursales cargadas, filtrar por IDs activos
      List<String> sucursalesActivasIds = _sucursales.map((s) => s.id).toList();

      PostgrestFilterBuilder query =
          supabaseLU.from('vw_mapa_sucursales').select('*');

      // Solo filtrar si tenemos IDs de sucursales activas
      if (sucursalesActivasIds.isNotEmpty) {
        query = query.in_('sucursal_id', sucursalesActivasIds);
      }

      final response = await query.order('sucursal_nombre');

      _sucursalesMapa = (response as List)
          .map((item) => VwMapaSucursales.fromJson(item))
          .toList();

      log('✅ Datos de mapa cargados: ${_sucursalesMapa.length}');

      // Construir filas para PlutoGrid
      _buildSucursalesRows();
    } catch (e) {
      log('❌ Error cargando datos de mapa: $e');
      // Si falla la vista, usar datos básicos de sucursales
      _sucursalesMapa = _sucursales
          .map((s) => VwMapaSucursales(
                sucursalId: s.id,
                nombre: s.nombre,
                imagenUrl: s.imagenUrl,
                direccion: s.direccion,
                lat: s.lat,
                lng: s.lng,
                empleadosActivos: 0,
                reportesTotales: 0,
                citasHoy: 0,
                telefono: s.telefono,
                emailContacto: s.emailContacto,
                capacidadBahias: s.capacidadBahias ?? 0,
              ))
          .toList();
    }
  }

  // Construir filas para PlutoGrid usando datos de VwMapaSucursales
  void _buildSucursalesRows() {
    sucursalesRows.clear();

    for (int i = 0; i < _sucursalesMapa.length; i++) {
      final sucursal = _sucursalesMapa[i];
      sucursalesRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'nombre': PlutoCell(value: sucursal.nombre),
        'telefono': PlutoCell(value: sucursal.telefono ?? ''),
        'email': PlutoCell(value: sucursal.emailContacto ?? ''),
        'direccion': PlutoCell(value: sucursal.direccion ?? ''),
        'empleados_activos': PlutoCell(value: sucursal.empleadosActivos),
        'capacidad_bahias': PlutoCell(value: sucursal.capacidadBahias),
        'reportes_totales': PlutoCell(value: sucursal.reportesTotales),
        'citas_hoy': PlutoCell(value: sucursal.citasHoy),
        'coordenadas': PlutoCell(
            value: sucursal.lat != null && sucursal.lng != null
                ? 'Ubicado'
                : 'Sin ubicar'),
        'gestion': PlutoCell(value: sucursal.sucursalId),
        'acciones': PlutoCell(value: sucursal.sucursalId),
      }));
    }
  }

  // Seleccionar una sucursal
  void seleccionarSucursal(Sucursal sucursal) {
    _sucursalSeleccionada = sucursal;
    _sucursalSeleccionadaId = sucursal.id;
    log('🏢 Sucursal seleccionada: ${sucursal.nombre}');
    notifyListeners();
  }

  // Seleccionar una sucursal por ID (para el sidebar)
  void seleccionarSucursalPorId(String sucursalId) {
    _sucursalSeleccionadaId = sucursalId;
    _sucursalSeleccionada =
        _sucursales.where((s) => s.id == sucursalId).firstOrNull;
    log('🏢 Sucursal seleccionada por ID: $sucursalId');
    notifyListeners();
  }

  // Limpiar selección
  void limpiarSeleccion() {
    _sucursalSeleccionada = null;
    notifyListeners();
  }

  // Crear nueva sucursal
  Future<bool> crearSucursal(Map<String, dynamic> datos) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await supabaseLU.from('sucursales').insert(datos);

      // Recargar todos los datos para asegurar consistencia
      await cargarSucursales();

      log('✅ Sucursal creada');
      return true;
    } catch (e) {
      _error = 'Error al crear sucursal: $e';
      log('❌ Error creando sucursal: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar sucursal
  Future<bool> actualizarSucursal(String id, Map<String, dynamic> datos) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await supabaseLU.from('sucursales').update(datos).eq('id', id);

      // Actualizar en la lista local
      final index = _sucursales.indexWhere((s) => s.id == id);
      if (index != -1) {
        _sucursales[index] =
            Sucursal.fromJson({..._sucursales[index].toJson(), ...datos});
      }

      log('✅ Sucursal actualizada: $id');
      return true;
    } catch (e) {
      _error = 'Error al actualizar sucursal: $e';
      log('❌ Error actualizando sucursal: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar (desactivar) sucursal
  Future<bool> eliminarSucursal(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Actualizar el campo activa a false en la base de datos
      await supabaseLU
          .from('sucursales')
          .update({'activa': false}).eq('id', id);

      // Eliminar de la lista local de sucursales
      _sucursales.removeWhere((s) => s.id == id);

      // Eliminar de la lista local de sucursales mapa
      _sucursalesMapa.removeWhere((s) => s.sucursalId == id);

      // Si era la sucursal seleccionada, limpiar selección
      if (_sucursalSeleccionada?.id == id) {
        _sucursalSeleccionada = null;
        _sucursalSeleccionadaId = null;
      }

      // Reconstruir las filas de PlutoGrid
      _buildSucursalesRows();

      log('✅ Sucursal desactivada: $id');
      return true;
    } catch (e) {
      _error = 'Error al eliminar sucursal: $e';
      log('❌ Error eliminando sucursal: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos para manejo de archivos
  Future<void> selectImagen() async {
    imagenFileName = null;
    imagenToUpload = null;

    FilePickerResult? picker = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (picker != null) {
      var now = DateTime.now();
      var formatter = DateFormat('yyyyMMddHHmmss');
      var timestamp = formatter.format(now);

      imagenFileName = 'sucursal-$timestamp-${picker.files.single.name}';
      imagenToUpload = picker.files.single.bytes;

      // Notificar inmediatamente después de seleccionar
      notifyListeners();
    }
  }

  Future<String?> uploadImagen() async {
    if (imagenToUpload != null && imagenFileName != null) {
      await supabaseLU.storage.from('taller_alex/imagenes').uploadBinary(
            imagenFileName!,
            imagenToUpload!,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );
      return imagenFileName;
    }
    return null;
  }

  void resetFormData() {
    imagenFileName = null;
    imagenToUpload = null;
    notifyListeners();
  }
}
