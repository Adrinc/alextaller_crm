import 'package:intl/intl.dart';

// Enums para estados
enum EstadoCita {
  pendiente,
  confirmada,
  enProgreso,
  completada,
  cancelada,
  noAsistio,
}

enum FuenteCita {
  web,
  app,
  recepcion,
  telefono,
}

enum EstadoOrdenServicio {
  creada,
  enProceso,
  pausada,
  porAprobar,
  esperandoPartes,
  lista,
  entregada,
  cerrada,
  cancelada,
}

// Extensiones para obtener texto legible
extension EstadoCitaExtension on EstadoCita {
  String get texto {
    switch (this) {
      case EstadoCita.pendiente:
        return 'Pendiente';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.enProgreso:
        return 'En Progreso';
      case EstadoCita.completada:
        return 'Completada';
      case EstadoCita.cancelada:
        return 'Cancelada';
      case EstadoCita.noAsistio:
        return 'No Asistió';
    }
  }
}

extension FuenteCitaExtension on FuenteCita {
  String get texto {
    switch (this) {
      case FuenteCita.web:
        return 'Web';
      case FuenteCita.app:
        return 'App';
      case FuenteCita.recepcion:
        return 'Recepción';
      case FuenteCita.telefono:
        return 'Teléfono';
    }
  }
}

extension EstadoOrdenServicioExtension on EstadoOrdenServicio {
  String get texto {
    switch (this) {
      case EstadoOrdenServicio.creada:
        return 'Creada';
      case EstadoOrdenServicio.enProceso:
        return 'En Proceso';
      case EstadoOrdenServicio.pausada:
        return 'Pausada';
      case EstadoOrdenServicio.porAprobar:
        return 'Por Aprobar';
      case EstadoOrdenServicio.esperandoPartes:
        return 'Esperando Partes';
      case EstadoOrdenServicio.lista:
        return 'Lista';
      case EstadoOrdenServicio.entregada:
        return 'Entregada';
      case EstadoOrdenServicio.cerrada:
        return 'Cerrada';
      case EstadoOrdenServicio.cancelada:
        return 'Cancelada';
    }
  }
}

// Modelo para vw_citas_activas_sucursal
class CitaActiva {
  final String citaId;
  final String sucursalId;
  final String sucursalNombre;
  final DateTime inicio;
  final DateTime fin;
  final EstadoCita estado;
  final FuenteCita fuente;
  final String clienteId;
  final String clienteNombre;
  final String vehiculoId;
  final String placa;
  final String marca;
  final String modelo;
  final int anio;
  final List<String> servicios;
  final String? bahiaId;

  CitaActiva({
    required this.citaId,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.inicio,
    required this.fin,
    required this.estado,
    required this.fuente,
    required this.clienteId,
    required this.clienteNombre,
    required this.vehiculoId,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.servicios,
    this.bahiaId,
  });

