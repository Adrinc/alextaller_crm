import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helpers/globals.dart';
import '../../models/talleralex/inventario_models.dart';

class InventarioProvider extends ChangeNotifier {
  // Variables de estado
  bool _isLoading = false;
  String? _error;
  String _sucursalId = '';

  // Listas principales
  List<RefaccionInventario> _refacciones = [];
  List<RefaccionAlerta> _refaccionesEnAlerta = [];
  List<HistorialMovimientoInventario> _historialMovimientos = [];

  // KPIs
  KPIsInventario? _kpis;

  // Elemento seleccionado para detalles
  RefaccionInventario? _refaccionSeleccionada;

  // Filtros
  String _filtroTexto = '';
  bool? _filtroActivo;
  bool? _filtroEnAlerta;
  String? _filtroProveedor;

  // PlutoGrid rows
  List<PlutoRow> inventarioRows = [];
  List<PlutoRow> alertasRows = [];
  List<PlutoRow> historialRows = [];

  // Tab seleccionado (0: Inventario, 1: Alertas, 2: Historial)
  int _tabSeleccionado = 0;

  // Rango de fechas para historial
  DateTimeRange _rangoFechas = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sucursalId => _sucursalId;
  List<RefaccionInventario> get refacciones => _refacciones;
  List<RefaccionAlerta> get refaccionesEnAlerta => _refaccionesEnAlerta;
  List<HistorialMovimientoInventario> get historialMovimientos =>
      _historialMovimientos;
  KPIsInventario? get kpis => _kpis;
  RefaccionInventario? get refaccionSeleccionada => _refaccionSeleccionada;
  int get tabSeleccionado => _tabSeleccionado;
  DateTimeRange get rangoFechas => _rangoFechas;

  // Getters de filtros
  String get filtroTexto => _filtroTexto;
  bool? get filtroActivo => _filtroActivo;
  bool? get filtroEnAlerta => _filtroEnAlerta;
  String? get filtroProveedor => _filtroProveedor;

  // Getter para refacciones filtradas
  List<RefaccionInventario> get refaccionesFiltradas {
    List<RefaccionInventario> resultado = List.from(_refacciones);

    // Filtro por texto
    if (_filtroTexto.isNotEmpty) {
      resultado = resultado.where((refaccion) {
        final texto = _filtroTexto.toLowerCase();
        return refaccion.nombre.toLowerCase().contains(texto) ||
            refaccion.sku.toLowerCase().contains(texto) ||
            refaccion.descripcion.toLowerCase().contains(texto) ||
            refaccion.proveedor.toLowerCase().contains(texto);
      }).toList();
    }

    // Filtro por estado activo
    if (_filtroActivo != null) {
      resultado = resultado
          .where((refaccion) => refaccion.activo == _filtroActivo)
          .toList();
    }

    // Filtro por alerta
    if (_filtroEnAlerta != null) {
      if (_filtroEnAlerta!) {
        resultado = resultado.where((refaccion) => refaccion.enAlerta).toList();
      } else {
        resultado =
            resultado.where((refaccion) => !refaccion.enAlerta).toList();
      }
    }

    // Filtro por proveedor
    if (_filtroProveedor != null && _filtroProveedor!.isNotEmpty) {
      resultado = resultado
          .where((refaccion) => refaccion.proveedor
              .toLowerCase()
              .contains(_filtroProveedor!.toLowerCase()))
          .toList();
    }

    // Ordenar: alertas primero, luego por nombre
    resultado.sort((a, b) {
      if (a.enAlerta && !b.enAlerta) return -1;
      if (!a.enAlerta && b.enAlerta) return 1;
      return a.nombre.compareTo(b.nombre);
    });

    return resultado;
  }

  // Getter para historial filtrado por fechas
  List<HistorialMovimientoInventario> get historialFiltrado {
    return _historialMovimientos.where((historial) {
      return historial.fechaMovimiento
              .isAfter(_rangoFechas.start.subtract(const Duration(days: 1))) &&
          historial.fechaMovimiento
              .isBefore(_rangoFechas.end.add(const Duration(days: 1)));
    }).toList();
  }

  // Lista de proveedores únicos para filtros
  List<String> get proveedoresDisponibles {
    final proveedores = _refacciones.map((r) => r.proveedor).toSet().toList();
    proveedores.sort();
    return proveedores;
  }

  // Cambiar tab seleccionado
  void cambiarTab(int tab) {
    _tabSeleccionado = tab;
    notifyListeners();

    // Construir rows apropiadas
    if (tab == 0) {
      _buildInventarioRows();
    } else if (tab == 1) {
      _buildAlertasRows();
    } else if (tab == 2) {
      _buildHistorialRows();
    }
  }

  // Cambiar rango de fechas para historial
  void cambiarRangoFechas(DateTimeRange nuevoRango) {
    _rangoFechas = nuevoRango;
    notifyListeners();

    if (_tabSeleccionado == 2) {
      _buildHistorialRows();
    }
  }

