import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'dart:developer' as developer;

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/empleados_globales_models.dart';

class EmpleadosGlobalesProvider extends ChangeNotifier {
  // Estado de carga
  bool _isLoading = false;
  String? _error;

  // Datos principales
  List<EmpleadoGlobalGrid> _empleados = [];
  List<SucursalEmpleado> _sucursales = [];
  List<String> _puestosDisponibles = [];

  // Filtros
  final FiltrosEmpleados _filtros = FiltrosEmpleados();

  // PlutoGrid
  List<PlutoRow> empleadosRows = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<EmpleadoGlobalGrid> get empleados => _empleados;
  List<SucursalEmpleado> get sucursales => _sucursales;
  List<String> get puestosDisponibles => _puestosDisponibles;
  FiltrosEmpleados get filtros => _filtros;

  // Empleados filtrados
  List<EmpleadoGlobalGrid> get empleadosFiltrados {
    return _empleados
        .where((empleado) => _filtros.cumpleFiltros(empleado))
        .toList();
  }

  // Estadísticas
  int get totalEmpleados => _empleados.length;
  int get empleadosActivos => _empleados.where((e) => e.activo).length;
  int get empleadosEnTurno => _empleados.where((e) => e.enTurnoNow).length;
  int get empleadosConCarga =>
      _empleados.where((e) => e.ordenesAbiertas > 0).length;

  // Estadísticas por sucursal
  Map<String, int> get empleadosPorSucursal {
    final Map<String, int> conteo = {};
    for (final empleado in _empleados) {
      conteo[empleado.sucursalNombre] =
          (conteo[empleado.sucursalNombre] ?? 0) + 1;
    }
    return conteo;
  }

  /// Cargar todos los empleados desde vw_empleados_grid
  Future<void> cargarEmpleadosGlobales() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      developer.log('🔄 Cargando empleados globales desde vw_empleados_grid');

      final response = await supabaseLU.from('vw_empleados_grid').select('*');

