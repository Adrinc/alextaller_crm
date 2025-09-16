import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/inventario_global_models.dart';

class InventarioGlobalProvider extends ChangeNotifier {
  // Estado de carga
  bool _isLoading = false;
  bool _isLoadingRedistribucion = false;
  String? _error;

  // Parámetros de consulta
  String? _sucursalIdFiltro;
  String _busquedaTexto = '';
  int _limit = 200;
  int _offset = 0;

  // Filtros adicionales
  int _filtroNivelStock = 0; // 0: Todos, 1: Bajo, 2: Sin stock, 3: Sobrestock
  String _filtroCategoria = '';
  String _filtroSucursal = '';
  String _filtroRefaccion = '';

  // Datos del inventario bundle
  InventarioGlobalBundle? _inventarioBundle;

  // Predicción y sugerencias (opcional)
  List<PrediccionDemandaItem> _prediccionDemanda = [];
  List<SugerenciaReordenItem> _sugerenciasReorden = [];

  // Lista de filas para PlutoGrid
  List<PlutoRow> inventarioRows = [];

  // Getters básicos
  bool get isLoading => _isLoading;
  bool get isLoadingRedistribucion => _isLoadingRedistribucion;
  String? get error => _error;
  String get busquedaTexto => _busquedaTexto;
  int get limit => _limit;
  int get offset => _offset;

  // Getters de filtros
  int get filtroNivelStock => _filtroNivelStock;
  String get filtroCategoria => _filtroCategoria;
  String get filtroSucursal => _filtroSucursal;
  String get filtroRefaccion => _filtroRefaccion;

  // Getters de datos
  InventarioGlobalBundle? get inventarioBundle => _inventarioBundle;

  List<InventarioDetalleItem> get inventarioDetalle =>
      _inventarioBundle?.detalle ?? [];

  List<InventarioAlertaItem> get alertasStock =>
      _inventarioBundle?.alertas ?? [];

  List<InventarioCaducidadItem> get inventarioCaducidad =>
      _inventarioBundle?.caducidad ?? [];

  List<InventarioResumenItem> get inventarioResumen =>
      _inventarioBundle?.resumen ?? [];

  List<RefaccionRotacionItem> get rotacionMensual =>
      _inventarioBundle?.rotacion ?? [];

  List<PrediccionDemandaItem> get prediccionDemanda => _prediccionDemanda;
  List<SugerenciaReordenItem> get sugerenciasReorden => _sugerenciasReorden;

  // Alias para compatibilidad con widgets existentes
  List<InventarioCaducidadItem> get refaccionesPorCaducar =>
      inventarioCaducidad;

  // KPIs calculados
  Map<String, dynamic> get kpis {
    if (_inventarioBundle == null) return {};

    return {
      'total_refacciones': _inventarioBundle!.totalRefacciones,
      'valor_total': _inventarioBundle!.valorTotal,
      'sin_stock': _inventarioBundle!.totalSinStock,
      'stock_bajo': _inventarioBundle!.totalStockBajo,
      'alertas_caducidad': _inventarioBundle!.totalPorCaducar,
      'sucursales_activas': _inventarioBundle!.sucursalesActivas,
      'sugerencias_compra': _sugerenciasReorden.length,
    };
  }