  // Método principal para cargar todos los datos
  Future<void> cargarDatos(String sucursalId) async {
    if (_sucursalId == sucursalId && _refacciones.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    _sucursalId = sucursalId;
    notifyListeners();

    try {
      await Future.wait([
        _cargarInventario(sucursalId),
        _cargarAlertasInventario(sucursalId),
        _cargarHistorialMovimientos(sucursalId),
      ]);

      _calcularKPIs();
      _buildInventarioRows();

      log('✅ Datos de inventario cargados');
    } catch (e) {
      _error = 'Error al cargar inventario: $e';
      log('❌ Error cargando inventario: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar inventario desde vw_inventario_sucursal
  Future<void> _cargarInventario(String sucursalId) async {
    final response = await supabaseLU
        .from('vw_inventario_sucursal')
        .select()
        .eq('sucursal_id', sucursalId)
        .order('nombre');

    _refacciones = (response as List<dynamic>)
        .map((json) => RefaccionInventario.fromJson(json))
        .toList();

    log('✅ Inventario cargado: ${_refacciones.length} refacciones');
  }

  // Cargar alertas desde vw_inventario_alerta
  Future<void> _cargarAlertasInventario(String sucursalId) async {
    final response = await supabaseLU
        .from('vw_inventario_alerta')
        .select()
        .eq('sucursal_id', sucursalId)
        .order('existencias');

    _refaccionesEnAlerta = (response as List<dynamic>)
        .map((json) => RefaccionAlerta.fromJson(json))
        .toList();

    log('✅ Alertas de inventario cargadas: ${_refaccionesEnAlerta.length}');
  }

  // Cargar historial desde vw_historial_refacciones
  Future<void> _cargarHistorialMovimientos(String sucursalId) async {
    final fechaInicio = _rangoFechas.start.toIso8601String();
    final fechaFin = _rangoFechas.end.toIso8601String();

    final response = await supabaseLU
        .from('vw_historial_movimientos_inventario')
        .select()
        .eq('sucursal_id', sucursalId)
        .gte('fecha_movimiento', fechaInicio)
        .lte('fecha_movimiento', fechaFin)
        .order('fecha_movimiento', ascending: false)
        .limit(500);

    _historialMovimientos = (response as List<dynamic>)
        .map((json) => HistorialMovimientoInventario.fromJson(json))
        .toList();

    log('✅ Historial de movimientos cargado: ${_historialMovimientos.length}');
  }

  // Calcular KPIs basado en los datos cargados
  void _calcularKPIs() {
    final totalRefacciones = refaccionesFiltradas.length;
    final refaccionesActivas =
        refaccionesFiltradas.where((r) => r.activo).length;
    final refaccionesInactivas = totalRefacciones - refaccionesActivas;
    final refaccionesEnAlerta =
        refaccionesFiltradas.where((r) => r.enAlerta).length;

    final valorTotalInventario = refaccionesFiltradas
        .where((r) => r.activo)
        .fold<double>(0, (sum, r) => sum + r.valorInventario);

    final movimientosUltimos30Dias = historialFiltrado.length;

    // Cálculo simple de rotación promedio
    final promedioRotacion = totalRefacciones > 0
        ? movimientosUltimos30Dias / totalRefacciones
        : 0.0;

    _kpis = KPIsInventario(
      totalRefacciones: totalRefacciones,
      refaccionesActivas: refaccionesActivas,
      refaccionesInactivas: refaccionesInactivas,
      refaccionesEnAlerta: refaccionesEnAlerta,
      valorTotalInventario: valorTotalInventario,
      promedioRotacion: promedioRotacion,
      movimientosUltimos30Dias: movimientosUltimos30Dias,
    );
  }

  // Construir filas para PlutoGrid de inventario
  void _buildInventarioRows() {
    inventarioRows.clear();

    for (int i = 0; i < refaccionesFiltradas.length; i++) {
      final refaccion = refaccionesFiltradas[i];
      inventarioRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'sku': PlutoCell(value: refaccion.sku),
        'nombre': PlutoCell(value: refaccion.nombre),
        'descripcion': PlutoCell(value: refaccion.descripcion),
        'proveedor': PlutoCell(value: refaccion.proveedor),
        'precio_unitario': PlutoCell(value: refaccion.precioTexto),
        'existencias': PlutoCell(value: refaccion.existencias),
        'minimo_alerta': PlutoCell(value: refaccion.minimoAlerta),
        'estado': PlutoCell(value: refaccion.estadoTexto),
        'valor_inventario': PlutoCell(value: refaccion.valorInventarioTexto),
        'acciones': PlutoCell(value: refaccion.refaccionId),
      }));
    }

    notifyListeners();
  }

  // Construir filas para PlutoGrid de alertas
  void _buildAlertasRows() {
    alertasRows.clear();

    for (int i = 0; i < _refaccionesEnAlerta.length; i++) {
      final alerta = _refaccionesEnAlerta[i];
      alertasRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'sku': PlutoCell(value: alerta.sku),
        'nombre': PlutoCell(value: alerta.nombre),
        'existencias': PlutoCell(value: alerta.existencias),
        'minimo_alerta': PlutoCell(value: alerta.minimoAlerta),
        'faltantes': PlutoCell(value: alerta.faltantesTexto),
        'acciones': PlutoCell(value: alerta.refaccionId),
      }));
    }

    notifyListeners();
  }

  // Construir filas para PlutoGrid de historial
  void _buildHistorialRows() {
    historialRows.clear();

    for (int i = 0; i < historialFiltrado.length; i++) {
      final historial = historialFiltrado[i];
      historialRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'fecha_movimiento':
            PlutoCell(value: historial.fechaMovimiento.toString()),
        'nombre_refaccion': PlutoCell(value: historial.nombreRefaccion),
        'tipo_movimiento': PlutoCell(value: historial.tipoMovimiento),
        'cantidad': PlutoCell(value: historial.cantidad),
        'usuario': PlutoCell(value: historial.usuario ?? 'Sistema'),
        'stock_anterior': PlutoCell(value: historial.stockAnterior),
        'stock_actual': PlutoCell(value: historial.stockActual),
        'motivo': PlutoCell(value: historial.motivo),
        'acciones': PlutoCell(value: historial.movimientoId),
      }));
    }

    notifyListeners();
  }

  // Métodos de filtrado
  void aplicarFiltroTexto(String texto) {
    _filtroTexto = texto;
    _buildInventarioRows();
    notifyListeners();
  }

  void aplicarFiltroActivo(bool? activo) {
    _filtroActivo = activo;
    _calcularKPIs();
    _buildInventarioRows();
    notifyListeners();
  }

  void aplicarFiltroEnAlerta(bool? enAlerta) {
    _filtroEnAlerta = enAlerta;
    _calcularKPIs();
    _buildInventarioRows();
    notifyListeners();
  }

  void aplicarFiltroProveedor(String? proveedor) {
    _filtroProveedor = proveedor;
    _calcularKPIs();
    _buildInventarioRows();
    notifyListeners();
  }

  // Limpiar todos los filtros
  void limpiarFiltros() {
    _filtroTexto = '';
    _filtroActivo = null;
    _filtroEnAlerta = null;
    _filtroProveedor = null;
    _calcularKPIs();
    _buildInventarioRows();
    notifyListeners();
  }

  // Seleccionar refacción para detalles
  void seleccionarRefaccion(RefaccionInventario refaccion) {
    _refaccionSeleccionada = refaccion;
    notifyListeners();
  }

  void limpiarSeleccion() {
    _refaccionSeleccionada = null;
    notifyListeners();
  }

  // Método para refrescar datos
  Future<void> refrescarDatos() async {
    if (_sucursalId.isNotEmpty) {
      await cargarDatos(_sucursalId);
    }
  }

  // Actualizar existencias de una refacción
  Future<bool> actualizarExistencias(
      String refaccionId, int nuevasExistencias) async {
    try {
      await supabaseLU
          .from('inventario_refacciones')
          .update({'existencias': nuevasExistencias}).eq('id', refaccionId);

      // Actualizar localmente
      final index =
          _refacciones.indexWhere((r) => r.refaccionId == refaccionId);
      if (index != -1) {
        _refacciones[index] = RefaccionInventario(
          refaccionId: _refacciones[index].refaccionId,
          sucursalId: _refacciones[index].sucursalId,
          sucursalNombre: _refacciones[index].sucursalNombre,
          sku: _refacciones[index].sku,
          nombre: _refacciones[index].nombre,
          descripcion: _refacciones[index].descripcion,
          proveedor: _refacciones[index].proveedor,
          precioUnitario: _refacciones[index].precioUnitario,
          existencias: nuevasExistencias,
          minimoAlerta: _refacciones[index].minimoAlerta,
          activo: _refacciones[index].activo,
          imagenId: _refacciones[index].imagenId,
          imagenPath: _refacciones[index].imagenPath,
        );
      }

      _calcularKPIs();
      _buildInventarioRows();
      notifyListeners();

      log('✅ Existencias actualizadas para refacción $refaccionId');
      return true;
    } catch (e) {
      log('❌ Error actualizando existencias: $e');
      return false;
    }
  }

  // Activar/desactivar refacción
  Future<bool> cambiarEstadoRefaccion(String refaccionId, bool activo) async {
    try {
      await supabaseLU
          .from('inventario_refacciones')
          .update({'activo': activo}).eq('id', refaccionId);

      await refrescarDatos();
      log('✅ Estado de refacción $refaccionId cambiado a ${activo ? 'activo' : 'inactivo'}');
      return true;
    } catch (e) {
      log('❌ Error cambiando estado de refacción: $e');
      return false;
    }
  }

  // Obtener historial específico de una refacción
  List<HistorialMovimientoInventario> obtenerHistorialRefaccion(
      String refaccionId) {
    return _historialMovimientos
        .where((h) => h.refaccionId == refaccionId)
        .toList();
  }
}
