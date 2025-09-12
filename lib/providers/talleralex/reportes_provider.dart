import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../helpers/globals.dart';
import '../../models/talleralex/reportes_models.dart';

class ReportesProvider extends ChangeNotifier {
  // ============================================================================
  // ESTADO GENERAL
  // ============================================================================

  bool _isLoading = false;
  String? _error;
  String _sucursalId = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sucursalId => _sucursalId;

  // ============================================================================
  // DATOS PRINCIPALES
  // ============================================================================

  KPIsReportes? _kpis;
  List<ResumenSucursal> _resumenSucursal = [];
  List<IngresosSucursal> _ingresosSucursal = [];
  List<ServicioTop> _serviciosTop = [];
  List<RefaccionTop> _refaccionesTop = [];
  List<ClienteFrecuente> _clientesFrecuentes = [];
  List<TecnicoProductivo> _tecnicosProductivos = [];
  List<AlertaOperativa> _alertas = [];

  // Getters
  KPIsReportes? get kpis => _kpis;
  List<ResumenSucursal> get resumenSucursal => _resumenSucursal;
  List<IngresosSucursal> get ingresosSucursal => _ingresosSucursal;
  List<ServicioTop> get serviciosTop => _serviciosTop;
  List<RefaccionTop> get refaccionesTop => _refaccionesTop;
  List<ClienteFrecuente> get clientesFrecuentes => _clientesFrecuentes;
  List<TecnicoProductivo> get tecnicosProductivos => _tecnicosProductivos;
  List<AlertaOperativa> get alertas => _alertas;

  // ============================================================================
  // FILTROS
  // ============================================================================

  FiltrosReportes _filtros = const FiltrosReportes();
  FiltrosReportes get filtros => _filtros;

  void actualizarFiltros(FiltrosReportes nuevosFiltros) {
    _filtros = nuevosFiltros;
    notifyListeners();
    cargarReportes(); // Recargar datos con nuevos filtros
  }

  // ============================================================================
  // PLUTO GRID ROWS
  // ============================================================================

  List<PlutoRow> clientesFrecuentesRows = [];
  List<PlutoRow> tecnicosProductivosRows = [];
  List<PlutoRow> alertasRows = [];

  // ============================================================================
  // INICIALIZACIÓN
  // ============================================================================

  void inicializar(String sucursalId) {
    _sucursalId = sucursalId;
    cargarReportes();
  }

  // ============================================================================
  // CARGA DE DATOS
  // ============================================================================

