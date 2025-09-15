import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

/// Modelo principal para representar un cliente en la vista global
/// Basado en vw_clientes_sucursal
class ClienteGlobalGrid {
  final String clienteId;
  final String clienteNombre;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final String? rfc;
  final String? notas;
  final int totalVehiculos;
  final int citasProximas;
  final DateTime? ultimaVisita;
  final double totalGastado;
  final String sucursalId;
  final String sucursalNombre;
  final String? imagenId;
  final String? imagenPath;

  ClienteGlobalGrid({
    required this.clienteId,
    required this.clienteNombre,
    this.correo,
    this.telefono,
    this.direccion,
    this.rfc,
    this.notas,
    required this.totalVehiculos,
    required this.citasProximas,
    this.ultimaVisita,
    required this.totalGastado,
    required this.sucursalId,
    required this.sucursalNombre,
    this.imagenId,
    this.imagenPath,
  });

  /// Factory constructor desde Map (respuesta de Supabase)
  factory ClienteGlobalGrid.fromMap(Map<String, dynamic> map) {
    return ClienteGlobalGrid(
      clienteId: map['cliente_id'] ?? '',
      clienteNombre: map['cliente_nombre'] ?? 'Cliente sin nombre',
      correo: map['correo'],
      telefono: map['telefono'],
      direccion: map['direccion'],
      rfc: map['rfc'],
      notas: map['notas'],
      totalVehiculos: map['total_vehiculos'] ?? 0,
      citasProximas: map['citas_proximas'] ?? 0,
      ultimaVisita: map['ultima_visita'] != null
          ? DateTime.parse(map['ultima_visita'])
          : null,
      totalGastado: (map['total_gastado'] ?? 0).toDouble(),
      sucursalId: map['sucursal_id'] ?? '',
      sucursalNombre: map['sucursal_nombre'] ?? 'Sin sucursal',
      imagenId: map['imagen_id'],
      imagenPath: map['imagen_path'],
    );
  }

  /// Getter para fecha formateada de última visita
  String get ultimaVisitaTexto {
    if (ultimaVisita == null) return 'Nunca';

    final now = DateTime.now();
    final difference = now.difference(ultimaVisita!).inDays;

    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Ayer';
    if (difference < 7) return 'Hace $difference días';
    if (difference < 30) return 'Hace ${(difference / 7).floor()} semanas';
    if (difference < 365) return 'Hace ${(difference / 30).floor()} meses';

    return DateFormat('dd/MM/yyyy').format(ultimaVisita!);
  }

  /// Getter para total gastado formateado
  String get totalGastadoTexto {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return formatter.format(totalGastado);
  }

  /// Getter para sucursal principal (alias de sucursalNombre)
  String get sucursalPrincipal => sucursalNombre;

  /// Getter para clasificación automática del cliente
  String get clasificacionCliente {
    if (totalGastado >= 50000) return 'VIP';
    if (totalGastado >= 20000) return 'Premium';
    if (totalGastado >= 5000) return 'Frecuente';
    if (totalGastado > 0) return 'Ocasional';
    return 'Nuevo';
  }

  /// Getter para color de la clasificación
  String get colorClasificacion {
    switch (clasificacionCliente) {
      case 'VIP':
        return 'oro';
      case 'Premium':
        return 'violeta';
      case 'Frecuente':
        return 'verde';
      case 'Ocasional':
        return 'azul';
      case 'Nuevo':
        return 'gris';
      default:
        return 'gris';
    }
  }

  /// Getter para estado del cliente basado en última visita
  String get estadoCliente {
    if (ultimaVisita == null) return 'Nuevo';

    final diasInactivo = DateTime.now().difference(ultimaVisita!).inDays;
    if (diasInactivo <= 30) return 'Activo';
    if (diasInactivo <= 90) return 'Regular';
    if (diasInactivo <= 180) return 'En riesgo';
    return 'Inactivo';
  }

  /// Getter para color del estado
  String get colorEstado {
    switch (estadoCliente) {
      case 'Activo':
        return 'verde';
      case 'Regular':
        return 'azul';
      case 'En riesgo':
        return 'naranja';
      case 'Inactivo':
        return 'rojo';
      case 'Nuevo':
        return 'violeta';
      default:
        return 'gris';
    }
  }