      if (response.isEmpty) {
        _empleados = [];
        developer.log('ℹ️ No se encontraron empleados');
      } else {
        _empleados = response.map<EmpleadoGlobalGrid>((json) {
          return EmpleadoGlobalGrid.fromMap(json);
        }).toList();

        developer.log('✅ Empleados cargados: ${_empleados.length}');

        // Extraer sucursales únicas
        _extraerSucursales();

        // Extraer puestos únicos
        _extraerPuestos();

        // Construir filas para PlutoGrid
        _buildEmpleadosRows();
      }
    } catch (e) {
      _error = 'Error al cargar empleados: $e';
      developer.log('❌ Error cargando empleados: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Extraer sucursales únicas de los empleados
  void _extraerSucursales() {
    final sucursalesSet = <String, SucursalEmpleado>{};

    for (final empleado in _empleados) {
      if (!sucursalesSet.containsKey(empleado.sucursalId)) {
        sucursalesSet[empleado.sucursalId] = SucursalEmpleado(
          id: empleado.sucursalId,
          nombre: empleado.sucursalNombre,
        );
      }
    }

    _sucursales = sucursalesSet.values.toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  /// Extraer puestos únicos de los empleados
  void _extraerPuestos() {
    final puestosSet = <String>{};

    for (final empleado in _empleados) {
      puestosSet.add(empleado.puesto);
    }

    _puestosDisponibles = puestosSet.toList()..sort();
  }

  /// Construir filas para PlutoGrid
  void _buildEmpleadosRows() {
    empleadosRows.clear();

    final empleadosFiltrados = this.empleadosFiltrados;

    for (int i = 0; i < empleadosFiltrados.length; i++) {
      final empleado = empleadosFiltrados[i];
      empleadosRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'empleado': PlutoCell(value: empleado.empleadoNombre),
        'puesto': PlutoCell(value: empleado.puesto),
        'sucursal': PlutoCell(value: empleado.sucursalNombre),
        'turno': PlutoCell(value: empleado.estadoTurno),
        'carga': PlutoCell(value: empleado.ordenesAbiertas.toString()),
        'acciones': PlutoCell(value: empleado.empleadoId),
      }));
    }
  }

  /// Transferir empleado a otra sucursal
  Future<bool> transferirEmpleado(
      String empleadoId, String nuevaSucursalId) async {
    try {
      developer.log(
          '🔄 Transfiriendo empleado $empleadoId a sucursal $nuevaSucursalId');

      await supabaseLU.rpc('mover_empleado_sucursal', params: {
        'p_empleado_id': empleadoId,
        'p_nueva_sucursal_id': nuevaSucursalId,
      });

      developer.log('✅ Empleado transferido exitosamente');

      // Recargar datos para reflejar el cambio
      await cargarEmpleadosGlobales();

      return true;
    } catch (e) {
      _error = 'Error al transferir empleado: $e';
      developer.log('❌ Error transfiriendo empleado: $e');
      notifyListeners();
      return false;
    }
  }

  /// Cambiar rol de empleado
  Future<bool> cambiarRolEmpleado(String usuarioId, int nuevoRoleId) async {
    try {
      developer
          .log('🔄 Cambiando rol del usuario $usuarioId a rol $nuevoRoleId');

      await supabaseLU.rpc('cambiar_rol_empleado', params: {
        'p_usuario_id': usuarioId,
        'p_role_id': nuevoRoleId,
      });

      developer.log('✅ Rol cambiado exitosamente');

      // Recargar datos para reflejar el cambio
      await cargarEmpleadosGlobales();

      return true;
    } catch (e) {
      _error = 'Error al cambiar rol: $e';
      developer.log('❌ Error cambiando rol: $e');
      notifyListeners();
      return false;
    }
  }

  /// Programar turno para empleado
  Future<bool> programarTurno({
    required String empleadoId,
    required String sucursalId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String tipoTurno,
  }) async {
    try {
      developer.log('🔄 Programando turno para empleado $empleadoId');

      await supabaseLU.rpc('programar_turno_empleado', params: {
        'p_empleado_id': empleadoId,
        'p_sucursal_id': sucursalId,
        'p_fecha_inicio': fechaInicio.toIso8601String(),
        'p_fecha_fin': fechaFin.toIso8601String(),
        'p_tipo_turno': tipoTurno,
      });

      developer.log('✅ Turno programado exitosamente');

      // Recargar datos para reflejar el cambio
      await cargarEmpleadosGlobales();

      return true;
    } catch (e) {
      _error = 'Error al programar turno: $e';
      developer.log('❌ Error programando turno: $e');
      notifyListeners();
      return false;
    }
  }

  /// Aplicar filtros y reconstruir filas
  void aplicarFiltros() {
    _buildEmpleadosRows();
    notifyListeners();
  }

  /// Filtrar por término de búsqueda
  void filtrarPorTexto(String searchTerm) {
    _filtros.searchTerm = searchTerm;
    aplicarFiltros();
  }

  /// Filtrar por sucursal
  void filtrarPorSucursal(String? sucursalId) {
    _filtros.sucursalId = sucursalId;
    aplicarFiltros();
  }

  /// Filtrar por puesto
  void filtrarPorPuesto(String? puesto) {
    _filtros.puesto = puesto;
    aplicarFiltros();
  }

  /// Filtrar por estado activo
  void filtrarPorEstado(bool? activo) {
    _filtros.activo = activo;
    aplicarFiltros();
  }

  /// Filtrar por turno
  void filtrarPorTurno(bool? enTurno) {
    _filtros.enTurno = enTurno;
    aplicarFiltros();
  }

  /// Filtrar por estado de turno
  void filtrarPorEstadoTurno(String? estadoTurno) {
    _filtros.estadoTurno = estadoTurno;
    aplicarFiltros();
  }

  /// Filtrar por nivel de carga
  void filtrarPorCarga(String? nivelCarga) {
    _filtros.nivelCarga = nivelCarga;
    aplicarFiltros();
  }

  /// Limpiar todos los filtros
  void limpiarFiltros() {
    _filtros.limpiar();
    aplicarFiltros();
  }

  /// Obtener empleado por ID
  EmpleadoGlobalGrid? getEmpleadoById(String empleadoId) {
    try {
      return _empleados.firstWhere((emp) => emp.empleadoId == empleadoId);
    } catch (e) {
      return null;
    }
  }

  /// Obtener sucursal por ID
  SucursalEmpleado? getSucursalById(String sucursalId) {
    try {
      return _sucursales.firstWhere((suc) => suc.id == sucursalId);
    } catch (e) {
      return null;
    }
  }

  /// Refrescar datos
  Future<void> refrescar() async {
    await cargarEmpleadosGlobales();
  }

  /// Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