  // Getters filtrados para compatibilidad con widgets existentes
  List<Map<String, dynamic>> get inventarioFiltrado {
    return inventarioDetalle
        .map((item) => {
              'refaccion_id': item.refaccionId,
              'sucursal_id': item.sucursalId,
              'sucursal_nombre': item.sucursalNombre,
              'sku': item.sku,
              'nombre': item.nombre,
              'nombre_refaccion': item.nombre, // Alias para compatibilidad
              'categoria':
                  'General', // Campo temporal mientras se agrega a la BD
              'marca': item.proveedor ?? 'N/A', // Temporal
              'modelo': 'N/A', // Temporal
              'ubicacion': 'N/A', // Temporal
              'descripcion': item.descripcion,
              'proveedor': item.proveedor,
              'precio_unitario': item.precioUnitario,
              'existencias': item.existencias,
              'stock_actual': item.existencias, // Alias para compatibilidad
              'minimo_alerta': item.minimoAlerta,
              'stock_minimo': item.minimoAlerta, // Alias para compatibilidad
              'activo': item.activo,
              'imagen_id': item.imagenId,
              'imagen_path': item.imagenPath,
            })
        .where((item) {
      // Aplicar filtro de texto de búsqueda (nombre de refacción)
      if (_filtroRefaccion.isNotEmpty) {
        final searchText = _filtroRefaccion.toLowerCase();
        final nombre = (item['nombre']?.toString() ?? '').toLowerCase();
        final sku = (item['sku']?.toString() ?? '').toLowerCase();
        final proveedor = (item['proveedor']?.toString() ?? '').toLowerCase();

        if (!nombre.contains(searchText) &&
            !sku.contains(searchText) &&
            !proveedor.contains(searchText)) {
          return false;
        }
      }

      // Aplicar filtro de sucursal por NOMBRE (no por ID)
      if (_filtroSucursal.isNotEmpty) {
        final sucursalNombre =
            (item['sucursal_nombre']?.toString() ?? '').toLowerCase();
        if (!sucursalNombre.contains(_filtroSucursal.toLowerCase())) {
          return false;
        }
      }

      // Aplicar filtro de nivel de stock
      if (_filtroNivelStock != 0) {
        final stockActual =
            int.tryParse(item['stock_actual']?.toString() ?? '0') ?? 0;
        final stockMinimo =
            int.tryParse(item['stock_minimo']?.toString() ?? '0') ?? 0;

        switch (_filtroNivelStock) {
          case 1: // Stock Bajo - stock actual > 0 pero <= stock mínimo
            if (stockActual == 0 || stockActual > stockMinimo) {
              return false;
            }
            break;
          case 2: // Sin Stock - stock actual == 0
            if (stockActual != 0) {
              return false;
            }
            break;
          case 3: // Sobrestock - stock actual > doble del mínimo
            if (stockMinimo == 0 || stockActual <= stockMinimo * 2) {
              return false;
            }
            break;
        }
      }

      return true;
    }).toList();
  }

  // Métodos de filtrado y búsqueda
  void setBusquedaTexto(String texto) {
    _busquedaTexto = texto;
    _filtroRefaccion = texto; // Mantener sincronizado
    _buildInventarioRows(); // Reconstruir filas cuando cambie el filtro
    notifyListeners();
  }

  void setSucursalFiltro(String? sucursalId) {
    _sucursalIdFiltro = sucursalId;
    _buildInventarioRows(); // Reconstruir filas cuando cambie el filtro
    notifyListeners();
  }

  void setLimit(int newLimit) {
    _limit = newLimit;
  }

  void setOffset(int newOffset) {
    _offset = newOffset;
  }

  void limpiarFiltros() {
    _busquedaTexto = '';
    _sucursalIdFiltro = null;
    _filtroNivelStock = 0;
    _filtroCategoria = '';
    _filtroSucursal = '';
    _filtroRefaccion = '';
    _offset = 0;
    _buildInventarioRows(); // Reconstruir filas después de limpiar filtros
    notifyListeners();
  }

