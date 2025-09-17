import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/promociones_models.dart';

class PromocionesGlobalesProvider extends ChangeNotifier {
  // ==============================================
  // ESTADO DE CARGA
  // ==============================================

  bool _isLoading = false;
  bool _isLoadingPublicacion = false;
  bool _isLoadingCupones = false;
  bool _isLoadingCanje = false;
  String? _error;

  // ==============================================
  // FILTROS PERSISTENTES
  // ==============================================

  String _filtroTexto = '';
  String? _sucursalIdFiltro;
  DateTimeRange _rangoFechas = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  // ==============================================
  // DATOS PRINCIPALES
  // ==============================================

  List<PromocionActiva> _promocionesActivas = [];
  List<PromocionROI> _promocionesROI = [];
  List<CuponItem> _cupones = [];
  List<SucursalSimple> _sucursales = [];

  // Para edición
  PromocionActiva? _promocionEnEdicion;

  // Resultados de operaciones
  List<ResultadoPublicacion> _ultimosResultadosPublicacion = [];
  List<CuponEmitido> _ultimosCuponesEmitidos = [];
  ResultadoCanje? _ultimoResultadoCanje;

  // ==============================================
  // PLUTO GRID ROWS
  // ==============================================

  List<PlutoRow> promocionesActivasRows = [];
  List<PlutoRow> promocionesROIRows = [];
  List<PlutoRow> cuponesRows = [];

  // ==============================================
  // GETTERS - ESTADO
  // ==============================================

  bool get isLoading => _isLoading;
  bool get isLoadingPublicacion => _isLoadingPublicacion;
  bool get isLoadingCupones => _isLoadingCupones;
  bool get isLoadingCanje => _isLoadingCanje;
  String? get error => _error;

  // ==============================================
  // GETTERS - FILTROS
  // ==============================================

  String get filtroTexto => _filtroTexto;
  String? get sucursalIdFiltro => _sucursalIdFiltro;
  DateTimeRange get rangoFechas => _rangoFechas;

  // ==============================================
  // GETTERS - DATOS
  // ==============================================

  List<PromocionActiva> get promocionesActivas => _promocionesActivas;
  List<PromocionROI> get promocionesROI => _promocionesROI;
  List<CuponItem> get cupones => _cupones;
  List<SucursalSimple> get sucursales => _sucursales;

  PromocionActiva? get promocionEnEdicion => _promocionEnEdicion;
  List<ResultadoPublicacion> get ultimosResultadosPublicacion =>
      _ultimosResultadosPublicacion;
  List<CuponEmitido> get ultimosCuponesEmitidos => _ultimosCuponesEmitidos;
  ResultadoCanje? get ultimoResultadoCanje => _ultimoResultadoCanje;

  // ==============================================
  // GETTERS - DATOS FILTRADOS
  // ==============================================

  List<PromocionActiva> get promocionesActivasFiltradas {
    var resultado = _promocionesActivas.where((promo) {
      // Filtro por texto
      if (_filtroTexto.isNotEmpty) {
        final texto = _filtroTexto.toLowerCase();
        if (!promo.titulo.toLowerCase().contains(texto) &&
            !promo.descripcion.toLowerCase().contains(texto)) {
          return false;
        }
      }

      // Filtro por sucursal
      if (_sucursalIdFiltro != null && _sucursalIdFiltro!.isNotEmpty) {
        if (promo.sucursalId != _sucursalIdFiltro) {
          return false;
        }
      }

      // Filtro por rango de fechas (se superpone con la vigencia)
      if (promo.fechaFin.isBefore(_rangoFechas.start) ||
          promo.fechaInicio.isAfter(_rangoFechas.end)) {
        return false;
      }

      return true;
    }).toList();

    // Ordenar: activas primero, luego por fecha de inicio
    resultado.sort((a, b) {
      if (a.activo && !b.activo) return -1;
      if (!a.activo && b.activo) return 1;
      return b.fechaInicio.compareTo(a.fechaInicio);
    });

    return resultado;
  }