  Future<void> cargarReportes() async {
    if (_sucursalId.isEmpty) return;

    _setLoading(true);
    _error = null;

    try {
      await Future.wait([
        _cargarKPIs(),
        _cargarResumenSucursal(),
        _cargarIngresosSucursal(),
        _cargarServiciosTop(),
        _cargarRefaccionesTop(),
        _cargarClientesFrecuentes(),
        _cargarTecnicosProductivos(),
        _cargarAlertas(),
      ]);

      _buildRows();
    } catch (e) {
      _error = 'Error al cargar reportes: $e';
      if (kDebugMode) print('Error cargarReportes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // CARGA INDIVIDUAL DE DATOS
  // ============================================================================

  Future<void> _cargarKPIs() async {
    try {
      // Simulación de datos - en producción serían queries reales
      _kpis = const KPIsReportes(
        totalCitas: 156,
        citasCompletadas: 142,
        citasCanceladas: 14,
        totalOrdenes: 134,
        ordenesAbiertas: 23,
        ordenesCerradas: 111,
        ingresosMes: 87540.50,
        porcentajeOcupacionBahias: 78.5,
        topServicio: 'Cambio de aceite',
        topServicioVeces: 45,
      );
    } catch (e) {
      if (kDebugMode) print('Error _cargarKPIs: $e');
    }
  }

  Future<void> _cargarResumenSucursal() async {
    try {
      final response = await supabaseLU
          .from('vw_resumen_sucursal')
          .select()
          .eq('sucursal_id', _sucursalId)
          .order('periodo', ascending: false)
          .limit(12);

      _resumenSucursal = (response as List)
          .map((json) => ResumenSucursal.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) print('Error _cargarResumenSucursal: $e');
      // Datos de ejemplo en caso de error
      _resumenSucursal = [
        ResumenSucursal(
          sucursalId: _sucursalId,
          sucursalNombre: 'Sucursal Principal',
          periodo: DateTime.now(),
          totalCitas: 156,
          citasCompletadas: 142,
          citasCanceladas: 14,
          totalOrdenes: 134,
          ordenesAbiertas: 23,
          ordenesCerradas: 111,
        ),
      ];
    }
  }

  Future<void> _cargarIngresosSucursal() async {
    try {
      final fechaInicio = DateTime.now().subtract(const Duration(days: 30));
      final fechaFin = DateTime.now();

      final response = await supabaseLU
          .from('vw_ingresos_sucursal')
          .select()
          .eq('sucursal_id', _sucursalId)
          .gte('fecha', fechaInicio.toIso8601String())
          .lte('fecha', fechaFin.toIso8601String())
          .order('fecha', ascending: true);

      _ingresosSucursal = (response as List)
          .map((json) => IngresosSucursal.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) print('Error _cargarIngresosSucursal: $e');
      // Datos de ejemplo
      _ingresosSucursal = List.generate(30, (index) {
        final fecha = DateTime.now().subtract(Duration(days: 29 - index));
        return IngresosSucursal(
          sucursalId: _sucursalId,
          sucursalNombre: 'Sucursal Principal',
          fecha: fecha,
          totalPagado: 2500 + (index * 100),
          totalPendiente: 800 + (index * 50),
          totalFallido: 200 + (index * 10),
        );
      });
    }
  }

  Future<void> _cargarServiciosTop() async {
    try {
      final response = await supabaseLU
          .from('vw_servicios_top_sucursal')
          .select()
          .eq('sucursal_id', _sucursalId)
          .order('veces_solicitado', ascending: false)
          .limit(10);

      _serviciosTop =
          (response as List).map((json) => ServicioTop.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) print('Error _cargarServiciosTop: $e');
      // Datos de ejemplo
      _serviciosTop = [
        const ServicioTop(
          sucursalId: '',
          sucursalNombre: 'Sucursal Principal',
          servicioNombre: 'Cambio de aceite',
          vecesSolicitado: 45,
          totalIngresos: 13500.00,
        ),
        const ServicioTop(
          sucursalId: '',
          sucursalNombre: 'Sucursal Principal',
          servicioNombre: 'Alineación y balanceo',
          vecesSolicitado: 32,
          totalIngresos: 19200.00,
        ),
        const ServicioTop(
          sucursalId: '',
          sucursalNombre: 'Sucursal Principal',
          servicioNombre: 'Revisión de frenos',
          vecesSolicitado: 28,
          totalIngresos: 16800.00,
        ),
      ];
    }
  }

  Future<void> _cargarRefaccionesTop() async {
    try {
      final response = await supabaseLU
          .from('vw_refacciones_top_sucursal')
          .select()
          .eq('sucursal_id', _sucursalId)
          .order('total_usada', ascending: false)
          .limit(10);

      _refaccionesTop = (response as List)
          .map((json) => RefaccionTop.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) print('Error _cargarRefaccionesTop: $e');
      // Datos de ejemplo
      _refaccionesTop = [
        const RefaccionTop(
          sucursalId: '',
          sucursalNombre: 'Sucursal Principal',
          refaccionNombre: 'Aceite sintético 5W-30',
          totalUsada: 180.5,
          totalIngresos: 9025.00,
        ),
        const RefaccionTop(
          sucursalId: '',
          sucursalNombre: 'Sucursal Principal',
          refaccionNombre: 'Filtro de aceite',
          totalUsada: 156.0,
          totalIngresos: 4680.00,
        ),
      ];
    }
  }

  Future<void> _cargarClientesFrecuentes() async {
    try {
      // En producción sería una query que calcule clientes con más citas y gastos
      _clientesFrecuentes = [
        ClienteFrecuente(
          clienteId: 'cliente-1',
          clienteNombre: 'María González Pérez',
          totalCitas: 12,
          totalGastado: 8450.00,
          ultimaVisita: DateTime.now().subtract(const Duration(days: 15)),
          telefono: '555-0101',
          correo: 'maria.gonzalez@email.com',
        ),
        ClienteFrecuente(
          clienteId: 'cliente-2',
          clienteNombre: 'Carlos Rodríguez López',
          totalCitas: 9,
          totalGastado: 6780.50,
          ultimaVisita: DateTime.now().subtract(const Duration(days: 8)),
          telefono: '555-0102',
          correo: 'carlos.rodriguez@email.com',
        ),
        ClienteFrecuente(
          clienteId: 'cliente-3',
          clienteNombre: 'Ana Martínez Silva',
          totalCitas: 8,
          totalGastado: 5420.75,
          ultimaVisita: DateTime.now().subtract(const Duration(days: 22)),
          telefono: '555-0103',
          correo: 'ana.martinez@email.com',
        ),
      ];
    } catch (e) {
      if (kDebugMode) print('Error _cargarClientesFrecuentes: $e');
    }
  }

  Future<void> _cargarTecnicosProductivos() async {
    try {
      // En producción sería una query que calcule productividad de técnicos
      _tecnicosProductivos = [
        const TecnicoProductivo(
          empleadoId: 'empleado-1',
          empleadoNombre: 'Juan Pérez Mendoza',
          ordenesAtendidas: 45,
          minutosTrabajados: 9600, // 160 horas
          ingresosGenerados: 22500.00,
          especialidad: 'Motor y Transmisión',
        ),
        const TecnicoProductivo(
          empleadoId: 'empleado-2',
          empleadoNombre: 'Roberto Silva García',
          ordenesAtendidas: 38,
          minutosTrabajados: 8220, // 137 horas
          ingresosGenerados: 19000.00,
          especialidad: 'Suspensión y Frenos',
        ),
        const TecnicoProductivo(
          empleadoId: 'empleado-3',
          empleadoNombre: 'Luis Hernández Torres',
          ordenesAtendidas: 32,
          minutosTrabajados: 7440, // 124 horas
          ingresosGenerados: 16800.00,
          especialidad: 'Eléctrico y Electrónico',
        ),
      ];
    } catch (e) {
      if (kDebugMode) print('Error _cargarTecnicosProductivos: $e');
    }
  }

  Future<void> _cargarAlertas() async {
    try {
      // En producción serían queries que detecten problemas operativos
      _alertas = [
        AlertaOperativa(
          tipo: 'inventario',
          titulo: 'Stock bajo en refacciones',
          descripcion: '5 refacciones están por debajo del mínimo requerido',
          severidad: 'alta',
          fecha: DateTime.now().subtract(const Duration(hours: 2)),
          metadata: {'refacciones_afectadas': 5},
        ),
        AlertaOperativa(
          tipo: 'citas',
          titulo: 'Citas no atendidas',
          descripcion: '3 citas programadas no fueron atendidas ayer',
          severidad: 'media',
          fecha: DateTime.now().subtract(const Duration(days: 1)),
          metadata: {'citas_perdidas': 3},
        ),
        AlertaOperativa(
          tipo: 'ordenes',
          titulo: 'Órdenes vencidas',
          descripcion: '2 órdenes exceden el tiempo estimado de entrega',
          severidad: 'media',
          fecha: DateTime.now().subtract(const Duration(hours: 8)),
          metadata: {'ordenes_vencidas': 2},
        ),
      ];
    } catch (e) {
      if (kDebugMode) print('Error _cargarAlertas: $e');
    }
  }

  // ============================================================================
  // CONSTRUCCIÓN DE ROWS PARA PLUTO GRID
  // ============================================================================

  void _buildRows() {
    _buildClientesFrecuentesRows();
    _buildTecnicosProductivosRows();
    _buildAlertasRows();
  }

  void _buildClientesFrecuentesRows() {
    clientesFrecuentesRows.clear();

    for (int i = 0; i < _clientesFrecuentes.length; i++) {
      final cliente = _clientesFrecuentes[i];
      clientesFrecuentesRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'nombre': PlutoCell(value: cliente.clienteNombre),
        'telefono': PlutoCell(value: cliente.telefono ?? ''),
        'correo': PlutoCell(value: cliente.correo ?? ''),
        'total_citas': PlutoCell(value: cliente.totalCitas),
        'total_gastado': PlutoCell(value: cliente.totalGastadoTexto),
        'promedio_gasto': PlutoCell(value: cliente.promedioGastoPorCita),
        'ultima_visita': PlutoCell(value: cliente.ultimaVisitaTexto),
        'acciones': PlutoCell(value: cliente.clienteId),
      }));
    }
  }