  factory CitaActiva.fromJson(Map<String, dynamic> json) {
    return CitaActiva(
      citaId: json['cita_id'] as String,
      sucursalId: json['sucursal_id'] as String,
      sucursalNombre: json['sucursal_nombre'] as String,
      inicio: DateTime.parse(json['inicio'] as String),
      fin: DateTime.parse(json['fin'] as String),
      estado: _estadoCitaFromString(json['estado'] as String),
      fuente: _fuenteCitaFromString(json['fuente'] as String),
      clienteId: json['cliente_id'] as String,
      clienteNombre: json['cliente_nombre'] as String,
      vehiculoId: json['vehiculo_id'] as String,
      placa: json['placa'] as String,
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      anio: json['anio'] as int,
      servicios: (json['servicios'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bahiaId: json['bahia_id'] as String?,
    );
  }

  // Getters de conveniencia
  String get vehiculoTexto => '$marca $modelo ($anio)';

  String get fechaHoraTexto => DateFormat('dd/MM/yyyy HH:mm').format(inicio);

  String get duracionTexto {
    final duracion = fin.difference(inicio);
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes % 60;
    if (horas > 0) {
      return '${horas}h ${minutos}m';
    }
    return '${minutos}m';
  }

  String get serviciosTexto => servicios.join(', ');

  bool get tieneBahia => bahiaId != null;

  // Calcular retraso si la cita ya debería haber empezado
  Duration? get retraso {
    if (estado == EstadoCita.pendiente || estado == EstadoCita.confirmada) {
      final ahora = DateTime.now();
      if (ahora.isAfter(inicio)) {
        return ahora.difference(inicio);
      }
    }
    return null;
  }

  String get retrasoTexto {
    final r = retraso;
    if (r == null) return '';
    final minutos = r.inMinutes;
    if (minutos < 60) {
      return '${minutos}m retraso';
    }
    final horas = r.inHours;
    final mins = r.inMinutes % 60;
    return '${horas}h ${mins}m retraso';
  }
}

// Modelo para vw_ordenes_sucursal
class OrdenSucursal {
  final String ordenId;
  final String numero;
  final String sucursalId;
  final String sucursalNombre;
  final EstadoOrdenServicio estado;
  final DateTime fechaInicio;
  final DateTime? fechaFinEstimada;
  final DateTime? fechaFinReal;
  final String clienteId;
  final String clienteNombre;
  final String vehiculoId;
  final String placa;
  final String marca;
  final String modelo;
  final int anio;
  final double totalServicios;
  final double totalRefacciones;
  final double totalGeneral;
  final double pagos;
  final double saldo;

  OrdenSucursal({
    required this.ordenId,
    required this.numero,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.estado,
    required this.fechaInicio,
    this.fechaFinEstimada,
    this.fechaFinReal,
    required this.clienteId,
    required this.clienteNombre,
    required this.vehiculoId,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.totalServicios,
    required this.totalRefacciones,
    required this.totalGeneral,
    required this.pagos,
    required this.saldo,
  });

  factory OrdenSucursal.fromJson(Map<String, dynamic> json) {
    return OrdenSucursal(
      ordenId: json['orden_id'] as String,
      numero: json['numero'] as String,
      sucursalId: json['sucursal_id'] as String,
      sucursalNombre: json['sucursal_nombre'] as String,
      estado: _estadoOrdenFromString(json['estado'] as String),
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFinEstimada: json['fecha_fin_estimada'] != null
          ? DateTime.parse(json['fecha_fin_estimada'] as String)
          : null,
      fechaFinReal: json['fecha_fin_real'] != null
          ? DateTime.parse(json['fecha_fin_real'] as String)
          : null,
      clienteId: json['cliente_id'] as String,
      clienteNombre: json['cliente_nombre'] as String,
      vehiculoId: json['vehiculo_id'] as String,
      placa: json['placa'] as String,
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      anio: json['anio'] as int,
      totalServicios: (json['total_servicios'] as num?)?.toDouble() ?? 0.0,
      totalRefacciones: (json['total_refacciones'] as num?)?.toDouble() ?? 0.0,
      totalGeneral: (json['total_general'] as num?)?.toDouble() ?? 0.0,
      pagos: (json['pagos'] as num?)?.toDouble() ?? 0.0,
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Getters de conveniencia
  String get vehiculoTexto => '$marca $modelo ($anio)';

  String get fechaInicioTexto =>
      DateFormat('dd/MM/yyyy HH:mm').format(fechaInicio);

  String get fechaFinEstimadaTexto => fechaFinEstimada != null
      ? DateFormat('dd/MM/yyyy HH:mm').format(fechaFinEstimada!)
      : 'No definida';

  String get totalGeneralTexto => '\$${totalGeneral.toStringAsFixed(2)}';

  String get pagosTexto => '\$${pagos.toStringAsFixed(2)}';

  String get saldoTexto => '\$${saldo.toStringAsFixed(2)}';

  bool get estaPagada => saldo <= 0;

  bool get tieneSaldo => saldo > 0;

  // Calcular progreso de tiempo si hay fecha estimada
  double? get progresoTiempo {
    if (fechaFinEstimada == null) return null;

    final ahora = DateTime.now();
    final duracionTotal = fechaFinEstimada!.difference(fechaInicio);
    final duracionTranscurrida = ahora.difference(fechaInicio);

    if (duracionTotal.inMinutes <= 0) return 1.0;

    final progreso = duracionTranscurrida.inMinutes / duracionTotal.inMinutes;
    return progreso.clamp(0.0, 1.0);
  }
}

// Modelo para vw_backlog_aprobaciones
class AprobacionPendiente {
  final String ordenId;
  final String numero;
  final String sucursalId;
  final String clienteNombre;
  final String placa;
  final String ordenItemId;
  final String descripcion;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  final bool requiereAprobacion;
  final bool aprobado;
  final String? aprobadoPor;
  final DateTime? aprobadoEn;

  AprobacionPendiente({
    required this.ordenId,
    required this.numero,
    required this.sucursalId,
    required this.clienteNombre,
    required this.placa,
    required this.ordenItemId,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.requiereAprobacion,
    required this.aprobado,
    this.aprobadoPor,
    this.aprobadoEn,
  });

  factory AprobacionPendiente.fromJson(Map<String, dynamic> json) {
    return AprobacionPendiente(
      ordenId: json['orden_id'] as String,
      numero: json['numero'] as String,
      sucursalId: json['sucursal_id'] as String,
      clienteNombre: json['cliente_nombre'] as String,
      placa: json['placa'] as String,
      ordenItemId: json['orden_item_id'] as String,
      descripcion: json['descripcion'] as String,
      cantidad: (json['cantidad'] as num).toDouble(),
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      requiereAprobacion: json['requiere_aprobacion'] as bool,
      aprobado: json['aprobado'] as bool,
      aprobadoPor: json['aprobado_por'] as String?,
      aprobadoEn: json['aprobado_en'] != null
          ? DateTime.parse(json['aprobado_en'] as String)
          : null,
    );
  }

  // Getters de conveniencia
  String get subtotalTexto => '\$${subtotal.toStringAsFixed(2)}';

  String get precioUnitarioTexto => '\$${precioUnitario.toStringAsFixed(2)}';

  bool get estaPendiente => requiereAprobacion && !aprobado;
}

// Modelo para KPIs del encabezado
class KPIsCitasOrdenes {
  final int citasPendientes;
  final int citasConfirmadas;
  final int citasNoAsistio;
  final int citasCompletadas;

  final int ordenesEnProceso;
  final int ordenesPorAprobar;
  final int ordenesEsperandoPartes;
  final int ordenesListas;
  final int ordenesEntregadas;
  final int ordenesCerradas;

  final int bahiasOcupadas;
  final int bahiasTotales;

  final double ingresosPeriodo;
  final int aprobacionesPendientes;

  KPIsCitasOrdenes({
    required this.citasPendientes,
    required this.citasConfirmadas,
    required this.citasNoAsistio,
    required this.citasCompletadas,
    required this.ordenesEnProceso,
    required this.ordenesPorAprobar,
    required this.ordenesEsperandoPartes,
    required this.ordenesListas,
    required this.ordenesEntregadas,
    required this.ordenesCerradas,
    required this.bahiasOcupadas,
    required this.bahiasTotales,
    required this.ingresosPeriodo,
    required this.aprobacionesPendientes,
  });

  // Getters de conveniencia
  int get totalCitas =>
      citasPendientes + citasConfirmadas + citasNoAsistio + citasCompletadas;

  int get totalOrdenes =>
      ordenesEnProceso +
      ordenesPorAprobar +
      ordenesEsperandoPartes +
      ordenesListas +
      ordenesEntregadas +
      ordenesCerradas;

  double get porcentajeBahiasOcupadas =>
      bahiasTotales > 0 ? (bahiasOcupadas / bahiasTotales) * 100 : 0;

  String get ingresosPeriodoTexto => '\$${ingresosPeriodo.toStringAsFixed(2)}';
}

// Helper functions para mapear estados desde la base de datos
EstadoCita _estadoCitaFromString(String estado) {
  switch (estado.toLowerCase()) {
    case 'pendiente':
      return EstadoCita.pendiente;
    case 'confirmada':
      return EstadoCita.confirmada;
    case 'en_progreso':
      return EstadoCita.enProgreso;
    case 'completada':
      return EstadoCita.completada;
    case 'cancelada':
      return EstadoCita.cancelada;
    case 'no_asistio':
      return EstadoCita.noAsistio;
    default:
      return EstadoCita.pendiente;
  }
}

FuenteCita _fuenteCitaFromString(String fuente) {
  switch (fuente.toLowerCase()) {
    case 'web':
      return FuenteCita.web;
    case 'app':
      return FuenteCita.app;
    case 'recepcion':
      return FuenteCita.recepcion;
    case 'telefono':
      return FuenteCita.telefono;
    default:
      return FuenteCita.recepcion;
  }
}

EstadoOrdenServicio _estadoOrdenFromString(String estado) {
  switch (estado.toLowerCase()) {
    case 'creada':
      return EstadoOrdenServicio.creada;
    case 'en_proceso':
      return EstadoOrdenServicio.enProceso;
    case 'pausada':
      return EstadoOrdenServicio.pausada;
    case 'por_aprobar':
      return EstadoOrdenServicio.porAprobar;
    case 'esperando_partes':
      return EstadoOrdenServicio.esperandoPartes;
    case 'lista':
      return EstadoOrdenServicio.lista;
    case 'entregada':
      return EstadoOrdenServicio.entregada;
    case 'cerrada':
      return EstadoOrdenServicio.cerrada;
    case 'cancelada':
      return EstadoOrdenServicio.cancelada;
    default:
      return EstadoOrdenServicio.creada;
  }
}