  // Cargar datos completos del inventario global usando RPC
  Future<void> cargarInventarioGlobal({
    String? sucursalId,
    String? busqueda,
    int? limit,
    int? offset,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Cargando inventario global completo...');

      // Preparar parámetros para la función RPC
      final params = <String, dynamic>{};

      if (sucursalId != null) params['p_sucursal_id'] = sucursalId;
      if (busqueda != null && busqueda.isNotEmpty) params['p_q'] = busqueda;
      if (limit != null) params['p_limit'] = limit;
      if (offset != null) params['p_offset'] = offset;

      // Llamar a la función RPC inventario_global_bundle
      final response =
          await supabaseLU.rpc('inventario_global_bundle', params: params);

      if (response != null) {
        // Parsear el resultado usando el modelo InventarioGlobalBundle
        _inventarioBundle =
            InventarioGlobalBundle.fromJson(response as Map<String, dynamic>);

        log('✅ Inventario global cargado:');
        log('  - Detalle: ${_inventarioBundle!.detalle.length} items');
        log('  - Alertas: ${_inventarioBundle!.alertas.length} items');
        log('  - Caducidad: ${_inventarioBundle!.caducidad.length} items');
        log('  - Resumen: ${_inventarioBundle!.resumen.length} items');
        log('  - Rotación: ${_inventarioBundle!.rotacion.length} items');

        // Cargar datos adicionales opcionales
        await _cargarDatosAdicionales(sucursalId);

        // Construir filas para PlutoGrid
        _buildInventarioRows();
      } else {
        log('❌ No se recibieron datos del inventario global');
        _error = 'No se pudieron cargar los datos del inventario';
      }
    } catch (e) {
      _error = 'Error al cargar inventario global: $e';
      log('❌ Error en cargarInventarioGlobal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar datos adicionales opcionales (predicción y sugerencias)
  Future<void> _cargarDatosAdicionales(String? sucursalId) async {
    try {
      // Cargar predicción de demanda si existe la función
      await _cargarPrediccionDemanda(sucursalId);

      // Cargar sugerencias de reorden si existe la función
      await _cargarSugerenciasReorden(sucursalId);
    } catch (e) {
      log('⚠️ Error cargando datos adicionales: $e');
      // No es crítico, continuar sin estos datos
    }
  }

  // Construir filas para PlutoGrid usando datos de inventarioDetalle
  void _buildInventarioRows() {
    inventarioRows.clear();

    final inventario = inventarioFiltrado;

    for (int i = 0; i < inventario.length; i++) {
      final item = inventario[i];
      final stockActual =
          int.tryParse(item['stock_actual']?.toString() ?? '0') ?? 0;
      final stockMinimo =
          int.tryParse(item['stock_minimo']?.toString() ?? '0') ?? 0;
      final precioUnitario =
          double.tryParse(item['precio_unitario']?.toString() ?? '0') ?? 0.0;
      final valorTotal = stockActual * precioUnitario;

      String estadoStock = 'Normal';
      if (stockActual == 0) {
        estadoStock = 'Sin Stock';
      } else if (stockActual <= stockMinimo) {
        estadoStock = 'Stock Bajo';
      } else if (stockMinimo > 0 && stockActual > stockMinimo * 2) {
        estadoStock = 'Sobrestock';
      }

      inventarioRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'nombre_refaccion':
            PlutoCell(value: item['nombre_refaccion']?.toString() ?? ''),
        'categoria':
            PlutoCell(value: item['categoria']?.toString() ?? 'General'),
        'sucursal_nombre':
            PlutoCell(value: item['sucursal_nombre']?.toString() ?? ''),
        'stock_actual': PlutoCell(value: stockActual),
        'stock_minimo': PlutoCell(value: stockMinimo),
        'precio_unitario': PlutoCell(value: precioUnitario),
        'valor_total': PlutoCell(value: valorTotal),
        'estado_stock': PlutoCell(value: estadoStock),
        'acciones':
            PlutoCell(value: item), // Pasamos todo el objeto para las acciones
      }));
    }

    log('✅ Filas de inventario construidas: ${inventarioRows.length}');
  }

  Future<void> _cargarPrediccionDemanda(String? sucursalId) async {
    try {
      final params = <String, dynamic>{};
      if (sucursalId != null) params['p_sucursal_id'] = sucursalId;
      params['p_dias'] = 30; // Ventana de 30 días por defecto

      final response =
          await supabaseLU.rpc('prediccion_demanda_mvp', params: params);

      if (response != null && response is List) {
        _prediccionDemanda = response
            .map((item) => PrediccionDemandaItem.fromJson(item))
            .toList();
        log('✅ Predicción de demanda cargada: ${_prediccionDemanda.length} items');
      }
    } catch (e) {
      log('⚠️ Función prediccion_demanda_mvp no disponible: $e');
    }
  }

  Future<void> _cargarSugerenciasReorden(String? sucursalId) async {
    try {
      final params = <String, dynamic>{};
      if (sucursalId != null) params['p_sucursal_id'] = sucursalId;
      params['p_lead_time_dias'] = 7; // 7 días de tiempo de entrega
      params['p_safety_dias'] = 3; // 3 días de stock de seguridad

      final response =
          await supabaseLU.rpc('sugerencias_reorden', params: params);

      if (response != null && response is List) {
        _sugerenciasReorden = response
            .map((item) => SugerenciaReordenItem.fromJson(item))
            .toList();
        log('✅ Sugerencias de reorden cargadas: ${_sugerenciasReorden.length} items');
      }
    } catch (e) {
      log('⚠️ Función sugerencias_reorden no disponible: $e');
    }
  }

