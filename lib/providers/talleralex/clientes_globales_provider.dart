import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'dart:developer' as developer;

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/clientes_globales_models.dart';

class ClientesGlobalesProvider extends ChangeNotifier {
  // Estado de carga
  bool _isLoading = false;
  String? _error;

  // Datos principales
  List<ClienteGlobalGrid> _clientes = [];
  List<String> _sucursalesDisponibles = [];
  MetricasGlobales? _metricasGlobales;
  List<MetricaSucursal> _metricasSucursales = [];
  List<ClienteInactivo> _clientesInactivos = [];

  // Historial del cliente seleccionado
  List<HistorialClienteTecnico> _historialTecnico = [];
  List<HistorialClienteFinanciero> _historialFinanciero = [];
  List<SucursalFrecuente> _sucursalesFrecuentes = [];
  String? _clienteSeleccionadoId;

  // Vehículos del cliente seleccionado
  List<VehiculoCliente> _vehiculosActivos = [];
  List<VehiculoCliente> _vehiculosInactivos = [];
  List<HistorialVehiculo> _historialVehiculo = [];
  String? _vehiculoSeleccionadoId;

  // Filtros
  final FiltrosClientesGlobales _filtros = FiltrosClientesGlobales();

  // PlutoGrid
  List<PlutoRow> clientesRows = [];

  // Getters principales
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClienteGlobalGrid> get clientes => _clientes;
  List<ClienteGlobalGrid> get clientesFiltrados {
    return _clientes
        .where((cliente) => _filtros.cumpleFiltros(cliente))
        .toList();
  }

  List<String> get sucursalesDisponibles => _sucursalesDisponibles;
  MetricasGlobales? get metricasGlobales => _metricasGlobales;
  List<MetricaSucursal> get metricasSucursales => _metricasSucursales;
  List<ClienteInactivo> get clientesInactivos => _clientesInactivos;
  FiltrosClientesGlobales get filtros => _filtros;

  // Historial del cliente seleccionado
  List<HistorialClienteTecnico> get historialTecnico => _historialTecnico;
  List<HistorialClienteFinanciero> get historialFinanciero =>
      _historialFinanciero;
  List<SucursalFrecuente> get sucursalesFrecuentes => _sucursalesFrecuentes;
  String? get clienteSeleccionadoId => _clienteSeleccionadoId;

  // Vehículos del cliente seleccionado
  List<VehiculoCliente> get vehiculosActivos => _vehiculosActivos;
  List<VehiculoCliente> get vehiculosInactivos => _vehiculosInactivos;
  List<HistorialVehiculo> get historialVehiculo => _historialVehiculo;
  String? get vehiculoSeleccionadoId => _vehiculoSeleccionadoId;

  // Estadísticas calculadas
  int get totalClientes => _clientes.length;
  int get clientesActivos =>
      _clientes.where((c) => c.estadoCliente == 'Activo').length;
  int get clientesVIP =>
      _clientes.where((c) => c.clasificacionCliente == 'VIP').length;
  double get ingresosTotalesClientes =>
      _clientes.fold(0.0, (sum, c) => sum + c.totalGastado);

  // Segmentación automática
  Map<String, int> get clientesPorClasificacion {
    final Map<String, int> conteo = {};
    for (final cliente in _clientes) {
      conteo[cliente.clasificacionCliente] =
          (conteo[cliente.clasificacionCliente] ?? 0) + 1;
    }
    return conteo;
  }

  Map<String, int> get clientesPorEstado {
    final Map<String, int> conteo = {};
    for (final cliente in _clientes) {
      conteo[cliente.estadoCliente] = (conteo[cliente.estadoCliente] ?? 0) + 1;
    }
    return conteo;
  }

  Map<String, int> get clientesPorSucursal {
    final Map<String, int> conteo = {};
    for (final cliente in _clientes) {
      conteo[cliente.sucursalNombre] =
          (conteo[cliente.sucursalNombre] ?? 0) + 1;
    }
    return conteo;
  }

