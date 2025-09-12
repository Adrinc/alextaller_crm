import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helpers/globals.dart';
import '../../models/talleralex/pagos_models.dart';

class PagosProvider extends ChangeNotifier {
  // Variables de estado
  bool _isLoading = false;
  String? _error;
  String _sucursalId = '';

  // Listas principales
  List<PagoDetalle> _pagos = [];
  List<PagosTotalesSucursal> _totalesDiarios = [];

  // KPIs
  KPIsPagos? _kpis;

  // Elemento seleccionado para detalles
  PagoDetalle? _pagoSeleccionado;

  // Filtros
  String _filtroTexto = '';
  String? _filtroEstado;
  String? _filtroMetodo;
  bool? _filtroTieneFactura;
  DateTimeRange _rangoFechas = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  // PlutoGrid rows
  List<PlutoRow> pagosRows = [];
  List<PlutoRow> facturasRows = [];

  // Tab seleccionado (0: Pagos, 1: Facturas)
  int _tabSeleccionado = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sucursalId => _sucursalId;
  List<PagoDetalle> get pagos => _pagos;
  List<PagosTotalesSucursal> get totalesDiarios => _totalesDiarios;
  KPIsPagos? get kpis => _kpis;
  PagoDetalle? get pagoSeleccionado => _pagoSeleccionado;
  int get tabSeleccionado => _tabSeleccionado;
  DateTimeRange get rangoFechas => _rangoFechas;

  // Getters de filtros
  String get filtroTexto => _filtroTexto;
  String? get filtroEstado => _filtroEstado;
  String? get filtroMetodo => _filtroMetodo;
  bool? get filtroTieneFactura => _filtroTieneFactura;

  // Getter para pagos filtrados
  List<PagoDetalle> get pagosFiltrados {
    List<PagoDetalle> resultado = List.from(_pagos);

    // Filtro por rango de fechas
    resultado = resultado.where((pago) {
      return pago.fechaPago
              .isAfter(_rangoFechas.start.subtract(const Duration(days: 1))) &&
          pago.fechaPago
              .isBefore(_rangoFechas.end.add(const Duration(days: 1)));
    }).toList();

    // Filtro por texto
    if (_filtroTexto.isNotEmpty) {
      final texto = _filtroTexto.toLowerCase();
      resultado = resultado.where((pago) {
        return pago.clienteNombre.toLowerCase().contains(texto) ||
            pago.numeroOrden.toLowerCase().contains(texto) ||
            pago.placa.toLowerCase().contains(texto) ||
            pago.vehiculoTexto.toLowerCase().contains(texto) ||
            (pago.facturaFolio != null &&
                pago.facturaFolio!.toLowerCase().contains(texto));
      }).toList();
    }

    // Filtro por estado
    if (_filtroEstado != null && _filtroEstado!.isNotEmpty) {
      resultado = resultado
          .where((pago) =>
              pago.estado.toLowerCase() == _filtroEstado!.toLowerCase())
          .toList();
    }

    // Filtro por método
    if (_filtroMetodo != null && _filtroMetodo!.isNotEmpty) {
      resultado = resultado
          .where((pago) =>
              pago.metodo.toLowerCase() == _filtroMetodo!.toLowerCase())
          .toList();
    }

    // Filtro por factura
    if (_filtroTieneFactura != null) {
      if (_filtroTieneFactura!) {
        resultado = resultado.where((pago) => pago.tieneFactura).toList();
      } else {
        resultado = resultado.where((pago) => !pago.tieneFactura).toList();
      }
    }

    // Ordenar: pendientes primero, luego por fecha descendente
    resultado.sort((a, b) {
      if (a.esPendiente && !b.esPendiente) return -1;
      if (!a.esPendiente && b.esPendiente) return 1;
      return b.fechaPago.compareTo(a.fechaPago);
    });

    return resultado;
  }

  // Getter para facturas filtradas
  List<PagoDetalle> get facturasFiltradasList {
    return pagosFiltrados.where((pago) => pago.tieneFactura).toList();
  }

  // Lista de estados disponibles para filtros
  List<String> get estadosDisponibles {
    return ['pendiente', 'pagado', 'fallido', 'reembolsado', 'parcial'];
  }

  // Lista de métodos disponibles para filtros
  List<String> get metodosDisponibles {
    return ['efectivo', 'tarjeta', 'transferencia', 'cheque'];
  }

  // Cambiar tab seleccionado
  void cambiarTab(int tab) {
    _tabSeleccionado = tab;
    notifyListeners();

    // Construir rows apropiadas
    if (tab == 0) {
      _buildPagosRows();
    } else if (tab == 1) {
      _buildFacturasRows();
    }
  }

  // Cambiar rango de fechas
  void cambiarRangoFechas(DateTimeRange nuevoRango) {
    _rangoFechas = nuevoRango;
    notifyListeners();
    _calcularKPIs();
    _buildPagosRows();
    if (_tabSeleccionado == 1) {
      _buildFacturasRows();
    }
  }

