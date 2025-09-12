// ============================================================================
// RESUMEN GENERAL DE SUCURSAL
// ============================================================================

class ResumenSucursal {
  final String sucursalId;
  final String sucursalNombre;
  final DateTime periodo;
  final int totalCitas;
  final int citasCompletadas;
  final int citasCanceladas;
  final int totalOrdenes;
  final int ordenesAbiertas;
  final int ordenesCerradas;

  const ResumenSucursal({
    required this.sucursalId,
    required this.sucursalNombre,
    required this.periodo,
    required this.totalCitas,
    required this.citasCompletadas,
    required this.citasCanceladas,
    required this.totalOrdenes,
    required this.ordenesAbiertas,
    required this.ordenesCerradas,
  });

  factory ResumenSucursal.fromJson(Map<String, dynamic> json) {
    return ResumenSucursal(
      sucursalId: json['sucursal_id'] ?? '',
      sucursalNombre: json['sucursal_nombre'] ?? '',
      periodo:
          DateTime.parse(json['periodo'] ?? DateTime.now().toIso8601String()),
      totalCitas: json['total_citas'] ?? 0,
      citasCompletadas: json['citas_completadas'] ?? 0,
      citasCanceladas: json['citas_canceladas'] ?? 0,
      totalOrdenes: json['total_ordenes'] ?? 0,
      ordenesAbiertas: json['ordenes_abiertas'] ?? 0,
      ordenesCerradas: json['ordenes_cerradas'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucursal_id': sucursalId,
      'sucursal_nombre': sucursalNombre,
      'periodo': periodo.toIso8601String(),
      'total_citas': totalCitas,
      'citas_completadas': citasCompletadas,
      'citas_canceladas': citasCanceladas,
      'total_ordenes': totalOrdenes,
      'ordenes_abiertas': ordenesAbiertas,
      'ordenes_cerradas': ordenesCerradas,
    };
  }

  // Porcentaje de citas completadas
  double get porcentajeCitasCompletadas {
    if (totalCitas == 0) return 0.0;
    return (citasCompletadas / totalCitas) * 100;
  }

  // Porcentaje de citas canceladas
  double get porcentajeCitasCanceladas {
    if (totalCitas == 0) return 0.0;
    return (citasCanceladas / totalCitas) * 100;
  }

  // Porcentaje de órdenes cerradas
  double get porcentajeOrdenesCerradas {
    if (totalOrdenes == 0) return 0.0;
    return (ordenesCerradas / totalOrdenes) * 100;
  }

  // Texto del período
  String get periodoTexto {
    final months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${months[periodo.month]} ${periodo.year}';
  }
}

// Extensiones para cálculos
extension ResumenSucursalExtension on ResumenSucursal {
  // Porcentaje de citas completadas
  double get porcentajeCitasCompletadas {
    if (totalCitas == 0) return 0.0;
    return (citasCompletadas / totalCitas) * 100;
  }

  // Porcentaje de citas canceladas
  double get porcentajeCitasCanceladas {
    if (totalCitas == 0) return 0.0;
    return (citasCanceladas / totalCitas) * 100;
  }

  // Porcentaje de órdenes cerradas
  double get porcentajeOrdenesCerradas {
    if (totalOrdenes == 0) return 0.0;
    return (ordenesCerradas / totalOrdenes) * 100;
  }

  // Texto del período
  String get periodoTexto {
    final months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${months[periodo.month]} ${periodo.year}';
  }
}

// ============================================================================
// INGRESOS POR DÍA
// ============================================================================

class IngresosSucursal {
  final String sucursalId;
  final String sucursalNombre;
  final DateTime fecha;
  final double totalPagado;
  final double totalPendiente;
  final double totalFallido;

  const IngresosSucursal({
    required this.sucursalId,
    required this.sucursalNombre,
    required this.fecha,
    required this.totalPagado,
    required this.totalPendiente,
    required this.totalFallido,
  });

