import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/empleados_models.dart';

class EmpleadosProvider extends ChangeNotifier {
  List<EmpleadoGrid> _empleados = [];
  bool _isLoading = false;
  String? _error;
  String _sucursalId = '';

  // Filtros
  String _filtroTexto = '';
  PuestoEmpleado? _filtroPuesto;
  bool? _filtroActivo;
  bool? _filtroEnTurno;
  DateTimeRange? _filtroFechaRango;

  // Lista de filas para PlutoGrid
  List<PlutoRow> empleadosRows = [];

  // Getters
  List<EmpleadoGrid> get empleados => _empleados;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sucursalId => _sucursalId;

  // Filtros getters
  String get filtroTexto => _filtroTexto;
  PuestoEmpleado? get filtroPuesto => _filtroPuesto;
  bool? get filtroActivo => _filtroActivo;
  bool? get filtroEnTurno => _filtroEnTurno;
  DateTimeRange? get filtroFechaRango => _filtroFechaRango;

  List<EmpleadoGrid> get empleadosFiltrados {
    var resultado = _empleados.where((empleado) {
      // Filtro por texto (nombre)
      if (_filtroTexto.isNotEmpty &&
          !empleado.empleadoNombre
              .toLowerCase()
              .contains(_filtroTexto.toLowerCase())) {
        return false;
      }

      // Filtro por puesto
      if (_filtroPuesto != null && empleado.puesto != _filtroPuesto) {
        return false;
      }

      // Filtro por activo
      if (_filtroActivo != null && empleado.activo != _filtroActivo) {
        return false;
      }

      // Filtro por en turno
      if (_filtroEnTurno != null && empleado.enTurnoNow != _filtroEnTurno) {
        return false;
      }

      return true;
    }).toList();

    // Ordenar por nombre
    resultado.sort((a, b) => a.empleadoNombre.compareTo(b.empleadoNombre));
    return resultado;
  }

  // Método para cargar empleados de una sucursal
  Future<void> cargarEmpleados(String sucursalId) async {
    if (_sucursalId == sucursalId && _empleados.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    _sucursalId = sucursalId;
    notifyListeners();

    try {
      final response = await supabaseLU
          .from('vw_empleados_grid')
          .select()
          .eq('sucursal_id', sucursalId);

      _empleados = (response as List<dynamic>)
          .map((json) => EmpleadoGrid.fromJson(json as Map<String, dynamic>))
          .toList();

      // Construir filas para PlutoGrid
      _buildEmpleadosRows();

      _error = null;
      log('✅ Empleados cargados: ${_empleados.length}');
    } catch (e) {
      _error = 'Error al cargar empleados: $e';
      _empleados = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para refrescar datos
  Future<void> refrescarEmpleados() async {
    if (_sucursalId.isEmpty) return;

    final sucursalActual = _sucursalId;
    _empleados.clear();
    await cargarEmpleados(sucursalActual);
  }

  // Métodos de filtrado
  void aplicarFiltroTexto(String texto) {
    _filtroTexto = texto;
    notifyListeners();
  }

  void aplicarFiltroPuesto(PuestoEmpleado? puesto) {
    _filtroPuesto = puesto;
    notifyListeners();
  }

  void aplicarFiltroActivo(bool? activo) {
    _filtroActivo = activo;
    notifyListeners();
  }

  void aplicarFiltroEnTurno(bool? enTurno) {
    _filtroEnTurno = enTurno;
    notifyListeners();
  }

  void aplicarFiltroFechaRango(DateTimeRange? rango) {
    _filtroFechaRango = rango;
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtroTexto = '';
    _filtroPuesto = null;
    _filtroActivo = null;
    _filtroEnTurno = null;
    _filtroFechaRango = null;
    notifyListeners();
  }

  // Construir filas para PlutoGrid usando datos de empleados
  void _buildEmpleadosRows() {
    empleadosRows.clear();

    for (int i = 0; i < empleadosFiltrados.length; i++) {
      final empleado = empleadosFiltrados[i];
      empleadosRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'nombre': PlutoCell(value: empleado.empleadoNombre),
        'puesto': PlutoCell(value: empleado.puesto.displayName),
        'correo': PlutoCell(value: empleado.correo ?? ''),
        'telefono': PlutoCell(value: empleado.telefono ?? ''),
        'direccion': PlutoCell(value: empleado.direccion ?? ''),
        'activo': PlutoCell(value: empleado.activo ? 'Activo' : 'Inactivo'),
        'en_turno': PlutoCell(value: empleado.enTurnoNow ? 'Sí' : 'No'),
        'turno_actual': PlutoCell(value: empleado.turnoTexto),
        'ordenes_abiertas': PlutoCell(value: empleado.ordenesAbiertas),
        'minutos_hoy': PlutoCell(value: empleado.horasHoyTexto),
        'acciones': PlutoCell(value: empleado.empleadoId),
      }));
    }
  }