  /// Método para convertir a PlutoRow
  PlutoRow toPlutoRow(int index) {
    return PlutoRow(cells: {
      'numero': PlutoCell(value: (index + 1).toString()),
      'nombre': PlutoCell(value: clienteNombre),
      'telefono': PlutoCell(value: telefono ?? ''),
      'correo': PlutoCell(value: correo ?? ''),
      'rfc': PlutoCell(value: rfc ?? ''),
      'total_gastado': PlutoCell(value: totalGastadoTexto),
      'total_visitas': PlutoCell(value: totalVehiculos.toString()),
      'ultima_visita': PlutoCell(value: ultimaVisitaTexto),
      'sucursal': PlutoCell(value: sucursalNombre),
      'clasificacion': PlutoCell(value: clasificacionCliente),
      'acciones': PlutoCell(value: clienteId),
    });
  }

  @override
  String toString() {
    return 'ClienteGlobalGrid(id: $clienteId, nombre: $clienteNombre, sucursal: $sucursalNombre, gastado: $totalGastadoTexto)';
  }
}

/// Modelo para historial técnico de servicios
/// Basado en vw_historial_cliente
class HistorialClienteTecnico {
  final String clienteId;
  final String clienteNombre;
  final String vehiculoId;
  final String placa;
  final String marca;
  final String modelo;
  final int anio;
  final String ordenId;
  final String numeroOrden;
  final String estado;
  final DateTime fechaInicio;
  final DateTime? fechaFinReal;
  final double totalServicios;
  final double totalRefacciones;
  final double totalGeneral;
  final String? serviciosIncluidos;
  final String? imagenId;
  final String? imagenPath;
  final bool activo;

  HistorialClienteTecnico({
    required this.clienteId,
    required this.clienteNombre,
    required this.vehiculoId,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.ordenId,
    required this.numeroOrden,
    required this.estado,
    required this.fechaInicio,
    this.fechaFinReal,
    required this.totalServicios,
    required this.totalRefacciones,
    required this.totalGeneral,
    this.serviciosIncluidos,
    this.imagenId,
    this.imagenPath,
    required this.activo,
  });

  factory HistorialClienteTecnico.fromMap(Map<String, dynamic> map) {
    return HistorialClienteTecnico(
      clienteId: map['cliente_id'] ?? '',
      clienteNombre: map['cliente_nombre'] ?? '',
      vehiculoId: map['vehiculo_id'] ?? '',
      placa: map['placa'] ?? '',
      marca: map['marca'] ?? '',
      modelo: map['modelo'] ?? '',
      anio: map['anio'] ?? 0,
      ordenId: map['orden_id'] ?? '',
      numeroOrden: map['numero_orden'] ?? '',
      estado: map['estado'] ?? '',
      fechaInicio: DateTime.parse(map['fecha_inicio']),
      fechaFinReal: map['fecha_fin_real'] != null
          ? DateTime.parse(map['fecha_fin_real'])
          : null,
      totalServicios: (map['total_servicios'] ?? 0).toDouble(),
      totalRefacciones: (map['total_refacciones'] ?? 0).toDouble(),
      totalGeneral: (map['total_general'] ?? 0).toDouble(),
      serviciosIncluidos: map['servicios_incluidos'],
      imagenId: map['imagen_id'],
      imagenPath: map['imagen_path'],
      activo: map['activo'] ?? true,
    );
  }

  String get vehiculoTexto => '$marca $modelo $anio';
  String get fechaInicioTexto =>
      DateFormat('dd/MM/yyyy HH:mm').format(fechaInicio);
  String get fechaFinTexto => fechaFinReal != null
      ? DateFormat('dd/MM/yyyy HH:mm').format(fechaFinReal!)
      : 'En proceso';

  String get totalGeneralTexto {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return formatter.format(totalGeneral);
  }
}