  List<PromocionROI> get promocionesROIFiltradas {
    var resultado = _promocionesROI.where((roi) {
      // Filtro por texto
      if (_filtroTexto.isNotEmpty) {
        final texto = _filtroTexto.toLowerCase();
        if (!roi.titulo.toLowerCase().contains(texto)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Ordenar por ROI descendente
    resultado.sort((a, b) => b.roi.compareTo(a.roi));
    return resultado;
  }

  List<CuponItem> get cuponesFiltrados {
    var resultado = _cupones.where((cupon) {
      // Filtro por texto (código)
      if (_filtroTexto.isNotEmpty) {
        final texto = _filtroTexto.toLowerCase();
        if (!cupon.codigo.toLowerCase().contains(texto)) {
          return false;
        }
      }

      // Filtro por rango de fechas
      if (cupon.fechaFin.isBefore(_rangoFechas.start) ||
          cupon.fechaInicio.isAfter(_rangoFechas.end)) {
        return false;
      }

      return true;
    }).toList();

    // Ordenar: disponibles primero, luego por fecha de creación
    resultado.sort((a, b) {
      if (a.estaDisponible && !b.estaDisponible) return -1;
      if (!a.estaDisponible && b.estaDisponible) return 1;
      return b.creadoEn.compareTo(a.creadoEn);
    });

    return resultado;
  }

  // ==============================================
  // GETTERS - KPIs
  // ==============================================

  Map<String, dynamic> get kpisPromocionesActivas {
    final activas = promocionesActivasFiltradas;
    final vigentes = activas.where((p) => p.estaVigente && p.activo).length;
    final programadas =
        activas.where((p) => DateTime.now().isBefore(p.fechaInicio)).length;
    final vencidas =
        activas.where((p) => DateTime.now().isAfter(p.fechaFin)).length;

    return {
      'total': activas.length,
      'vigentes': vigentes,
      'programadas': programadas,
      'vencidas': vencidas,
    };
  }

  Map<String, dynamic> get kpisROI {
    final roi = promocionesROIFiltradas;
    if (roi.isEmpty) {
      return {
        'total_canjes': 0,
        'clientes_unicos': 0,
        'descuento_total': 0.0,
        'ingreso_bruto': 0.0,
        'ingreso_neto': 0.0,
        'roi_promedio': 0.0,
      };
    }

    final totalCanjes = roi.fold<int>(0, (sum, item) => sum + item.canjes);
    final clientesUnicos =
        roi.fold<int>(0, (sum, item) => sum + item.clientesUnicos);
    final descuentoTotal =
        roi.fold<double>(0, (sum, item) => sum + item.descuentoTotal);
    final ingresoBruto =
        roi.fold<double>(0, (sum, item) => sum + item.ingresoBruto);
    final ingresoNeto =
        roi.fold<double>(0, (sum, item) => sum + item.ingresoNeto);
    final roiPromedio =
        roi.fold<double>(0, (sum, item) => sum + item.roi) / roi.length;

    return {
      'total_canjes': totalCanjes,
      'clientes_unicos': clientesUnicos,
      'descuento_total': descuentoTotal,
      'ingreso_bruto': ingresoBruto,
      'ingreso_neto': ingresoNeto,
      'roi_promedio': roiPromedio,
    };
  }

  Map<String, dynamic> get kpisCupones {
    final cuponesFilt = cuponesFiltrados;
    final disponibles = cuponesFilt.where((c) => c.estaDisponible).length;
    final agotados =
        cuponesFilt.where((c) => c.usosRealizados >= c.limiteUsoGlobal).length;
    final vencidos =
        cuponesFilt.where((c) => DateTime.now().isAfter(c.fechaFin)).length;
    final usosTotal =
        cuponesFilt.fold<int>(0, (sum, item) => sum + item.usosRealizados);

    return {
      'total': cuponesFilt.length,
      'disponibles': disponibles,
      'agotados': agotados,
      'vencidos': vencidos,
      'usos_total': usosTotal,
    };
  }

  // ==============================================
  // MÉTODOS - FILTROS
  // ==============================================

  void setFiltroTexto(String texto) {
    _filtroTexto = texto;
    _buildAllRows();
    notifyListeners();
  }

  void setSucursalFiltro(String? sucursalId) {
    _sucursalIdFiltro = sucursalId;
    _buildAllRows();
    notifyListeners();
  }

  void setRangoFechas(DateTimeRange rango) {
    _rangoFechas = rango;
    _buildAllRows();
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtroTexto = '';
    _sucursalIdFiltro = null;
    _rangoFechas = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    _buildAllRows();
    notifyListeners();
  }

  // ==============================================
  // MÉTODOS - CARGAR DATOS
  // ==============================================

  Future<void> cargarPromocionesActivas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Cargando promociones activas...');

      final response = await supabaseLU
          .from('vw_promociones_activas')
          .select()
          .order('fecha_inicio', ascending: false);

      _promocionesActivas = (response as List<dynamic>)
          .map((json) => PromocionActiva.fromJson(json))
          .toList();

      _buildPromocionesActivasRows();
      log('✅ Promociones activas cargadas: ${_promocionesActivas.length}');
    } catch (e) {
      _error = 'Error al cargar promociones activas: $e';
      log('❌ Error en cargarPromocionesActivas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarPromocionesROI() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Cargando ROI de promociones...');

      final response = await supabaseLU
          .from('vw_promociones_roi')
          .select()
          .order('roi', ascending: false);

      _promocionesROI = (response as List<dynamic>)
          .map((json) => PromocionROI.fromJson(json))
          .toList();

      _buildPromocionesROIRows();
      log('✅ ROI promociones cargado: ${_promocionesROI.length}');
    } catch (e) {
      _error = 'Error al cargar ROI de promociones: $e';
      log('❌ Error en cargarPromocionesROI: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarCuponesPorPromocion(String promocionId) async {
    _isLoadingCupones = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Cargando cupones para promoción: $promocionId');

      final response = await supabaseLU
          .from('cupones')
          .select()
          .eq('promocion_id', promocionId)
          .order('creado_en', ascending: false);

      _cupones = (response as List<dynamic>)
          .map((json) => CuponItem.fromJson(json))
          .toList();

      _buildCuponesRows();
      log('✅ Cupones cargados: ${_cupones.length}');
    } catch (e) {
      _error = 'Error al cargar cupones: $e';
      log('❌ Error en cargarCuponesPorPromocion: $e');
    } finally {
      _isLoadingCupones = false;
      notifyListeners();
    }
  }

  Future<void> cargarSucursales() async {
    try {
      log('🔄 Cargando sucursales...');

      final response = await supabaseLU
          .from('sucursales')
          .select('id, nombre, activa')
          .eq('activa', true)
          .order('nombre');

      _sucursales = (response as List<dynamic>)
          .map((json) => SucursalSimple.fromJson(json))
          .toList();

      log('✅ Sucursales cargadas: ${_sucursales.length}');
    } catch (e) {
      log('❌ Error en cargarSucursales: $e');
    }
  }

  // ==============================================
  // MÉTODOS - OPERACIONES PRINCIPALES
  // ==============================================

  Future<String?> upsertPromocion({
    String? promocionId,
    required String titulo,
    required String descripcion,
    required TipoDescuento tipoDescuento,
    required double valorDescuento,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required bool activo,
    Map<String, dynamic>? condiciones,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 ${promocionId != null ? 'Actualizando' : 'Creando'} promoción...');

      String nuevoPromocionId;

      if (promocionId != null) {
        // Actualizar promoción existente
        log('💾 Actualizando promoción existente: $promocionId');
        final response = await supabaseLU
            .from('promociones')
            .update({
              'titulo': titulo,
              'descripcion': descripcion,
              'tipo_descuento': tipoDescuento.valor,
              'valor_descuento': valorDescuento,
              'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
              'fecha_fin': fechaFin.toIso8601String().split('T')[0],
              'activo': activo,
              'condiciones_json': condiciones ?? {},
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', promocionId)
            .select('id')
            .single();

        nuevoPromocionId = response['id'] as String;
      } else {
        // Crear nueva promoción
        log('💾 Creando promoción...');
        final response = await supabaseLU
            .from('promociones')
            .insert({
              'titulo': titulo,
              'descripcion': descripcion,
              'tipo_descuento': tipoDescuento.valor,
              'valor_descuento': valorDescuento,
              'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
              'fecha_fin': fechaFin.toIso8601String().split('T')[0],
              'activo': activo,
              'condiciones_json': condiciones ?? {},
            })
            .select('id')
            .single();

        nuevoPromocionId = response['id'] as String;
      }

      log('✅ Promoción ${promocionId != null ? 'actualizada' : 'creada'}: $nuevoPromocionId');

      // Recargar promociones activas
      await cargarPromocionesActivas();

      return nuevoPromocionId;
    } catch (e) {
      _error = 'Error al guardar promoción: $e';
      log('❌ Error en upsertPromocion: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ResultadoPublicacion>> publicarPromocionEnSucursales({
    required String promocionId,
    List<String>? sucursalIds,
    bool todasLasSucursales = false,
  }) async {
    _isLoadingPublicacion = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Publicando promoción en sucursales...');

      List<String> sucursalesTarget;

      if (todasLasSucursales) {
        // Obtener todas las sucursales activas
        log('🔍 Consultando sucursales activas...');
        final sucursalesResponse = await supabaseLU
            .from('sucursales')
            .select('id, nombre')
            .eq('activa', true);

        log('📊 Sucursales encontradas: ${sucursalesResponse.length}');
        log('📊 Datos de sucursales: $sucursalesResponse');

        sucursalesTarget = (sucursalesResponse as List<dynamic>)
            .map((s) => s['id'] as String)
            .toList();

        log('🎯 IDs de sucursales target: $sucursalesTarget');
      } else {
        sucursalesTarget = sucursalIds ?? [];
        log('🎯 Sucursales específicas: $sucursalesTarget');
      }

      if (sucursalesTarget.isEmpty) {
        throw Exception('No hay sucursales para publicar');
      }

      // Insertar en promocion_sucursales
      final promocionSucursalesData = sucursalesTarget
          .map((sucursalId) => {
                'promocion_id': promocionId,
                'sucursal_id': sucursalId,
              })
          .toList();

      log('💾 Datos para insertar en promocion_sucursales: $promocionSucursalesData');

      final insertResponse = await supabaseLU
          .from('promocion_sucursales')
          .upsert(promocionSucursalesData,
              onConflict: 'promocion_id,sucursal_id');

      log('✅ Respuesta de inserción: $insertResponse');

      // Crear resultados para cada sucursal
      _ultimosResultadosPublicacion = sucursalesTarget.map((sucursalId) {
        return ResultadoPublicacion(
          sucursalId: sucursalId,
          insertado: true,
          sucursalNombre:
              'Sucursal $sucursalId', // En un caso real, harías join para obtener el nombre
        );
      }).toList();

      log('✅ Promoción publicada en ${_ultimosResultadosPublicacion.length} sucursales');

      // Recargar promociones activas
      await cargarPromocionesActivas();

      return _ultimosResultadosPublicacion;
    } catch (e) {
      _error = 'Error al publicar promoción: $e';
      log('❌ Error en publicarPromocionEnSucursales: $e');
      return [];
    } finally {
      _isLoadingPublicacion = false;
      notifyListeners();
    }
  }

  Future<List<CuponEmitido>> emitirCupones({
    required String promocionId,
    required String prefijo,
    required int cantidad,
    int limiteUsoGlobal = 1,
    int limiteUsoPorCliente = 1,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool activo = true,
  }) async {
    _isLoadingCupones = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Emitiendo $cantidad cupones...');

      final response = await supabaseLU.rpc('emitir_cupones', params: {
        'p_promocion_id': promocionId,
        'p_prefijo': prefijo,
        'p_cantidad': cantidad,
        'p_limite_uso_global': limiteUsoGlobal,
        'p_limite_uso_por_cliente': limiteUsoPorCliente,
        'p_fecha_inicio': fechaInicio?.toIso8601String().split('T')[0],
        'p_fecha_fin': fechaFin?.toIso8601String().split('T')[0],
        'p_activo': activo,
      });

      _ultimosCuponesEmitidos = (response as List<dynamic>)
          .map((json) => CuponEmitido.fromJson(json))
          .toList();

      log('✅ Cupones emitidos: ${_ultimosCuponesEmitidos.length}');

      // Recargar cupones para esta promoción
      await cargarCuponesPorPromocion(promocionId);

      return _ultimosCuponesEmitidos;
    } catch (e) {
      _error = 'Error al emitir cupones: $e';
      log('❌ Error en emitirCupones: $e');
      return [];
    } finally {
      _isLoadingCupones = false;
      notifyListeners();
    }
  }

  Future<ResultadoCanje?> probarCanje({
    required String codigo,
    required String clienteId,
    required String sucursalId,
    String? citaId,
    String? ordenId,
    double? totalBruto,
    String canal = 'web',
  }) async {
    _isLoadingCanje = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Probando canje de cupón: $codigo');

      final response = await supabaseLU.rpc('canjear_cupon', params: {
        'p_codigo': codigo,
        'p_cliente_id': clienteId,
        'p_sucursal_id': sucursalId,
        'p_cita_id': citaId,
        'p_orden_id': ordenId,
        'p_total_bruto': totalBruto,
        'p_canal': canal,
      });

      if (response != null && response is List && response.isNotEmpty) {
        _ultimoResultadoCanje = ResultadoCanje.fromJson(response.first);
        log('✅ Canje probado: ${_ultimoResultadoCanje!.mensaje}');
        return _ultimoResultadoCanje;
      }

      return null;
    } catch (e) {
      _error = 'Error al probar canje: $e';
      log('❌ Error en probarCanje: $e');
      return null;
    } finally {
      _isLoadingCanje = false;
      notifyListeners();
    }
  }

  // ==============================================
  // MÉTODOS - CONSTRUCCIÓN DE ROWS
  // ==============================================

  void _buildPromocionesActivasRows() {
    promocionesActivasRows.clear();

    final promociones = promocionesActivasFiltradas;

    for (int i = 0; i < promociones.length; i++) {
      final promo = promociones[i];
      promocionesActivasRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'titulo': PlutoCell(value: promo.titulo),
        'tipo': PlutoCell(value: promo.tipoDescuento.displayName),
        'valor': PlutoCell(value: promo.valorDescuentoTexto),
        'sucursal': PlutoCell(value: promo.sucursalNombre ?? 'Todas'),
        'inicio':
            PlutoCell(value: promo.fechaInicio.toIso8601String().split('T')[0]),
        'fin': PlutoCell(value: promo.fechaFin.toIso8601String().split('T')[0]),
        'estado': PlutoCell(value: promo.estadoTexto),
        'acciones': PlutoCell(value: promo.promocionId),
      }));
    }

    log('✅ Filas promociones activas construidas: ${promocionesActivasRows.length}');
  }