  void _buildTecnicosProductivosRows() {
    tecnicosProductivosRows.clear();

    for (int i = 0; i < _tecnicosProductivos.length; i++) {
      final tecnico = _tecnicosProductivos[i];
      tecnicosProductivosRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'nombre': PlutoCell(value: tecnico.empleadoNombre),
        'especialidad': PlutoCell(value: tecnico.especialidad ?? 'General'),
        'ordenes_atendidas': PlutoCell(value: tecnico.ordenesAtendidas),
        'horas_trabajadas': PlutoCell(value: tecnico.horasTrabajadasTexto),
        'ingresos_generados': PlutoCell(value: tecnico.ingresosGeneradosTexto),
        'promedio_ingreso': PlutoCell(value: tecnico.promedioIngresoPorOrden),
        'promedio_tiempo':
            PlutoCell(value: tecnico.promedioMinutosPorOrdenTexto),
        'acciones': PlutoCell(value: tecnico.empleadoId),
      }));
    }
  }

  void _buildAlertasRows() {
    alertasRows.clear();

    for (int i = 0; i < _alertas.length; i++) {
      final alerta = _alertas[i];
      alertasRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'tipo': PlutoCell(value: alerta.tipo),
        'titulo': PlutoCell(value: alerta.titulo),
        'descripcion': PlutoCell(value: alerta.descripcion),
        'severidad': PlutoCell(value: alerta.severidad),
        'fecha': PlutoCell(value: alerta.fechaTexto),
        'acciones': PlutoCell(value: '${alerta.tipo}-${i}'),
      }));
    }
  }

  // ============================================================================
  // DATOS PARA GRÁFICAS
  // ============================================================================

  List<DatoGrafica> get datosIngresosPorDia {
    return _ingresosSucursal
        .map((ingreso) => DatoGrafica(
              etiqueta: ingreso.fechaTexto,
              valor: ingreso.totalPagado,
              metadatos: {
                'fecha': ingreso.fecha,
                'pendiente': ingreso.totalPendiente,
                'fallido': ingreso.totalFallido,
              },
            ))
        .toList();
  }

  List<DatoGrafica> get datosServiciosTop {
    return _serviciosTop
        .take(5)
        .map((servicio) => DatoGrafica(
              etiqueta: servicio.servicioNombre,
              valor: servicio.vecesSolicitado.toDouble(),
              metadatos: {
                'ingresos': servicio.totalIngresos,
                'promedio': servicio.promedioIngresoPorServicio,
              },
            ))
        .toList();
  }

  List<DatoGrafica> get datosRefaccionesTop {
    return _refaccionesTop
        .take(5)
        .map((refaccion) => DatoGrafica(
              etiqueta: refaccion.refaccionNombre,
              valor: refaccion.totalUsada,
              metadatos: {
                'ingresos': refaccion.totalIngresos,
                'promedio': refaccion.promedioIngresoPorUnidad,
              },
            ))
        .toList();
  }

  List<DatoGrafica> get datosEstadosOrdenes {
    if (_kpis == null) return [];

    return [
      DatoGrafica(
        etiqueta: 'Abiertas',
        valor: _kpis!.ordenesAbiertas.toDouble(),
        color: '#FF9800',
      ),
      DatoGrafica(
        etiqueta: 'Cerradas',
        valor: _kpis!.ordenesCerradas.toDouble(),
        color: '#4CAF50',
      ),
    ];
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> refrescar() async {
    await cargarReportes();
  }

  void limpiar() {
    _kpis = null;
    _resumenSucursal.clear();
    _ingresosSucursal.clear();
    _serviciosTop.clear();
    _refaccionesTop.clear();
    _clientesFrecuentes.clear();
    _tecnicosProductivos.clear();
    _alertas.clear();
    clientesFrecuentesRows.clear();
    tecnicosProductivosRows.clear();
    alertasRows.clear();
    _error = null;
    _sucursalId = '';
    notifyListeners();
  }

  // ============================================================================
  // EXPORTACIÓN DE DATOS
  // ============================================================================

  Map<String, dynamic> exportarDatos() {
    return {
      'kpis': _kpis?.toJson(),
      'resumen_sucursal': _resumenSucursal.map((e) => e.toJson()).toList(),
      'ingresos_sucursal': _ingresosSucursal.map((e) => e.toJson()).toList(),
      'servicios_top': _serviciosTop.map((e) => e.toJson()).toList(),
      'refacciones_top': _refaccionesTop.map((e) => e.toJson()).toList(),
      'clientes_frecuentes':
          _clientesFrecuentes.map((e) => e.toJson()).toList(),
      'tecnicos_productivos':
          _tecnicosProductivos.map((e) => e.toJson()).toList(),
      'alertas': _alertas.map((e) => e.toJson()).toList(),
      'fecha_exportacion': DateTime.now().toIso8601String(),
    };
  }
}