/// Modelo para historial financiero de pagos
/// Basado en vw_historial_cliente_financiero
class HistorialClienteFinanciero {
  final String clienteId;
  final String clienteNombre;
  final String citaId;
  final DateTime citaInicio;
  final String ordenId;
  final String? numeroOrden;
  final String ordenEstado;
  final DateTime fechaInicio;
  final DateTime? fechaFinReal;
  final String sucursalId;
  final String sucursalNombre;
  final double totalPagado;

  HistorialClienteFinanciero({
    required this.clienteId,
    required this.clienteNombre,
    required this.citaId,
    required this.citaInicio,
    required this.ordenId,
    this.numeroOrden,
    required this.ordenEstado,
    required this.fechaInicio,
    this.fechaFinReal,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.totalPagado,
  });

  factory HistorialClienteFinanciero.fromMap(Map<String, dynamic> map) {
    return HistorialClienteFinanciero(
      clienteId: map['cliente_id'] ?? '',
      clienteNombre: map['cliente_nombre'] ?? '',
      citaId: map['cita_id'] ?? '',
      citaInicio: DateTime.parse(map['cita_inicio']),
      ordenId: map['orden_id'] ?? '',
      numeroOrden: map['numero_orden'] ?? '',
      ordenEstado: map['orden_estado'] ?? '',
      fechaInicio: DateTime.parse(map['fecha_inicio']),
      fechaFinReal: map['fecha_fin_real'] != null
          ? DateTime.parse(map['fecha_fin_real'])
          : null,
      sucursalId: map['sucursal_id'] ?? '',
      sucursalNombre: map['sucursal_nombre'] ?? '',
      totalPagado: (map['total_pagado'] ?? 0).toDouble(),
    );
  }

  String get fechaInicioTexto => DateFormat('dd/MM/yyyy').format(fechaInicio);
  String get totalPagadoTexto {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return formatter.format(totalPagado);
  }
}

/// Modelo para sucursales frecuentes del cliente
/// Basado en vw_clientes_sucursales_frecuentes
class SucursalFrecuente {
  final String clienteId;
  final String sucursalId;
  final String sucursalNombre;
  final int totalVisitas;

  SucursalFrecuente({
    required this.clienteId,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.totalVisitas,
  });

  factory SucursalFrecuente.fromMap(Map<String, dynamic> map) {
    return SucursalFrecuente(
      clienteId: map['cliente_id'] ?? '',
      sucursalId: map['sucursal_id'] ?? '',
      sucursalNombre: map['sucursal_nombre'] ?? '',
      totalVisitas: map['total_visitas'] ?? 0,
    );
  }

  /// Getter para porcentaje relativo (calculado en el provider)
  double porcentajeVisitas = 0.0;
}

/// Modelo para clientes inactivos
/// Basado en vw_clientes_inactivos
class ClienteInactivo {
  final String clienteId;
  final String clienteNombre;
  final DateTime ultimaVisita;
  final int diasInactivo;

  ClienteInactivo({
    required this.clienteId,
    required this.clienteNombre,
    required this.ultimaVisita,
    required this.diasInactivo,
  });

  factory ClienteInactivo.fromMap(Map<String, dynamic> map) {
    return ClienteInactivo(
      clienteId: map['cliente_id'] ?? '',
      clienteNombre: map['cliente_nombre'] ?? '',
      ultimaVisita: DateTime.parse(map['ultima_visita']),
      diasInactivo: map['dias_inactivo'] ?? 0,
    );
  }

  String get ultimaVisitaTexto => DateFormat('dd/MM/yyyy').format(ultimaVisita);

  String get nivelRiesgo {
    if (diasInactivo >= 180) return 'Alto riesgo';
    if (diasInactivo >= 90) return 'Riesgo medio';
    if (diasInactivo >= 30) return 'Riesgo bajo';
    return 'Activo';
  }

  String get colorRiesgo {
    switch (nivelRiesgo) {
      case 'Alto riesgo':
        return 'rojo';
      case 'Riesgo medio':
        return 'naranja';
      case 'Riesgo bajo':
        return 'amarillo';
      case 'Activo':
        return 'verde';
      default:
        return 'gris';
    }
  }
}