  // Método para crear un nuevo empleado
  Future<bool> crearEmpleado(NuevoEmpleado nuevoEmpleado) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Llamar a la función de Supabase para crear empleado
      final response = await supabaseLU.rpc('crear_empleado_completo', params: {
        'p_sucursal_id': _sucursalId,
        'p_nombre': nuevoEmpleado.nombre,
        'p_apellido': nuevoEmpleado.apellido,
        'p_correo': nuevoEmpleado.correo,
        'p_telefono': nuevoEmpleado.telefono,
        'p_direccion': nuevoEmpleado.direccion,
        'p_puesto': nuevoEmpleado.puesto.value,
        'p_password': nuevoEmpleado.password ?? 'temp123',
      });

      if (response != null) {
        // Refrescar la lista de empleados
        await refrescarEmpleados();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al crear empleado: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para activar/desactivar empleado
  Future<bool> cambiarEstadoEmpleado(String empleadoId, bool activo) async {
    try {
      await supabaseLU
          .from('empleados')
          .update({'activo': activo}).eq('id', empleadoId);

      // Actualizar el estado local
      final index = _empleados.indexWhere((e) => e.empleadoId == empleadoId);
      if (index != -1) {
        final empleado = _empleados[index];
        _empleados[index] = EmpleadoGrid(
          empleadoId: empleado.empleadoId,
          empleadoNombre: empleado.empleadoNombre,
          puesto: empleado.puesto,
          activo: activo,
          correo: empleado.correo,
          telefono: empleado.telefono,
          direccion: empleado.direccion,
          imagenId: empleado.imagenId,
          sucursalId: empleado.sucursalId,
          sucursalNombre: empleado.sucursalNombre,
          enTurnoNow: empleado.enTurnoNow,
          turnoInicio: empleado.turnoInicio,
          turnoFin: empleado.turnoFin,
          minutosHoy: empleado.minutosHoy,
          ordenesAbiertas: empleado.ordenesAbiertas,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'Error al cambiar estado del empleado: $e';
      notifyListeners();
      return false;
    }
  }

  // Método para programar turno
  Future<bool> programarTurno(String empleadoId, DateTime inicio, DateTime fin,
      TipoTurnoEmpleado tipo) async {
    try {
      await supabaseLU.rpc('programar_turno_empleado', params: {
        'p_empleado_id': empleadoId,
        'p_sucursal_id': _sucursalId,
        'p_inicio': inicio.toIso8601String(),
        'p_fin': fin.toIso8601String(),
        'p_tipo': tipo.value,
      });

      // Refrescar datos para mostrar el nuevo turno
      await refrescarEmpleados();
      return true;
    } catch (e) {
      _error = 'Error al programar turno: $e';
      notifyListeners();
      return false;
    }
  }

  // Método para reasignar empleado a otra sucursal
  Future<bool> reasignarEmpleado(
      String empleadoId, String nuevaSucursalId) async {
    try {
      await supabaseLU.rpc('asignar_empleado_a_sucursal', params: {
        'p_empleado_id': empleadoId,
        'p_sucursal_id': nuevaSucursalId,
      });

      // Refrescar datos
      await refrescarEmpleados();
      return true;
    } catch (e) {
      _error = 'Error al reasignar empleado: $e';
      notifyListeners();
      return false;
    }
  }

  // Método para obtener turnos de un empleado
  Future<List<TurnoEmpleado>> obtenerTurnosEmpleado(
    String empleadoId, {
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      var query = supabaseLU
          .from('turnos_empleado')
          .select()
          .eq('empleado_id', empleadoId)
          .eq('sucursal_id', _sucursalId);

      if (fechaInicio != null) {
        query = query.gte('inicio', fechaInicio.toIso8601String());
      }
      if (fechaFin != null) {
        query = query.lte('fin', fechaFin.toIso8601String());
      }

      final response = await query.order('inicio', ascending: false);

      return (response as List<dynamic>)
          .map((json) => TurnoEmpleado.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = 'Error al obtener turnos: $e';
      notifyListeners();
      return [];
    }
  }
}