  // Método principal para cargar todos los datos
  Future<void> cargarDatos(String sucursalId) async {
    if (_sucursalId == sucursalId && _pagos.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    _sucursalId = sucursalId;
    notifyListeners();

    try {
      await Future.wait([
        _cargarPagos(sucursalId),
        _cargarTotalesDiarios(sucursalId),
      ]);

      _calcularKPIs();
      _buildPagosRows();

      log('✅ Datos de pagos cargados');
    } catch (e) {
      _error = 'Error al cargar pagos: $e';
      log('❌ Error cargando pagos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar pagos desde vw_pagos_detalle
  Future<void> _cargarPagos(String sucursalId) async {
    final fechaInicio = _rangoFechas.start.toIso8601String();
    final fechaFin = _rangoFechas.end.toIso8601String();

    final response = await supabaseLU
        .from('vw_pagos_detalle')
        .select()
        .eq('sucursal_id', sucursalId)
        .gte('fecha_pago', fechaInicio)
        .lte('fecha_pago', fechaFin)
        .order('fecha_pago', ascending: false)
        .limit(1000);

    _pagos = (response as List<dynamic>)
        .map((json) => PagoDetalle.fromJson(json))
        .toList();

    log('✅ Pagos cargados: ${_pagos.length}');
  }

  // Cargar totales diarios desde vw_pagos_totales_sucursal
  Future<void> _cargarTotalesDiarios(String sucursalId) async {
    final fechaInicio = _rangoFechas.start.toIso8601String();
    final fechaFin = _rangoFechas.end.toIso8601String();

    final response = await supabaseLU
        .from('vw_pagos_totales_sucursal')
        .select()
        .eq('sucursal_id', sucursalId)
        .gte('fecha', fechaInicio)
        .lte('fecha', fechaFin)
        .order('fecha', ascending: false);

    _totalesDiarios = (response as List<dynamic>)
        .map((json) => PagosTotalesSucursal.fromJson(json))
        .toList();

    log('✅ Totales diarios cargados: ${_totalesDiarios.length}');
  }

  // Calcular KPIs basado en los datos cargados
  void _calcularKPIs() {
    final hoy = DateTime.now();
    final inicioMes = DateTime(hoy.year, hoy.month, 1);

    // Pagos de hoy
    final pagosHoy = pagosFiltrados
        .where((p) =>
            p.fechaPago.year == hoy.year &&
            p.fechaPago.month == hoy.month &&
            p.fechaPago.day == hoy.day)
        .toList();

    // Pagos del mes
    final pagosMes = pagosFiltrados
        .where((p) =>
            p.fechaPago.isAfter(inicioMes.subtract(const Duration(days: 1))))
        .toList();

    final totalPagadoHoy = pagosHoy
        .where((p) => p.esPagado)
        .fold<double>(0, (sum, p) => sum + p.monto);

    final totalPagadoMes = pagosMes
        .where((p) => p.esPagado)
        .fold<double>(0, (sum, p) => sum + p.monto);

    final totalPendiente = pagosFiltrados
        .where((p) => p.esPendiente)
        .fold<double>(0, (sum, p) => sum + p.monto);

    final facturasPendientes =
        pagosFiltrados.where((p) => p.esPagado && !p.tieneFactura).length;

    final facturasEmitidas = pagosFiltrados.where((p) => p.tieneFactura).length;

    final totalPagos = pagosFiltrados.where((p) => p.esPagado).length;
    final porcentajeFacturado =
        totalPagos > 0 ? (facturasEmitidas / totalPagos) * 100 : 0.0;

    _kpis = KPIsPagos(
      totalPagadoHoy: totalPagadoHoy,
      totalPagadoMes: totalPagadoMes,
      totalPendiente: totalPendiente,
      facturasPendientes: facturasPendientes,
      facturasEmitidas: facturasEmitidas,
      porcentajeFacturado: porcentajeFacturado,
      totalPagosHoy: pagosHoy.where((p) => p.esPagado).length,
      totalPagosMes: pagosMes.where((p) => p.esPagado).length,
    );
  }

  // Construir filas para PlutoGrid de pagos
  void _buildPagosRows() {
    pagosRows.clear();

    for (int i = 0; i < pagosFiltrados.length; i++) {
      final pago = pagosFiltrados[i];
      pagosRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'fecha_pago': PlutoCell(value: pago.fechaTexto),
        'cliente': PlutoCell(value: pago.clienteNombre),
        'vehiculo': PlutoCell(value: pago.vehiculoTexto),
        'orden': PlutoCell(value: pago.numeroOrden),
        'monto': PlutoCell(value: pago.monto),
        'metodo': PlutoCell(value: pago.metodo),
        'estado': PlutoCell(value: pago.estado),
        'factura': PlutoCell(value: pago.tieneFactura ? 'Sí' : 'No'),
        'folio_factura': PlutoCell(value: pago.facturaFolio ?? ''),
        'acciones': PlutoCell(value: pago.pagoId),
      }));
    }

    notifyListeners();
  }

  // Construir filas para PlutoGrid de facturas
  void _buildFacturasRows() {
    facturasRows.clear();

    final facturas = facturasFiltradasList;
    for (int i = 0; i < facturas.length; i++) {
      final factura = facturas[i];
      facturasRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'folio': PlutoCell(value: factura.facturaFolio ?? ''),
        'fecha_emision': PlutoCell(value: factura.facturaFechaTexto),
        'cliente': PlutoCell(value: factura.clienteNombre),
        'rfc': PlutoCell(value: factura.clienteRfc ?? ''),
        'monto': PlutoCell(value: factura.monto),
        'orden': PlutoCell(value: factura.numeroOrden),
        'pdf_url': PlutoCell(value: factura.pdfUrl ?? ''),
        'xml_url': PlutoCell(value: factura.xmlUrl ?? ''),
        'acciones': PlutoCell(value: factura.pagoId),
      }));
    }

    notifyListeners();
  }

  // Métodos de filtrado
  void aplicarFiltroTexto(String texto) {
    _filtroTexto = texto;
    _calcularKPIs();
    _buildPagosRows();
    if (_tabSeleccionado == 1) {
      _buildFacturasRows();
    }
    notifyListeners();
  }

  void aplicarFiltroEstado(String? estado) {
    _filtroEstado = estado;
    _calcularKPIs();
    _buildPagosRows();
    if (_tabSeleccionado == 1) {
      _buildFacturasRows();
    }
    notifyListeners();
  }

  void aplicarFiltroMetodo(String? metodo) {
    _filtroMetodo = metodo;
    _calcularKPIs();
    _buildPagosRows();
    if (_tabSeleccionado == 1) {
      _buildFacturasRows();
    }
    notifyListeners();
  }

  void aplicarFiltroTieneFactura(bool? tieneFactura) {
    _filtroTieneFactura = tieneFactura;
    _calcularKPIs();
    _buildPagosRows();
    if (_tabSeleccionado == 1) {
      _buildFacturasRows();
    }
    notifyListeners();
  }

  // Limpiar todos los filtros
  void limpiarFiltros() {
    _filtroTexto = '';
    _filtroEstado = null;
    _filtroMetodo = null;
    _filtroTieneFactura = null;
    _calcularKPIs();
    _buildPagosRows();
    if (_tabSeleccionado == 1) {
      _buildFacturasRows();
    }
    notifyListeners();
  }

  // Seleccionar pago para detalles
  void seleccionarPago(PagoDetalle pago) {
    _pagoSeleccionado = pago;
    notifyListeners();
  }

  void limpiarSeleccion() {
    _pagoSeleccionado = null;
    notifyListeners();
  }

  // Método para refrescar datos
  Future<void> refrescarDatos() async {
    if (_sucursalId.isNotEmpty) {
      await cargarDatos(_sucursalId);
    }
  }

  // Actualizar estado de pago
  Future<bool> actualizarEstadoPago(String pagoId, String nuevoEstado) async {
    try {
      await supabaseLU.from('pagos').update({
        'estado': nuevoEstado,
        'fecha_pago': DateTime.now().toIso8601String(),
      }).eq('id', pagoId);

      await refrescarDatos();
      log('✅ Estado de pago $pagoId actualizado a $nuevoEstado');
      return true;
    } catch (e) {
      log('❌ Error actualizando estado de pago: $e');
      return false;
    }
  }

  // Crear factura para un pago
  Future<bool> crearFactura(String pagoId, String folio,
      {String? pdfUrl, String? xmlUrl}) async {
    try {
      await supabaseLU.from('facturas').insert({
        'pago_id': pagoId,
        'folio': folio,
        'fecha_emision': DateTime.now().toIso8601String(),
        'sucursal_id': _sucursalId,
        if (pdfUrl != null) 'pdf_url': pdfUrl,
        if (xmlUrl != null) 'xml_url': xmlUrl,
      });

      await refrescarDatos();
      log('✅ Factura $folio creada para pago $pagoId');
      return true;
    } catch (e) {
      log('❌ Error creando factura: $e');
      return false;
    }
  }

  // Crear nuevo pago
  Future<bool> crearPago(CrearPago nuevoPago) async {
    try {
      await supabaseLU.from('pagos').insert({
        ...nuevoPago.toJson(),
        'sucursal_id': _sucursalId,
      });

      await refrescarDatos();
      log('✅ Nuevo pago creado');
      return true;
    } catch (e) {
      log('❌ Error creando pago: $e');
      return false;
    }
  }

  // Obtener historial de pagos de un cliente
  List<PagoDetalle> obtenerHistorialCliente(String clienteId) {
    return _pagos.where((p) => p.clienteId == clienteId).toList();
  }

  // Obtener pagos de una orden específica
  List<PagoDetalle> obtenerPagosOrden(String ordenId) {
    return _pagos.where((p) => p.ordenId == ordenId).toList();
  }
}