/// Modelo para métricas globales
/// Basado en vw_metricas_globales
class MetricasGlobales {
  final int totalClientes;
  final int ordenesAbiertas;
  final int ordenesCerradas;
  final double ingresosTotales;

  MetricasGlobales({
    required this.totalClientes,
    required this.ordenesAbiertas,
    required this.ordenesCerradas,
    required this.ingresosTotales,
  });

  factory MetricasGlobales.fromMap(Map<String, dynamic> map) {
    return MetricasGlobales(
      totalClientes: map['total_clientes'] ?? 0,
      ordenesAbiertas: map['ordenes_abiertas'] ?? 0,
      ordenesCerradas: map['ordenes_cerradas'] ?? 0,
      ingresosTotales: (map['ingresos_totales'] ?? 0).toDouble(),
    );
  }

  String get ingresosTotalesTexto {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return formatter.format(ingresosTotales);
  }

  int get totalOrdenes => ordenesAbiertas + ordenesCerradas;

  double get porcentajeExito =>
      totalOrdenes > 0 ? (ordenesCerradas / totalOrdenes) * 100 : 0.0;
}

/// Modelo para métricas por sucursal
/// Basado en vw_metricas_sucursal
class MetricaSucursal {
  final String sucursalId;
  final String sucursalNombre;
  final double ingresosTotales;

  MetricaSucursal({
    required this.sucursalId,
    required this.sucursalNombre,
    required this.ingresosTotales,
  });

  factory MetricaSucursal.fromMap(Map<String, dynamic> map) {
    return MetricaSucursal(
      sucursalId: map['sucursal_id'] ?? '',
      sucursalNombre: map['sucursal_nombre'] ?? '',
      ingresosTotales: (map['ingresos_totales'] ?? 0).toDouble(),
    );
  }

  String get ingresosTotalesTexto {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return formatter.format(ingresosTotales);
  }

  /// Getter para porcentaje relativo (calculado en el provider)
  double porcentajeIngresos = 0.0;
}

/// Modelo para filtros de clientes globales
class FiltrosClientesGlobales {
  String? sucursalId;
  String? clasificacion;
  String? estado;
  double? gastoMinimo;
  double? gastoMaximo;
  DateTime? ultimaVisitaDesde;
  DateTime? ultimaVisitaHasta;
  String searchTerm;

  FiltrosClientesGlobales({
    this.sucursalId,
    this.clasificacion,
    this.estado,
    this.gastoMinimo,
    this.gastoMaximo,
    this.ultimaVisitaDesde,
    this.ultimaVisitaHasta,
    this.searchTerm = '',
  });

  // Alias para compatibilidad con la página
  String? get clasificacionSeleccionada => clasificacion;
  set clasificacionSeleccionada(String? value) => clasificacion = value;

  String? get estadoSeleccionado => estado;
  set estadoSeleccionado(String? value) => estado = value;

  String? get sucursalSeleccionada => sucursalId;
  set sucursalSeleccionada(String? value) => sucursalId = value;

  String get terminoBusqueda => searchTerm;
  set terminoBusqueda(String value) => searchTerm = value;

  DateTime? get fechaInicioFiltro => ultimaVisitaDesde;
  set fechaInicioFiltro(DateTime? value) => ultimaVisitaDesde = value;

  DateTime? get fechaFinFiltro => ultimaVisitaHasta;
  set fechaFinFiltro(DateTime? value) => ultimaVisitaHasta = value;

