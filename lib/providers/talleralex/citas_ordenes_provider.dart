import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helpers/globals.dart';
import '../../models/talleralex/citas_ordenes_models.dart';

class CitasOrdenesProvider extends ChangeNotifier {
  // Variables de estado
  bool _isLoading = false;
  String? _error;
  String _sucursalId = '';

  // Rango de fechas para filtros
  DateTimeRange _rangoFechas = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now().add(const Duration(days: 7)),
  );

  // Listas principales
  List<CitaActiva> _citasActivas = [];
  List<OrdenSucursal> _ordenes = [];
  List<AprobacionPendiente> _aprobacionesPendientes = [];

  // KPIs
  KPIsCitasOrdenes? _kpis;

  // Elementos seleccionados para detalles
  CitaActiva? _citaSeleccionada;
  OrdenSucursal? _ordenSeleccionada;

  // Filtros para citas
  EstadoCita? _filtroCitaEstado;
  FuenteCita? _filtroCitaFuente;
  String _filtroCitaTexto = '';

  // Filtros para órdenes
  EstadoOrdenServicio? _filtroOrdenEstado;
  bool? _filtroOrdenConAprobacion;
  bool? _filtroOrdenConSaldo;
  String _filtroOrdenTexto = '';

  // PlutoGrid rows
  List<PlutoRow> citasRows = [];
  List<PlutoRow> ordenesRows = [];

  // Tab seleccionado (0: Citas, 1: Órdenes)
  int _tabSeleccionado = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sucursalId => _sucursalId;
  DateTimeRange get rangoFechas => _rangoFechas;
  List<CitaActiva> get citasActivas => _citasActivas;
  List<OrdenSucursal> get ordenes => _ordenes;
  List<AprobacionPendiente> get aprobacionesPendientes =>
      _aprobacionesPendientes;
  KPIsCitasOrdenes? get kpis => _kpis;
  CitaActiva? get citaSeleccionada => _citaSeleccionada;
  OrdenSucursal? get ordenSeleccionada => _ordenSeleccionada;
  int get tabSeleccionado => _tabSeleccionado;

  // Getters de filtros
  EstadoCita? get filtroCitaEstado => _filtroCitaEstado;
  FuenteCita? get filtroCitaFuente => _filtroCitaFuente;
  String get filtroCitaTexto => _filtroCitaTexto;
  EstadoOrdenServicio? get filtroOrdenEstado => _filtroOrdenEstado;
  bool? get filtroOrdenConAprobacion => _filtroOrdenConAprobacion;
  bool? get filtroOrdenConSaldo => _filtroOrdenConSaldo;
  String get filtroOrdenTexto => _filtroOrdenTexto;

  // Getter para citas filtradas
  List<CitaActiva> get citasFiltradas {
    List<CitaActiva> resultado = List.from(_citasActivas);

    // Filtro por rango de fechas
    resultado = resultado.where((cita) {
      return cita.inicio
              .isAfter(_rangoFechas.start.subtract(const Duration(days: 1))) &&
          cita.inicio.isBefore(_rangoFechas.end.add(const Duration(days: 1)));
    }).toList();

    // Filtro por texto
    if (_filtroCitaTexto.isNotEmpty) {
      resultado = resultado
          .where((cita) =>
              cita.clienteNombre
                  .toLowerCase()
                  .contains(_filtroCitaTexto.toLowerCase()) ||
              cita.placa
                  .toLowerCase()
                  .contains(_filtroCitaTexto.toLowerCase()) ||
              cita.vehiculoTexto
                  .toLowerCase()
                  .contains(_filtroCitaTexto.toLowerCase()) ||
              cita.serviciosTexto
                  .toLowerCase()
                  .contains(_filtroCitaTexto.toLowerCase()))
          .toList();
    }

    // Filtro por estado
    if (_filtroCitaEstado != null) {
      resultado =
          resultado.where((cita) => cita.estado == _filtroCitaEstado).toList();
    }

    // Filtro por fuente
    if (_filtroCitaFuente != null) {
      resultado =
          resultado.where((cita) => cita.fuente == _filtroCitaFuente).toList();
    }

    // Ordenar por fecha de inicio
    resultado.sort((a, b) => a.inicio.compareTo(b.inicio));
    return resultado;
  }

  // Getter para órdenes filtradas
  List<OrdenSucursal> get ordenesFiltradas {
    List<OrdenSucursal> resultado = List.from(_ordenes);

    // Filtro por rango de fechas
    resultado = resultado.where((orden) {
      return orden.fechaInicio
              .isAfter(_rangoFechas.start.subtract(const Duration(days: 1))) &&
          orden.fechaInicio
              .isBefore(_rangoFechas.end.add(const Duration(days: 1)));
    }).toList();

    // Filtro por texto
    if (_filtroOrdenTexto.isNotEmpty) {
      resultado = resultado
          .where((orden) =>
              orden.numero
                  .toLowerCase()
                  .contains(_filtroOrdenTexto.toLowerCase()) ||
              orden.clienteNombre
                  .toLowerCase()
                  .contains(_filtroOrdenTexto.toLowerCase()) ||
              orden.placa
                  .toLowerCase()
                  .contains(_filtroOrdenTexto.toLowerCase()) ||
              orden.vehiculoTexto
                  .toLowerCase()
                  .contains(_filtroOrdenTexto.toLowerCase()))
          .toList();
    }

    // Filtro por estado
    if (_filtroOrdenEstado != null) {
      resultado = resultado
          .where((orden) => orden.estado == _filtroOrdenEstado)
          .toList();
    }

    // Filtro por aprobación pendiente (esto requeriría lógica adicional)
    if (_filtroOrdenConAprobacion != null) {
      // Por ahora, mantenemos todas las órdenes
      // TODO: Implementar lógica para detectar órdenes con aprobaciones pendientes
    }

    // Filtro por saldo pendiente
    if (_filtroOrdenConSaldo != null) {
      if (_filtroOrdenConSaldo!) {
        resultado = resultado.where((orden) => orden.tieneSaldo).toList();
      } else {
        resultado = resultado.where((orden) => !orden.tieneSaldo).toList();
      }
    }

    // Ordenar por fecha de inicio (más reciente primero)
    resultado.sort((a, b) => b.fechaInicio.compareTo(a.fechaInicio));
    return resultado;
  }

  // Cambiar tab seleccionado
  void cambiarTab(int tab) {
    _tabSeleccionado = tab;
    notifyListeners();

    // Construir rows apropiadas
    if (tab == 0) {
      _buildCitasRows();
    } else {
      _buildOrdenesRows();
    }
  }

  // Cambiar rango de fechas
  void cambiarRangoFechas(DateTimeRange nuevoRango) {
    _rangoFechas = nuevoRango;
    notifyListeners();

    // Recargar datos si es necesario
    if (_sucursalId.isNotEmpty) {
      cargarDatos(_sucursalId);
    }
  }

  // Método principal para cargar todos los datos
  Future<void> cargarDatos(String sucursalId) async {
    if (_sucursalId == sucursalId && _citasActivas.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    _sucursalId = sucursalId;
    notifyListeners();

    try {
      // Cargar datos en paralelo
      await Future.wait([
        _cargarCitasActivas(sucursalId),
        _cargarOrdenesActivas(sucursalId),
        _cargarAprobacionesPendientes(sucursalId),
      ]);

      // Calcular KPIs
      _calcularKPIs();

      // Construir rows apropiadas según el tab activo
      if (_tabSeleccionado == 0) {
        _buildCitasRows();
      } else {
        _buildOrdenesRows();
      }

      _error = null;
      log('✅ Datos de citas y órdenes cargados');
    } catch (e) {
      _error = 'Error al cargar datos: $e';
      log('❌ Error cargando datos de citas y órdenes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar citas activas desde vw_citas_activas_sucursal
  Future<void> _cargarCitasActivas(String sucursalId) async {
    final response = await supabaseLU
        .from('vw_citas_activas_sucursal')
        .select()
        .eq('sucursal_id', sucursalId)
        .gte('inicio', _rangoFechas.start.toIso8601String())
        .lte('inicio', _rangoFechas.end.toIso8601String());

    _citasActivas = (response as List<dynamic>)
        .map((json) => CitaActiva.fromJson(json as Map<String, dynamic>))
        .toList();

    log('✅ Citas activas cargadas: ${_citasActivas.length}');
  }

  // Cargar órdenes desde vw_ordenes_sucursal
  Future<void> _cargarOrdenesActivas(String sucursalId) async {
    final response = await supabaseLU
        .from('vw_ordenes_sucursal')
        .select()
        .eq('sucursal_id', sucursalId)
        .gte('fecha_inicio', _rangoFechas.start.toIso8601String())
        .lte('fecha_inicio', _rangoFechas.end.toIso8601String());

    _ordenes = (response as List<dynamic>)
        .map((json) => OrdenSucursal.fromJson(json as Map<String, dynamic>))
        .toList();

    log('✅ Órdenes cargadas: ${_ordenes.length}');
  }

  // Cargar aprobaciones pendientes desde vw_backlog_aprobaciones
  Future<void> _cargarAprobacionesPendientes(String sucursalId) async {
    final response = await supabaseLU
        .from('vw_backlog_aprobaciones')
        .select()
        .eq('sucursal_id', sucursalId)
        .eq('requiere_aprobacion', true)
        .eq('aprobado', false);

    _aprobacionesPendientes = (response as List<dynamic>)
        .map((json) =>
            AprobacionPendiente.fromJson(json as Map<String, dynamic>))
        .toList();

    log('✅ Aprobaciones pendientes cargadas: ${_aprobacionesPendientes.length}');
  }

  // Calcular KPIs basado en los datos cargados
  void _calcularKPIs() {
    // Contar citas por estado
    int citasPendientes = 0;
    int citasConfirmadas = 0;
    int citasNoAsistio = 0;
    int citasCompletadas = 0;

    for (final cita in citasFiltradas) {
      switch (cita.estado) {
        case EstadoCita.pendiente:
          citasPendientes++;
          break;
        case EstadoCita.confirmada:
          citasConfirmadas++;
          break;
        case EstadoCita.noAsistio:
          citasNoAsistio++;
          break;
        case EstadoCita.completada:
          citasCompletadas++;
          break;
        default:
          break;
      }
    }

    // Contar órdenes por estado
    int ordenesEnProceso = 0;
    int ordenesPorAprobar = 0;
    int ordenesEsperandoPartes = 0;
    int ordenesListas = 0;
    int ordenesEntregadas = 0;
    int ordenesCerradas = 0;

    double ingresosPeriodo = 0;

    for (final orden in ordenesFiltradas) {
      switch (orden.estado) {
        case EstadoOrdenServicio.enProceso:
          ordenesEnProceso++;
          break;
        case EstadoOrdenServicio.porAprobar:
          ordenesPorAprobar++;
          break;
        case EstadoOrdenServicio.esperandoPartes:
          ordenesEsperandoPartes++;
          break;
        case EstadoOrdenServicio.lista:
          ordenesListas++;
          break;
        case EstadoOrdenServicio.entregada:
          ordenesEntregadas++;
          break;
        case EstadoOrdenServicio.cerrada:
          ordenesCerradas++;
          break;
        default:
          break;
      }

      // Sumar pagos para ingresos
      ingresosPeriodo += orden.pagos;
    }

    // Calcular bahías ocupadas (simulado por ahora)
    int bahiasOcupadas = citasConfirmadas + ordenesEnProceso;
    int bahiasTotales = 10; // TODO: Obtener de la tabla bahias_trabajo

    _kpis = KPIsCitasOrdenes(
      citasPendientes: citasPendientes,
      citasConfirmadas: citasConfirmadas,
      citasNoAsistio: citasNoAsistio,
      citasCompletadas: citasCompletadas,
      ordenesEnProceso: ordenesEnProceso,
      ordenesPorAprobar: ordenesPorAprobar,
      ordenesEsperandoPartes: ordenesEsperandoPartes,
      ordenesListas: ordenesListas,
      ordenesEntregadas: ordenesEntregadas,
      ordenesCerradas: ordenesCerradas,
      bahiasOcupadas: bahiasOcupadas,
      bahiasTotales: bahiasTotales,
      ingresosPeriodo: ingresosPeriodo,
      aprobacionesPendientes: _aprobacionesPendientes.length,
    );
  }

  // Construir filas para PlutoGrid de citas
  void _buildCitasRows() {
    citasRows.clear();

    for (int i = 0; i < citasFiltradas.length; i++) {
      final cita = citasFiltradas[i];
      citasRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'cliente': PlutoCell(value: cita.clienteNombre),
        'vehiculo': PlutoCell(value: '${cita.placa} - ${cita.vehiculoTexto}'),
        'fecha_hora': PlutoCell(value: cita.fechaHoraTexto),
        'duracion': PlutoCell(value: cita.duracionTexto),
        'estado': PlutoCell(value: cita.estado.texto),
        'fuente': PlutoCell(value: cita.fuente.texto),
        'servicios': PlutoCell(value: cita.serviciosTexto),
        'bahia': PlutoCell(value: cita.tieneBahia ? 'Asignada' : 'Sin asignar'),
        'retraso': PlutoCell(value: cita.retrasoTexto),
        'acciones': PlutoCell(value: cita.citaId),
      }));
    }
  }

  // Construir filas para PlutoGrid de órdenes
  void _buildOrdenesRows() {
    ordenesRows.clear();

    for (int i = 0; i < ordenesFiltradas.length; i++) {
      final orden = ordenesFiltradas[i];
      ordenesRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'folio': PlutoCell(value: orden.numero),
        'cliente': PlutoCell(value: orden.clienteNombre),
        'vehiculo': PlutoCell(value: '${orden.placa} - ${orden.vehiculoTexto}'),
        'estado': PlutoCell(value: orden.estado.texto),
        'fecha_inicio': PlutoCell(value: orden.fechaInicioTexto),
        'total': PlutoCell(value: orden.totalGeneralTexto),
        'pagos': PlutoCell(value: orden.pagosTexto),
        'saldo': PlutoCell(value: orden.saldoTexto),
        'progreso': PlutoCell(value: orden.progresoTiempo ?? 0.0),
        'acciones': PlutoCell(value: orden.ordenId),
      }));
    }
  }

  // Métodos de filtrado para citas
  void aplicarFiltroCitaTexto(String texto) {
    _filtroCitaTexto = texto;
    _buildCitasRows();
    notifyListeners();
  }

  void aplicarFiltroCitaEstado(EstadoCita? estado) {
    _filtroCitaEstado = estado;
    _buildCitasRows();
    notifyListeners();
  }

  void aplicarFiltroCitaFuente(FuenteCita? fuente) {
    _filtroCitaFuente = fuente;
    _buildCitasRows();
    notifyListeners();
  }

  // Métodos de filtrado para órdenes
  void aplicarFiltroOrdenTexto(String texto) {
    _filtroOrdenTexto = texto;
    _buildOrdenesRows();
    notifyListeners();
  }

  void aplicarFiltroOrdenEstado(EstadoOrdenServicio? estado) {
    _filtroOrdenEstado = estado;
    _buildOrdenesRows();
    notifyListeners();
  }

  void aplicarFiltroOrdenConAprobacion(bool? conAprobacion) {
    _filtroOrdenConAprobacion = conAprobacion;
    _buildOrdenesRows();
    notifyListeners();
  }

  void aplicarFiltroOrdenConSaldo(bool? conSaldo) {
    _filtroOrdenConSaldo = conSaldo;
    _buildOrdenesRows();
    notifyListeners();
  }

  // Limpiar filtros
  void limpiarFiltrosCitas() {
    _filtroCitaTexto = '';
    _filtroCitaEstado = null;
    _filtroCitaFuente = null;
    _buildCitasRows();
    notifyListeners();
  }

  void limpiarFiltrosOrdenes() {
    _filtroOrdenTexto = '';
    _filtroOrdenEstado = null;
    _filtroOrdenConAprobacion = null;
    _filtroOrdenConSaldo = null;
    _buildOrdenesRows();
    notifyListeners();
  }

  // Seleccionar elementos para detalles
  void seleccionarCita(CitaActiva cita) {
    _citaSeleccionada = cita;
    notifyListeners();
  }

  void seleccionarOrden(OrdenSucursal orden) {
    _ordenSeleccionada = orden;
    notifyListeners();
  }

  void limpiarSeleccion() {
    _citaSeleccionada = null;
    _ordenSeleccionada = null;
    notifyListeners();
  }

  // Método para refrescar datos
  Future<void> refrescarDatos() async {
    if (_sucursalId.isEmpty) return;

    final sucursalActual = _sucursalId;
    _citasActivas.clear();
    _ordenes.clear();
    _aprobacionesPendientes.clear();
    await cargarDatos(sucursalActual);
  }

  // Crear orden desde cita usando la función de Supabase
  Future<bool> crearOrdenDesdeCita(String citaId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response =
          await supabaseLU.rpc('crear_orden_desde_cita_v2', params: {
        'p_cita_id': citaId,
      });

      if (response != null) {
        // Refrescar datos
        await refrescarDatos();
        log('✅ Orden creada desde cita: $citaId');
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Error al crear orden: $e';
      log('❌ Error creando orden desde cita: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