  // Redistribuir refacción entre sucursales
  Future<RedistribucionResult?> redistribuirRefaccion({
    required String refaccionOrigenId,
    required String sucursalDestinoId,
    required int cantidad,
    required String usuarioId,
    String motivo = 'redistribución',
  }) async {
    if (_isLoadingRedistribucion) return null;

    _isLoadingRedistribucion = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Redistribuyendo refacción: $refaccionOrigenId a $sucursalDestinoId');

      final response = await supabaseLU.rpc('redistribuir_refaccion', params: {
        'p_refaccion_origen_id': refaccionOrigenId,
        'p_sucursal_destino': sucursalDestinoId,
        'p_cantidad': cantidad,
        'p_usuario_id': usuarioId,
        'p_motivo': motivo,
      });

      if (response != null && response is List && response.isNotEmpty) {
        final result = RedistribucionResult.fromJson(response.first);
        log('✅ Redistribución exitosa: ${result.movimientoSalidaId}');

        // Recargar datos para reflejar los cambios
        await cargarInventarioGlobal();

        return result;
      } else {
        _error = 'Error en la redistribución: respuesta inválida';
        log('❌ Error en redistribución: respuesta inválida');
        return null;
      }
    } catch (e) {
      _error = 'Error en redistribución: $e';
      log('❌ Error en redistribuirRefaccion: $e');
      return null;
    } finally {
      _isLoadingRedistribucion = false;
      notifyListeners();
    }
  }

  // Obtener sucursales disponibles para redistribución
  List<Map<String, dynamic>> getSucursalesParaRedistribucion(
      String refaccionId) {
    final sucursalesConStock = <String, Map<String, dynamic>>{};

    for (var item in inventarioDetalle) {
      if (item.refaccionId == refaccionId && item.existencias > 0) {
        sucursalesConStock[item.sucursalId] = {
          'sucursal_id': item.sucursalId,
          'sucursal_nombre': item.sucursalNombre,
          'existencias': item.existencias,
        };
      }
    }

    return sucursalesConStock.values.toList();
  }

  // Obtener todas las sucursales disponibles (para filtros)
  List<String> get sucursalesDisponibles {
    final sucursales = <String>{};
    for (var item in inventarioDetalle) {
      if (item.sucursalNombre.isNotEmpty) {
        sucursales.add(item.sucursalNombre);
      }
    }
    return sucursales.toList()..sort();
  }

  // Obtener todos los proveedores disponibles (para filtros)
  List<String> get proveedoresDisponibles {
    final proveedores = <String>{};
    for (var item in inventarioDetalle) {
      if (item.proveedor != null && item.proveedor!.isNotEmpty) {
        proveedores.add(item.proveedor!);
      }
    }
    return proveedores.toList()..sort();
  }

  // Métodos de compatibilidad con widgets existentes
  void setFiltroRefaccion(String filtro) {
    _filtroRefaccion = filtro;
    setBusquedaTexto(filtro);
  }

  void setFiltroSucursal(String filtro) {
    _filtroSucursal = filtro;
    _buildInventarioRows(); // Reconstruir filas cuando cambie el filtro
    notifyListeners();
  }

  void setFiltroCategoria(String filtro) {
    _filtroCategoria = filtro;
    _buildInventarioRows(); // Reconstruir filas cuando cambie el filtro
    notifyListeners();
  }

  void setFiltroNivelStock(int filtro) {
    _filtroNivelStock = filtro;
    log('🔍 Filtro nivel stock aplicado: $filtro (0=Todos, 1=Bajo, 2=Sin stock, 3=Sobrestock)');
    _buildInventarioRows(); // Reconstruir filas cuando cambie el filtro
    notifyListeners();
  }

  List<String> get categoriasDisponibles =>
      []; // Por implementar si es necesario

  // Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  // Refrescar datos
  Future<void> refrescar() async {
    await cargarInventarioGlobal(
      sucursalId: _sucursalIdFiltro,
      busqueda: _busquedaTexto.isEmpty ? null : _busquedaTexto,
      limit: _limit,
      offset: _offset,
    );
  }
}