  /// Verificar si un cliente pasa todos los filtros
  bool cumpleFiltros(ClienteGlobalGrid cliente) {
    // Filtro por sucursal
    if (sucursalId != null && cliente.sucursalId != sucursalId) {
      return false;
    }

    // Filtro por clasificación
    if (clasificacion != null &&
        cliente.clasificacionCliente != clasificacion) {
      return false;
    }

    // Filtro por estado
    if (estado != null && cliente.estadoCliente != estado) {
      return false;
    }

    // Filtro por gasto mínimo
    if (gastoMinimo != null && cliente.totalGastado < gastoMinimo!) {
      return false;
    }

    // Filtro por gasto máximo
    if (gastoMaximo != null && cliente.totalGastado > gastoMaximo!) {
      return false;
    }

    // Filtro por fecha de última visita desde
    if (ultimaVisitaDesde != null &&
        (cliente.ultimaVisita == null ||
            cliente.ultimaVisita!.isBefore(ultimaVisitaDesde!))) {
      return false;
    }

    // Filtro por fecha de última visita hasta
    if (ultimaVisitaHasta != null &&
        (cliente.ultimaVisita == null ||
            cliente.ultimaVisita!.isAfter(ultimaVisitaHasta!))) {
      return false;
    }

    // Filtro por término de búsqueda
    if (searchTerm.isNotEmpty) {
      final searchLower = searchTerm.toLowerCase();
      final nombreMatch =
          cliente.clienteNombre.toLowerCase().contains(searchLower);
      final telefonoMatch =
          cliente.telefono?.toLowerCase().contains(searchLower) ?? false;
      final correoMatch =
          cliente.correo?.toLowerCase().contains(searchLower) ?? false;
      final rfcMatch =
          cliente.rfc?.toLowerCase().contains(searchLower) ?? false;

      if (!nombreMatch && !telefonoMatch && !correoMatch && !rfcMatch) {
        return false;
      }
    }

    return true;
  }

  /// Limpiar todos los filtros
  void limpiar() {
    sucursalId = null;
    clasificacion = null;
    estado = null;
    gastoMinimo = null;
    gastoMaximo = null;
    ultimaVisitaDesde = null;
    ultimaVisitaHasta = null;
    searchTerm = '';
  }

  /// Verificar si hay filtros activos
  bool get tieneFiltrosActivos {
    return sucursalId != null ||
        clasificacion != null ||
        estado != null ||
        gastoMinimo != null ||
        gastoMaximo != null ||
        ultimaVisitaDesde != null ||
        ultimaVisitaHasta != null ||
        searchTerm.isNotEmpty;
  }

  @override
  String toString() {
    return 'FiltrosClientesGlobales(sucursal: $sucursalId, clasificacion: $clasificacion, estado: $estado, search: "$searchTerm")';
  }
}

/// Enums para valores predefinidos
enum ClasificacionCliente {
  vip('VIP'),
  premium('Premium'),
  frecuente('Frecuente'),
  ocasional('Ocasional'),
  nuevo('Nuevo');

  const ClasificacionCliente(this.nombre);
  final String nombre;

  static List<ClasificacionCliente> get todas => ClasificacionCliente.values;
}

enum EstadoCliente {
  activo('Activo'),
  regular('Regular'),
  enRiesgo('En riesgo'),
  inactivo('Inactivo'),
  nuevo('Nuevo');

  const EstadoCliente(this.nombre);
  final String nombre;

  static List<EstadoCliente> get todos => EstadoCliente.values;
}

/// Modelo para representar un vehículo del cliente
/// Basado en tabla vehiculos + fotos_vehiculo
class VehiculoCliente {
  final String vehiculoId;
  final String clienteId;
  final String marca;
  final String modelo;
  final int anio;
  final String placa;
  final String? color;
  final String? vin;
  final String? combustible;
  final bool activo;
  final String? fotoId;
  final String? fotoPath;
  final String? fotoTipo;

  VehiculoCliente({
    required this.vehiculoId,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
    this.color,
    this.vin,
    this.combustible,
    required this.activo,
    this.fotoId,
    this.fotoPath,
    this.fotoTipo,
  });

  /// Factory constructor desde Map (respuesta de Supabase)
  factory VehiculoCliente.fromMap(Map<String, dynamic> map) {
    return VehiculoCliente(
      vehiculoId: map['id'] ?? map['vehiculo_id'] ?? '',
      clienteId: map['cliente_id'] ?? '',
      marca: map['marca'] ?? 'Sin marca',
      modelo: map['modelo'] ?? 'Sin modelo',
      anio: map['anio'] ?? DateTime.now().year,
      placa: map['placa'] ?? 'Sin placa',
      color: map['color'],
      vin: map['vin'],
      combustible: map['combustible'],
      activo: map['activo'] ?? true,
      fotoId: map['foto_id'] ?? map['archivo_id'],
      fotoPath: map['foto_path'] ?? map['archivo_path'],
      fotoTipo: map['foto_tipo'] ?? map['tipo'],
    );
  }