  void _buildPromocionesROIRows() {
    promocionesROIRows.clear();

    final roi = promocionesROIFiltradas;

    for (int i = 0; i < roi.length; i++) {
      final roiItem = roi[i];
      promocionesROIRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'titulo': PlutoCell(value: roiItem.titulo),
        'canjes': PlutoCell(value: roiItem.canjes),
        'clientes': PlutoCell(value: roiItem.clientesUnicos),
        'descuento': PlutoCell(value: roiItem.descuentoTotal),
        'ingreso_bruto': PlutoCell(value: roiItem.ingresoBruto),
        'ingreso_neto': PlutoCell(value: roiItem.ingresoNeto),
        'roi': PlutoCell(value: roiItem.roi),
        'ticket_promedio': PlutoCell(value: roiItem.ticketPromedio),
        'acciones': PlutoCell(value: roiItem.promocionId),
      }));
    }

    log('✅ Filas ROI construidas: ${promocionesROIRows.length}');
  }

  void _buildCuponesRows() {
    cuponesRows.clear();

    final cuponesFilt = cuponesFiltrados;

    for (int i = 0; i < cuponesFilt.length; i++) {
      final cupon = cuponesFilt[i];
      cuponesRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'codigo': PlutoCell(value: cupon.codigo),
        'usos': PlutoCell(value: cupon.usoTexto),
        'limite_cliente': PlutoCell(value: cupon.limiteUsoPorCliente),
        'vigencia': PlutoCell(
            value:
                '${cupon.fechaInicio.toIso8601String().split('T')[0]} - ${cupon.fechaFin.toIso8601String().split('T')[0]}'),
        'estado': PlutoCell(value: cupon.estadoTexto),
        'creado':
            PlutoCell(value: cupon.creadoEn.toIso8601String().split('T')[0]),
        'acciones': PlutoCell(value: cupon.id),
      }));
    }

    log('✅ Filas cupones construidas: ${cuponesRows.length}');
  }

  void _buildAllRows() {
    _buildPromocionesActivasRows();
    _buildPromocionesROIRows();
    _buildCuponesRows();
  }

  // ==============================================
  // MÉTODOS - EDICIÓN
  // ==============================================

  void iniciarEdicionPromocion(PromocionActiva? promocion) {
    _promocionEnEdicion = promocion;
    notifyListeners();
  }

  void cancelarEdicion() {
    _promocionEnEdicion = null;
    notifyListeners();
  }

  // ==============================================
  // MÉTODOS - UTILIDAD
  // ==============================================

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void limpiarResultados() {
    _ultimosResultadosPublicacion.clear();
    _ultimosCuponesEmitidos.clear();
    _ultimoResultadoCanje = null;
    notifyListeners();
  }

  // ==============================================
  // MÉTODOS - INICIALIZACIÓN
  // ==============================================

  Future<void> inicializar() async {
    await Future.wait([
      cargarPromocionesActivas(),
      cargarPromocionesROI(),
      cargarSucursales(),
    ]);
  }

  Future<void> refrescar() async {
    await inicializar();
  }
}