  /// 1. Cargar todos los clientes globales
  Future<void> cargarClientesGlobales() async {
    try {
      developer.log('🔄 Cargando clientes globales...');

      _isLoading = true;
      _error = null;
      notifyListeners();

      // Consultar vista principal
      final response = await supabaseLU.from('vw_clientes_sucursal').select();

      if (response.isEmpty) {
        developer.log('⚠️ No se encontraron clientes');
        _clientes = [];
      } else {
        _clientes = (response as List)
            .map((map) => ClienteGlobalGrid.fromMap(map))
            .toList();

        // Ordenar por total gastado descendente
        _clientes.sort((a, b) => b.totalGastado.compareTo(a.totalGastado));

        developer.log('✅ ${_clientes.length} clientes cargados');
      }

      // Extraer sucursales únicas
      _extraerSucursalesDisponibles();

      // Construir filas para PlutoGrid
      _buildClientesRows();
    } catch (e) {
      developer.log('❌ Error al cargar clientes: $e');
      _error = 'Error al cargar clientes: $e';
      _clientes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2. Cargar métricas globales del sistema
  Future<void> cargarMetricasGlobales() async {
    try {
      developer.log('🔄 Cargando métricas globales...');

      // Usar vista de métricas globales si existe, sino calcular
      try {
        final response =
            await supabaseLU.from('vw_metricas_globales').select().single();

        _metricasGlobales = MetricasGlobales.fromMap(response);
        developer.log('✅ Métricas globales cargadas desde vista');
      } catch (e) {
        // Si no existe la vista, calcular manualmente
        developer
            .log('⚠️ Vista vw_metricas_globales no disponible, calculando...');
        await _calcularMetricasGlobales();
      }

      notifyListeners();
    } catch (e) {
      developer.log('❌ Error al cargar métricas globales: $e');
      _error = 'Error al cargar métricas: $e';
    }
  }

  /// 3. Cargar métricas por sucursal para comparativo
  Future<void> cargarMetricasSucursales() async {
    try {
      developer.log('🔄 Cargando métricas por sucursal...');

      // Usar vista de métricas por sucursal si existe
      try {
        final response = await supabaseLU
            .from('vw_metricas_sucursal')
            .select('sucursal_id, sucursal_nombre, ingresos_totales');

        _metricasSucursales = (response as List)
            .map((map) => MetricaSucursal.fromMap(map))
            .toList();

        // Ordenar por ingresos descendente
        _metricasSucursales
            .sort((a, b) => b.ingresosTotales.compareTo(a.ingresosTotales));

        // Calcular porcentajes relativos
        final totalIngresos =
            _metricasSucursales.fold(0.0, (sum, m) => sum + m.ingresosTotales);
        for (final metrica in _metricasSucursales) {
          metrica.porcentajeIngresos = totalIngresos > 0
              ? (metrica.ingresosTotales / totalIngresos) * 100
              : 0.0;
        }

        developer.log(
            '✅ ${_metricasSucursales.length} métricas de sucursales cargadas');
      } catch (e) {
        developer.log('⚠️ Vista vw_metricas_sucursal no disponible: $e');
        _metricasSucursales = [];
      }

      notifyListeners();
    } catch (e) {
      developer.log('❌ Error al cargar métricas de sucursales: $e');
    }
  }

  /// 4. Cargar clientes inactivos para alertas
  Future<void> cargarClientesInactivos() async {
    try {
      developer.log('🔄 Cargando clientes inactivos...');

      final response = await supabaseLU.from('vw_clientes_inactivos').select();

      _clientesInactivos = (response as List)
          .map((map) => ClienteInactivo.fromMap(map))
          .toList();

      // Ordenar por días inactivo descendente
      _clientesInactivos
          .sort((a, b) => b.diasInactivo.compareTo(a.diasInactivo));

      developer.log(
          '✅ ${_clientesInactivos.length} clientes inactivos identificados');
      notifyListeners();
    } catch (e) {
      developer.log('❌ Error al cargar clientes inactivos: $e');
      _clientesInactivos = [];
    }
  }

  /// 5. Cargar historial técnico de un cliente
  Future<void> cargarHistorialTecnico(String clienteId) async {
    if (_clienteSeleccionadoId == clienteId && _historialTecnico.isNotEmpty) {
      developer.log('✅ Historial técnico ya cargado para cliente $clienteId');
      return;
    }

    try {
      developer.log('🔄 Cargando historial técnico del cliente $clienteId...');

      _clienteSeleccionadoId = clienteId;

      final response = await supabaseLU
          .from('vw_historial_cliente')
          .select()
          .eq('cliente_id', clienteId)
          .order('fecha_inicio', ascending: false);

      _historialTecnico = (response as List)
          .map((map) => HistorialClienteTecnico.fromMap(map))
          .toList();

      developer
          .log('✅ ${_historialTecnico.length} registros técnicos cargados');
      notifyListeners();
    } catch (e) {
      developer.log('❌ Error al cargar historial técnico: $e');
      _historialTecnico = [];
    }
  }

  /// 6. Cargar historial financiero de un cliente
  Future<void> cargarHistorialFinanciero(String clienteId) async {
    if (_clienteSeleccionadoId == clienteId &&
        _historialFinanciero.isNotEmpty) {
      developer
          .log('✅ Historial financiero ya cargado para cliente $clienteId');
      return;
    }

    try {
      developer
          .log('🔄 Cargando historial financiero del cliente $clienteId...');

      final response = await supabaseLU
          .from('vw_historial_cliente_financiero')
          .select()
          .eq('cliente_id', clienteId)
          .order('fecha_inicio', ascending: false);

      _historialFinanciero = (response as List)
          .map((map) => HistorialClienteFinanciero.fromMap(map))
          .toList();

      developer.log(
          '✅ ${_historialFinanciero.length} registros financieros cargados');
      notifyListeners();
    } catch (e) {
      developer.log('❌ Error al cargar historial financiero: $e');
      _historialFinanciero = [];
    }
  }

  /// 7. Cargar sucursales frecuentes de un cliente
  Future<void> cargarSucursalesFrecuentes(String clienteId) async {
    if (_clienteSeleccionadoId == clienteId &&
        _sucursalesFrecuentes.isNotEmpty) {
      developer
          .log('✅ Sucursales frecuentes ya cargadas para cliente $clienteId');
      return;
    }

    try {
      developer
          .log('🔄 Cargando sucursales frecuentes del cliente $clienteId...');

      final response = await supabaseLU
          .from('vw_clientes_sucursales_frecuentes')
          .select()
          .eq('cliente_id', clienteId)
          .order('total_visitas', ascending: false);

      _sucursalesFrecuentes = (response as List)
          .map((map) => SucursalFrecuente.fromMap(map))
          .toList();

      // Calcular porcentajes relativos
      final totalVisitas =
          _sucursalesFrecuentes.fold(0, (sum, s) => sum + s.totalVisitas);
      for (final sucursal in _sucursalesFrecuentes) {
        sucursal.porcentajeVisitas = totalVisitas > 0
            ? (sucursal.totalVisitas / totalVisitas) * 100
            : 0.0;
      }

      developer.log(
          '✅ ${_sucursalesFrecuentes.length} sucursales frecuentes cargadas');
      notifyListeners();
    } catch (e) {
      developer.log('❌ Error al cargar sucursales frecuentes: $e');
      _sucursalesFrecuentes = [];
    }
  }

  /// 8. Cargar vehículos activos de un cliente
  Future<void> cargarVehiculosActivos(String clienteId) async {
    if (_clienteSeleccionadoId == clienteId && _vehiculosActivos.isNotEmpty) {
      developer.log('✅ Vehículos activos ya cargados para cliente $clienteId');
      return;
    }

    try {
      developer.log('🔄 Cargando vehículos activos del cliente $clienteId...');

      _clienteSeleccionadoId = clienteId;

      final response = await supabaseLU
          .from('vehiculos')
          .select('''
            id, cliente_id, marca, modelo, anio, placa, color, vin, combustible, activo,
            fotos_vehiculo!left(archivo_id, tipo, archivos!left(path))
          ''')
          .eq('cliente_id', clienteId)
          .eq('activo', true)
          .order('created_at', ascending: false);

      _vehiculosActivos = (response as List).map((vehiculoData) {
        // Extraer la foto principal (frontal o primera disponible)
        final fotos = vehiculoData['fotos_vehiculo'] as List? ?? [];
        String? fotoId;
        String? fotoPath;
        String? fotoTipo;

        if (fotos.isNotEmpty) {
          final fotoFrontal = fotos.firstWhere(
            (foto) => foto['tipo'] == 'frontal',
            orElse: () => fotos.first,
          );

          fotoId = fotoFrontal['archivo_id'];
          fotoTipo = fotoFrontal['tipo'];
          if (fotoFrontal['archivos'] != null) {
            fotoPath = fotoFrontal['archivos']['path'];
          }
        }

        return VehiculoCliente.fromMap({
          ...vehiculoData,
          'foto_id': fotoId,
          'foto_path': fotoPath,
          'foto_tipo': fotoTipo,
        });
      }).toList();

      developer.log('✅ ${_vehiculosActivos.length} vehículos activos cargados');
      notifyListeners();
    } catch (e) {
      developer.log('❌ Error al cargar vehículos activos: $e');
      _vehiculosActivos = [];
    }
  }

  /// 9. Cargar vehículos inactivos de un cliente
  Future<void> cargarVehiculosInactivos(String clienteId) async {
    if (_clienteSeleccionadoId == clienteId && _vehiculosInactivos.isNotEmpty) {
      developer
          .log('✅ Vehículos inactivos ya cargados para cliente $clienteId');
      return;
    }

    try {
      developer
          .log('🔄 Cargando vehículos inactivos del cliente $clienteId...');

      final response = await supabaseLU
          .from('vehiculos')
          .select('''
            id, cliente_id, marca, modelo, anio, placa, color, vin, combustible, activo,
            fotos_vehiculo!left(archivo_id, tipo, archivos!left(path))
          ''')
          .eq('cliente_id', clienteId)
          .eq('activo', false)
          .order('created_at', ascending: false);

      _vehiculosInactivos = (response as List).map((vehiculoData) {
        // Extraer la foto principal
        final fotos = vehiculoData['fotos_vehiculo'] as List? ?? [];
        String? fotoId;
        String? fotoPath;
        String? fotoTipo;

        if (fotos.isNotEmpty) {
          final fotoFrontal = fotos.firstWhere(
            (foto) => foto['tipo'] == 'frontal',
            orElse: () => fotos.first,
          );

          fotoId = fotoFrontal['archivo_id'];
          fotoTipo = fotoFrontal['tipo'];
          if (fotoFrontal['archivos'] != null) {
            fotoPath = fotoFrontal['archivos']['path'];
          }
        }

        return VehiculoCliente.fromMap({
          ...vehiculoData,
          'foto_id': fotoId,
          'foto_path': fotoPath,
          'foto_tipo': fotoTipo,
        });
      }).toList();

      developer
          .log('✅ ${_vehiculosInactivos.length} vehículos inactivos cargados');
      notifyListeners();
    } catch (e) {
      developer.log('❌ Error al cargar vehículos inactivos: $e');
      _vehiculosInactivos = [];
    }
  }

  /// 10. Cargar historial de órdenes de un vehículo específico
  Future<void> cargarHistorialVehiculo(String vehiculoId) async {
    if (_vehiculoSeleccionadoId == vehiculoId &&
        _historialVehiculo.isNotEmpty) {
      developer.log('✅ Historial de vehículo ya cargado para $vehiculoId');
      return;
    }

    try {
      developer.log('🔄 Cargando historial del vehículo $vehiculoId...');

      _vehiculoSeleccionadoId = vehiculoId;

      final response = await supabaseLU
          .from('vw_historial_vehiculo')
          .select()
          .eq('vehiculo_id', vehiculoId)
          .order('fecha_inicio', ascending: false);

      _historialVehiculo = (response as List)
          .map((item) => HistorialVehiculo.fromMap(item))
          .toList();

      developer.log(
          '✅ ${_historialVehiculo.length} registros de historial cargados');
      notifyListeners();
    } catch (e) {
      developer.log('❌ Error al cargar historial del vehículo: $e');
      _historialVehiculo = [];
    }
  }

  /// 11. Cargar todos los vehículos de un cliente (activos + inactivos)
  Future<void> cargarTodosLosVehiculos(String clienteId) async {
    await Future.wait([
      cargarVehiculosActivos(clienteId),
      cargarVehiculosInactivos(clienteId),
    ]);
  }

  /// 12. Cargar historial completo de un cliente (técnico + financiero + sucursales + vehículos)
  Future<void> cargarHistorialCompleto(String clienteId) async {
    await Future.wait([
      cargarHistorialTecnico(clienteId),
      cargarHistorialFinanciero(clienteId),
      cargarSucursalesFrecuentes(clienteId),
      cargarTodosLosVehiculos(clienteId),
    ]);
  }

  /// Métodos de filtrado
  void filtrarPorTexto(String searchTerm) {
    _filtros.searchTerm = searchTerm;
    aplicarFiltros();
  }

  void filtrarPorSucursal(String? sucursalId) {
    _filtros.sucursalId = sucursalId;
    aplicarFiltros();
  }

  void filtrarPorClasificacion(String? clasificacion) {
    _filtros.clasificacion = clasificacion;
    aplicarFiltros();
  }

  void filtrarPorEstado(String? estado) {
    _filtros.estado = estado;
    aplicarFiltros();
  }

  void filtrarPorRangoGasto(double? minimo, double? maximo) {
    _filtros.gastoMinimo = minimo;
    _filtros.gastoMaximo = maximo;
    aplicarFiltros();
  }

  void filtrarPorFechaVisita(DateTime? desde, DateTime? hasta) {
    _filtros.ultimaVisitaDesde = desde;
    _filtros.ultimaVisitaHasta = hasta;
    aplicarFiltros();
  }

  /// Aplicar filtros y actualizar UI
  void aplicarFiltros() {
    _buildClientesRows();
    notifyListeners();
  }

  /// Limpiar todos los filtros
  void limpiarFiltros() {
    _filtros.limpiar();
    aplicarFiltros();
  }

  /// Segmentación rápida predefinida
  void aplicarSegmentacionVIP() {
    _filtros.limpiar();
    _filtros.clasificacion = 'VIP';
    aplicarFiltros();
  }

  void aplicarSegmentacionInactivos(int diasMinimos) {
    _filtros.limpiar();
    final fechaLimite = DateTime.now().subtract(Duration(days: diasMinimos));
    _filtros.ultimaVisitaHasta = fechaLimite;
    aplicarFiltros();
  }

  void aplicarSegmentacionAltoValor(double montoMinimo) {
    _filtros.limpiar();
    _filtros.gastoMinimo = montoMinimo;
    aplicarFiltros();
  }

  /// Obtener cliente por ID
  ClienteGlobalGrid? getClienteById(String clienteId) {
    try {
      return _clientes.firstWhere((cliente) => cliente.clienteId == clienteId);
    } catch (e) {
      return null;
    }
  }

  /// Calcular métricas globales manualmente si no existe la vista
  Future<void> _calcularMetricasGlobales() async {
    try {
      // Contar total de clientes únicos
      final clientesResponse = await supabaseLU.from('clientes').select('id');

      final totalClientes = (clientesResponse as List).length;

      // Contar órdenes abiertas y cerradas
      final ordenesResponse =
          await supabaseLU.from('ordenes_servicio').select('estado');

      final ordenes = ordenesResponse as List;
      final ordenesAbiertas = ordenes
          .where((o) =>
              o['estado'] != 'cerrada' &&
              o['estado'] != 'entregada' &&
              o['estado'] != 'cancelada')
          .length;

      final ordenesCerradas = ordenes
          .where((o) => o['estado'] == 'cerrada' || o['estado'] == 'entregada')
          .length;

      // Sumar ingresos totales de pagos
      final pagosResponse =
          await supabaseLU.from('pagos').select('monto').eq('estado', 'pagado');

      final ingresosTotales = (pagosResponse as List)
          .fold(0.0, (sum, pago) => sum + (pago['monto'] ?? 0).toDouble());

      _metricasGlobales = MetricasGlobales(
        totalClientes: totalClientes,
        ordenesAbiertas: ordenesAbiertas,
        ordenesCerradas: ordenesCerradas,
        ingresosTotales: ingresosTotales,
      );

      developer.log('✅ Métricas globales calculadas manualmente');
    } catch (e) {
      developer.log('❌ Error al calcular métricas globales: $e');
    }
  }

  /// Extraer sucursales únicas de los clientes
  void _extraerSucursalesDisponibles() {
    final sucursalesSet = <String, String>{};

    for (final cliente in _clientes) {
      sucursalesSet[cliente.sucursalId] = cliente.sucursalNombre;
    }

    _sucursalesDisponibles = sucursalesSet.values.toList()..sort();
  }

  /// Construir filas para PlutoGrid
  void _buildClientesRows() {
    clientesRows.clear();

    final clientesFiltrados = this.clientesFiltrados;

    for (int i = 0; i < clientesFiltrados.length; i++) {
      final cliente = clientesFiltrados[i];
      clientesRows.add(cliente.toPlutoRow(i));
    }
  }

  /// Limpiar datos del historial al cambiar de cliente
  void limpiarHistorialCliente() {
    _clienteSeleccionadoId = null;
    _historialTecnico = [];
    _historialFinanciero = [];
    _sucursalesFrecuentes = [];
    _vehiculosActivos = [];
    _vehiculosInactivos = [];
    _historialVehiculo = [];
    _vehiculoSeleccionadoId = null;
    notifyListeners();
  }

  /// Limpiar datos del historial de vehículo al cambiar de vehículo
  void limpiarHistorialVehiculo() {
    _vehiculoSeleccionadoId = null;
    _historialVehiculo = [];
    notifyListeners();
  }

  /// Obtener vehículo por ID
  VehiculoCliente? getVehiculoById(String vehiculoId) {
    try {
      // Buscar en vehículos activos primero
      try {
        return _vehiculosActivos.firstWhere((v) => v.vehiculoId == vehiculoId);
      } catch (e) {
        // Si no está en activos, buscar en inactivos
        return _vehiculosInactivos
            .firstWhere((v) => v.vehiculoId == vehiculoId);
      }
    } catch (e) {
      return null;
    }
  }

  /// Recargar todos los datos principales
  Future<void> recargarDatos() async {
    await Future.wait([
      cargarClientesGlobales(),
      cargarMetricasGlobales(),
      cargarMetricasSucursales(),
      cargarClientesInactivos(),
    ]);
  }

  /// Getter para acceder a las métricas globales
  MetricasGlobales? get metricas => _metricasGlobales;

  /// Buscar clientes por nombre, teléfono o email
  void buscarClientes(String termino) {
    _filtros.terminoBusqueda = termino.toLowerCase();
    notifyListeners();
  }

  /// Verificar si hay filtros activos
  bool get tieneFiltrosActivos {
    return _filtros.terminoBusqueda.isNotEmpty ||
        _filtros.clasificacionSeleccionada != null ||
        _filtros.estadoSeleccionado != null ||
        _filtros.sucursalSeleccionada != null ||
        _filtros.fechaInicioFiltro != null ||
        _filtros.fechaFinFiltro != null;
  }
}