  /// Getter para nombre completo del vehículo
  String get nombreCompleto => '$marca $modelo $anio';

  /// Getter para descripción breve
  String get descripcionBreve => '$marca $modelo ($placa)';

  /// Getter para estado formateado
  String get estadoTexto => activo ? 'Activo' : 'Inactivo';

  /// Getter para año como texto
  String get anioTexto => anio.toString();

  /// Map para enviar a Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': vehiculoId,
      'cliente_id': clienteId,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'placa': placa,
      'color': color,
      'vin': vin,
      'combustible': combustible,
      'activo': activo,
    };
  }
}

/// Modelo para el historial de órdenes de un vehículo específico
/// Basado en vista vw_historial_vehiculo
class HistorialVehiculo {
  final String vehiculoId;
  final String placa;
  final String marca;
  final String modelo;
  final int anio;
  final String ordenId;
  final String numeroOrden;
  final DateTime fechaInicio;
  final DateTime? fechaFinReal;
  final String estado;
  final double totalServicios;
  final double totalRefacciones;
  final double totalGeneral;
  final String? tecnicoAsignado;
  final String? observaciones;

  HistorialVehiculo({
    required this.vehiculoId,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.ordenId,
    required this.numeroOrden,
    required this.fechaInicio,
    this.fechaFinReal,
    required this.estado,
    required this.totalServicios,
    required this.totalRefacciones,
    required this.totalGeneral,
    this.tecnicoAsignado,
    this.observaciones,
  });

  /// Factory constructor desde Map (respuesta de Supabase)
  factory HistorialVehiculo.fromMap(Map<String, dynamic> map) {
    return HistorialVehiculo(
      vehiculoId: map['vehiculo_id'] ?? '',
      placa: map['placa'] ?? 'Sin placa',
      marca: map['marca'] ?? 'Sin marca',
      modelo: map['modelo'] ?? 'Sin modelo',
      anio: map['anio'] ?? DateTime.now().year,
      ordenId: map['orden_id'] ?? '',
      numeroOrden: map['numero_orden'] ?? 'Sin número',
      fechaInicio: DateTime.parse(map['fecha_inicio']),
      fechaFinReal: map['fecha_fin_real'] != null
          ? DateTime.parse(map['fecha_fin_real'])
          : null,
      estado: map['estado'] ?? 'Pendiente',
      totalServicios: (map['total_servicios'] ?? 0).toDouble(),
      totalRefacciones: (map['total_refacciones'] ?? 0).toDouble(),
      totalGeneral: (map['total_general'] ?? 0).toDouble(),
      tecnicoAsignado: map['tecnico_asignado'],
      observaciones: map['observaciones'],
    );
  }

  /// Getter para fecha de inicio formateada
  String get fechaInicioTexto {
    return DateFormat('dd/MM/yyyy').format(fechaInicio);
  }

  /// Getter para fecha de fin formateada
  String get fechaFinTexto {
    if (fechaFinReal == null) return 'En proceso';
    return DateFormat('dd/MM/yyyy').format(fechaFinReal!);
  }

  /// Getter para duración del servicio
  String get duracionTexto {
    if (fechaFinReal == null) {
      final diasTranscurridos = DateTime.now().difference(fechaInicio).inDays;
      return '$diasTranscurridos días (en proceso)';
    }

    final duracion = fechaFinReal!.difference(fechaInicio).inDays;
    return duracion == 0 ? 'Mismo día' : '$duracion días';
  }

  /// Getter para total formateado
  String get totalTexto {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return formatter.format(totalGeneral);
  }

  /// Getter para total servicios formateado
  String get totalServiciosTexto {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return formatter.format(totalServicios);
  }

  /// Getter para total refacciones formateado
  String get totalRefaccionesTexto {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return formatter.format(totalRefacciones);
  }

  /// Getter para vehículo completo
  String get vehiculoCompleto => '$marca $modelo $anio ($placa)';
}