  factory IngresosSucursal.fromJson(Map<String, dynamic> json) {
    return IngresosSucursal(
      sucursalId: json['sucursal_id'] ?? '',
      sucursalNombre: json['sucursal_nombre'] ?? '',
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      totalPagado: (json['total_pagado'] ?? 0).toDouble(),
      totalPendiente: (json['total_pendiente'] ?? 0).toDouble(),
      totalFallido: (json['total_fallido'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucursal_id': sucursalId,
      'sucursal_nombre': sucursalNombre,
      'fecha': fecha.toIso8601String(),
      'total_pagado': totalPagado,
      'total_pendiente': totalPendiente,
      'total_fallido': totalFallido,
    };
  }
}

// Extensiones para formateo
extension IngresosSucursalExtension on IngresosSucursal {
  String get totalPagadoTexto => '\$${totalPagado.toStringAsFixed(2)}';
  String get totalPendienteTexto => '\$${totalPendiente.toStringAsFixed(2)}';
  String get totalFallidoTexto => '\$${totalFallido.toStringAsFixed(2)}';

  double get totalGeneral => totalPagado + totalPendiente + totalFallido;
  String get totalGeneralTexto => '\$${totalGeneral.toStringAsFixed(2)}';

  String get fechaTexto {
    final day = fecha.day.toString().padLeft(2, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}

// ============================================================================
// SERVICIOS MÁS SOLICITADOS
// ============================================================================

class ServicioTop {
  final String sucursalId;
  final String sucursalNombre;
  final String servicioNombre;
  final int vecesSolicitado;
  final double totalIngresos;

  const ServicioTop({
    required this.sucursalId,
    required this.sucursalNombre,
    required this.servicioNombre,
    required this.vecesSolicitado,
    required this.totalIngresos,
  });

  factory ServicioTop.fromJson(Map<String, dynamic> json) {
    return ServicioTop(
      sucursalId: json['sucursal_id'] ?? '',
      sucursalNombre: json['sucursal_nombre'] ?? '',
      servicioNombre: json['servicio_nombre'] ?? '',
      vecesSolicitado: json['veces_solicitado'] ?? 0,
      totalIngresos: (json['total_ingresos'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucursal_id': sucursalId,
      'sucursal_nombre': sucursalNombre,
      'servicio_nombre': servicioNombre,
      'veces_solicitado': vecesSolicitado,
      'total_ingresos': totalIngresos,
    };
  }
}

// Extensiones para formateo
extension ServicioTopExtension on ServicioTop {
  String get totalIngresosTexto => '\$${totalIngresos.toStringAsFixed(2)}';

  String get promedioIngresoPorServicio {
    if (vecesSolicitado == 0) return '\$0.00';
    final promedio = totalIngresos / vecesSolicitado;
    return '\$${promedio.toStringAsFixed(2)}';
  }
}

// ============================================================================
// REFACCIONES MÁS UTILIZADAS
// ============================================================================

class RefaccionTop {
  final String sucursalId;
  final String sucursalNombre;
  final String refaccionNombre;
  final double totalUsada;
  final double totalIngresos;

  const RefaccionTop({
    required this.sucursalId,
    required this.sucursalNombre,
    required this.refaccionNombre,
    required this.totalUsada,
    required this.totalIngresos,
  });

  factory RefaccionTop.fromJson(Map<String, dynamic> json) {
    return RefaccionTop(
      sucursalId: json['sucursal_id'] ?? '',
      sucursalNombre: json['sucursal_nombre'] ?? '',
      refaccionNombre: json['refaccion_nombre'] ?? '',
      totalUsada: (json['total_usada'] ?? 0).toDouble(),
      totalIngresos: (json['total_ingresos'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucursal_id': sucursalId,
      'sucursal_nombre': sucursalNombre,
      'refaccion_nombre': refaccionNombre,
      'total_usada': totalUsada,
      'total_ingresos': totalIngresos,
    };
  }
}

// Extensiones para formateo
extension RefaccionTopExtension on RefaccionTop {
  String get totalIngresosTexto => '\$${totalIngresos.toStringAsFixed(2)}';
  String get totalUsadaTexto => totalUsada.toStringAsFixed(1);

  String get promedioIngresoPorUnidad {
    if (totalUsada == 0) return '\$0.00';
    final promedio = totalIngresos / totalUsada;
    return '\$${promedio.toStringAsFixed(2)}';
  }
}

// ============================================================================
// KPIs CONSOLIDADOS
// ============================================================================

class KPIsReportes {
  final int totalCitas;
  final int citasCompletadas;
  final int citasCanceladas;
  final int totalOrdenes;
  final int ordenesAbiertas;
  final int ordenesCerradas;
  final double ingresosMes;
  final double porcentajeOcupacionBahias;
  final String topServicio;
  final int topServicioVeces;

  const KPIsReportes({
    required this.totalCitas,
    required this.citasCompletadas,
    required this.citasCanceladas,
    required this.totalOrdenes,
    required this.ordenesAbiertas,
    required this.ordenesCerradas,
    required this.ingresosMes,
    required this.porcentajeOcupacionBahias,
    required this.topServicio,
    required this.topServicioVeces,
  });

  factory KPIsReportes.fromJson(Map<String, dynamic> json) {
    return KPIsReportes(
      totalCitas: json['total_citas'] ?? 0,
      citasCompletadas: json['citas_completadas'] ?? 0,
      citasCanceladas: json['citas_canceladas'] ?? 0,
      totalOrdenes: json['total_ordenes'] ?? 0,
      ordenesAbiertas: json['ordenes_abiertas'] ?? 0,
      ordenesCerradas: json['ordenes_cerradas'] ?? 0,
      ingresosMes: (json['ingresos_mes'] ?? 0).toDouble(),
      porcentajeOcupacionBahias:
          (json['porcentaje_ocupacion_bahias'] ?? 0).toDouble(),
      topServicio: json['top_servicio'] ?? '',
      topServicioVeces: json['top_servicio_veces'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_citas': totalCitas,
      'citas_completadas': citasCompletadas,
      'citas_canceladas': citasCanceladas,
      'total_ordenes': totalOrdenes,
      'ordenes_abiertas': ordenesAbiertas,
      'ordenes_cerradas': ordenesCerradas,
      'ingresos_mes': ingresosMes,
      'porcentaje_ocupacion_bahias': porcentajeOcupacionBahias,
      'top_servicio': topServicio,
      'top_servicio_veces': topServicioVeces,
    };
  }

  double get porcentajeCitasCompletadas {
    if (totalCitas == 0) return 0.0;
    return (citasCompletadas / totalCitas) * 100;
  }

  double get porcentajeCitasCanceladas {
    if (totalCitas == 0) return 0.0;
    return (citasCanceladas / totalCitas) * 100;
  }

  double get porcentajeOrdenesCerradas {
    if (totalOrdenes == 0) return 0.0;
    return (ordenesCerradas / totalOrdenes) * 100;
  }

  String get ingresosMesTexto => '\$${ingresosMes.toStringAsFixed(2)}';

  String get porcentajeOcupacionTexto =>
      '${porcentajeOcupacionBahias.toStringAsFixed(1)}%';

  String get topServicioTexto => '$topServicio ($topServicioVeces veces)';
}

// Extensiones para cálculos de KPIs
extension KPIsReportesExtension on KPIsReportes {
  double get porcentajeCitasCompletadas {
    if (totalCitas == 0) return 0.0;
    return (citasCompletadas / totalCitas) * 100;
  }

  double get porcentajeCitasCanceladas {
    if (totalCitas == 0) return 0.0;
    return (citasCanceladas / totalCitas) * 100;
  }

  double get porcentajeOrdenesCerradas {
    if (totalOrdenes == 0) return 0.0;
    return (ordenesCerradas / totalOrdenes) * 100;
  }

  String get ingresosMesTexto => '\$${ingresosMes.toStringAsFixed(2)}';

  String get porcentajeOcupacionTexto =>
      '${porcentajeOcupacionBahias.toStringAsFixed(1)}%';

  String get topServicioTexto => '$topServicio ($topServicioVeces veces)';
}

// ============================================================================
// MODELOS PARA GRÁFICAS
// ============================================================================

class DatoGrafica {
  final String etiqueta;
  final double valor;
  final String? color;
  final Map<String, dynamic>? metadatos;

  const DatoGrafica({
    required this.etiqueta,
    required this.valor,
    this.color,
    this.metadatos,
  });

  factory DatoGrafica.fromJson(Map<String, dynamic> json) {
    return DatoGrafica(
      etiqueta: json['etiqueta'] ?? '',
      valor: (json['valor'] ?? 0).toDouble(),
      color: json['color'],
      metadatos: json['metadatos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'etiqueta': etiqueta,
      'valor': valor,
      'color': color,
      'metadatos': metadatos,
    };
  }
}

class DatoSerie {
  final String nombre;
  final List<DatoGrafica> datos;
  final String? color;

  const DatoSerie({
    required this.nombre,
    required this.datos,
    this.color,
  });

  factory DatoSerie.fromJson(Map<String, dynamic> json) {
    return DatoSerie(
      nombre: json['nombre'] ?? '',
      datos: (json['datos'] as List<dynamic>?)
              ?.map((e) => DatoGrafica.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'datos': datos.map((e) => e.toJson()).toList(),
      'color': color,
    };
  }
}

// ============================================================================
// CLIENTES FRECUENTES
// ============================================================================

class ClienteFrecuente {
  final String clienteId;
  final String clienteNombre;
  final int totalCitas;
  final double totalGastado;
  final DateTime? ultimaVisita;
  final String? telefono;
  final String? correo;

  const ClienteFrecuente({
    required this.clienteId,
    required this.clienteNombre,
    required this.totalCitas,
    required this.totalGastado,
    this.ultimaVisita,
    this.telefono,
    this.correo,
  });

  factory ClienteFrecuente.fromJson(Map<String, dynamic> json) {
    return ClienteFrecuente(
      clienteId: json['cliente_id'] ?? '',
      clienteNombre: json['cliente_nombre'] ?? '',
      totalCitas: json['total_citas'] ?? 0,
      totalGastado: (json['total_gastado'] ?? 0).toDouble(),
      ultimaVisita: json['ultima_visita'] != null
          ? DateTime.parse(json['ultima_visita'])
          : null,
      telefono: json['telefono'],
      correo: json['correo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente_id': clienteId,
      'cliente_nombre': clienteNombre,
      'total_citas': totalCitas,
      'total_gastado': totalGastado,
      'ultima_visita': ultimaVisita?.toIso8601String(),
      'telefono': telefono,
      'correo': correo,
    };
  }

  String get totalGastadoTexto => '\$${totalGastado.toStringAsFixed(2)}';

  String get promedioGastoPorCita {
    if (totalCitas == 0) return '\$0.00';
    final promedio = totalGastado / totalCitas;
    return '\$${promedio.toStringAsFixed(2)}';
  }

  String get ultimaVisitaTexto {
    if (ultimaVisita == null) return 'Sin visitas';
    final now = DateTime.now();
    final difference = now.difference(ultimaVisita!);

    if (difference.inDays == 0) return 'Hoy';
    if (difference.inDays == 1) return 'Ayer';
    if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
    if (difference.inDays < 30)
      return 'Hace ${(difference.inDays / 7).floor()} semanas';
    if (difference.inDays < 365)
      return 'Hace ${(difference.inDays / 30).floor()} meses';
    return 'Hace ${(difference.inDays / 365).floor()} años';
  }

  String get iniciales {
    final words = clienteNombre.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

extension ClienteFrecuenteExtension on ClienteFrecuente {
  String get totalGastadoTexto => '\$${totalGastado.toStringAsFixed(2)}';

  String get promedioGastoPorCita {
    if (totalCitas == 0) return '\$0.00';
    final promedio = totalGastado / totalCitas;
    return '\$${promedio.toStringAsFixed(2)}';
  }

  String get ultimaVisitaTexto {
    if (ultimaVisita == null) return 'Sin visitas';
    final now = DateTime.now();
    final difference = now.difference(ultimaVisita!);

    if (difference.inDays == 0) return 'Hoy';
    if (difference.inDays == 1) return 'Ayer';
    if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
    if (difference.inDays < 30)
      return 'Hace ${(difference.inDays / 7).floor()} semanas';
    if (difference.inDays < 365)
      return 'Hace ${(difference.inDays / 30).floor()} meses';
    return 'Hace ${(difference.inDays / 365).floor()} años';
  }

  String get iniciales {
    final words = clienteNombre.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

// ============================================================================
// TÉCNICOS PRODUCTIVOS
// ============================================================================

class TecnicoProductivo {
  final String empleadoId;
  final String empleadoNombre;
  final int ordenesAtendidas;
  final int minutosTrabajados;
  final double ingresosGenerados;
  final String? especialidad;

  const TecnicoProductivo({
    required this.empleadoId,
    required this.empleadoNombre,
    required this.ordenesAtendidas,
    required this.minutosTrabajados,
    required this.ingresosGenerados,
    this.especialidad,
  });

  factory TecnicoProductivo.fromJson(Map<String, dynamic> json) {
    return TecnicoProductivo(
      empleadoId: json['empleado_id'] ?? '',
      empleadoNombre: json['empleado_nombre'] ?? '',
      ordenesAtendidas: json['ordenes_atendidas'] ?? 0,
      minutosTrabajados: json['minutos_trabajados'] ?? 0,
      ingresosGenerados: (json['ingresos_generados'] ?? 0).toDouble(),
      especialidad: json['especialidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empleado_id': empleadoId,
      'empleado_nombre': empleadoNombre,
      'ordenes_atendidas': ordenesAtendidas,
      'minutos_trabajados': minutosTrabajados,
      'ingresos_generados': ingresosGenerados,
      'especialidad': especialidad,
    };
  }

  String get horasTrabajadasTexto {
    final horas = minutosTrabajados / 60;
    return '${horas.toStringAsFixed(1)}h';
  }

  String get ingresosGeneradosTexto =>
      '\$${ingresosGenerados.toStringAsFixed(2)}';

  String get promedioIngresoPorOrden {
    if (ordenesAtendidas == 0) return '\$0.00';
    final promedio = ingresosGenerados / ordenesAtendidas;
    return '\$${promedio.toStringAsFixed(2)}';
  }

  double get promedioMinutosPorOrden {
    if (ordenesAtendidas == 0) return 0.0;
    return minutosTrabajados / ordenesAtendidas;
  }

  String get promedioMinutosPorOrdenTexto {
    final promedio = promedioMinutosPorOrden;
    if (promedio < 60) return '${promedio.toStringAsFixed(0)} min';
    final horas = promedio / 60;
    return '${horas.toStringAsFixed(1)}h';
  }

  String get iniciales {
    final words = empleadoNombre.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

extension TecnicoProductivoExtension on TecnicoProductivo {
  String get horasTrabajadasTexto {
    final horas = minutosTrabajados / 60;
    return '${horas.toStringAsFixed(1)}h';
  }

  String get ingresosGeneradosTexto =>
      '\$${ingresosGenerados.toStringAsFixed(2)}';

  String get promedioIngresoPorOrden {
    if (ordenesAtendidas == 0) return '\$0.00';
    final promedio = ingresosGenerados / ordenesAtendidas;
    return '\$${promedio.toStringAsFixed(2)}';
  }

  double get promedioMinutosPorOrden {
    if (ordenesAtendidas == 0) return 0.0;
    return minutosTrabajados / ordenesAtendidas;
  }

  String get promedioMinutosPorOrdenTexto {
    final promedio = promedioMinutosPorOrden;
    if (promedio < 60) return '${promedio.toStringAsFixed(0)} min';
    final horas = promedio / 60;
    return '${horas.toStringAsFixed(1)}h';
  }

  String get iniciales {
    final words = empleadoNombre.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

// ============================================================================
// ALERTAS OPERATIVAS
// ============================================================================

class AlertaOperativa {
  final String tipo;
  final String titulo;
  final String descripcion;
  final String severidad; // alta, media, baja
  final DateTime fecha;
  final Map<String, dynamic>? metadata;

  const AlertaOperativa({
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.severidad,
    required this.fecha,
    this.metadata,
  });

  factory AlertaOperativa.fromJson(Map<String, dynamic> json) {
    return AlertaOperativa(
      tipo: json['tipo'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      severidad: json['severidad'] ?? 'baja',
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'titulo': titulo,
      'descripcion': descripcion,
      'severidad': severidad,
      'fecha': fecha.toIso8601String(),
      'metadata': metadata,
    };
  }

  String get fechaTexto {
    final now = DateTime.now();
    final difference = now.difference(fecha);

    if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Hace ${difference.inHours} h';
    if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  String get severidadTexto {
    switch (severidad.toLowerCase()) {
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Media';
      case 'baja':
        return 'Baja';
      default:
        return 'Desconocida';
    }
  }
}

extension AlertaOperativaExtension on AlertaOperativa {
  String get fechaTexto {
    final now = DateTime.now();
    final difference = now.difference(fecha);

    if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Hace ${difference.inHours} h';
    if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  String get severidadTexto {
    switch (severidad.toLowerCase()) {
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Media';
      case 'baja':
        return 'Baja';
      default:
        return 'Desconocida';
    }
  }
}

// ============================================================================
// FILTROS PARA REPORTES
// ============================================================================

class FiltrosReportes {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String? tipoReporte; // 'diario', 'semanal', 'mensual'
  final List<String>? serviciosSeleccionados;
  final List<String>? tecnicosSeleccionados;
  final bool incluirCanceladas;
  final bool incluirPendientes;

  const FiltrosReportes({
    this.fechaInicio,
    this.fechaFin,
    this.tipoReporte,
    this.serviciosSeleccionados,
    this.tecnicosSeleccionados,
    this.incluirCanceladas = true,
    this.incluirPendientes = true,
  });

  factory FiltrosReportes.fromJson(Map<String, dynamic> json) {
    return FiltrosReportes(
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'])
          : null,
      fechaFin:
          json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : null,
      tipoReporte: json['tipo_reporte'],
      serviciosSeleccionados:
          (json['servicios_seleccionados'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
      tecnicosSeleccionados: (json['tecnicos_seleccionados'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      incluirCanceladas: json['incluir_canceladas'] ?? true,
      incluirPendientes: json['incluir_pendientes'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'tipo_reporte': tipoReporte,
      'servicios_seleccionados': serviciosSeleccionados,
      'tecnicos_seleccionados': tecnicosSeleccionados,
      'incluir_canceladas': incluirCanceladas,
      'incluir_pendientes': incluirPendientes,
    };
  }
}

// ============================================================================
// CONSTANTES Y HELPERS
// ============================================================================

class ReportesConstants {
  static const Map<String, String> tiposReporte = {
    'diario': 'Reporte Diario',
    'semanal': 'Reporte Semanal',
    'mensual': 'Reporte Mensual',
  };

  static const Map<String, String> coloresSeveridad = {
    'alta': '#F44336',
    'media': '#FF9800',
    'baja': '#4CAF50',
  };

  static const List<String> coloresGraficas = [
    '#2196F3',
    '#4CAF50',
    '#FF9800',
    '#9C27B0',
    '#00BCD4',
    '#795548',
    '#607D8B',
    '#E91E63',
  ];
}
