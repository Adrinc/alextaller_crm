// Enum para tipo de descuento
enum TipoDescuento {
  porcentaje,
  precioFijo;

  String get valor {
    switch (this) {
      case TipoDescuento.porcentaje:
        return 'porcentaje';
      case TipoDescuento.precioFijo:
        return 'precio_fijo';
    }
  }

  static TipoDescuento fromString(String value) {
    switch (value) {
      case 'porcentaje':
        return TipoDescuento.porcentaje;
      case 'precio_fijo':
        return TipoDescuento.precioFijo;
      default:
        return TipoDescuento.porcentaje;
    }
  }

  String get displayName {
    switch (this) {
      case TipoDescuento.porcentaje:
        return 'Porcentaje';
      case TipoDescuento.precioFijo:
        return 'Precio Fijo';
    }
  }
}

class PromocionSucursal {
  final String promocionId;
  final String titulo;
  final String descripcion;
  final String tipoDescuento;
  final double valorDescuento;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool activo;
  final Map<String, dynamic>? condicionesJson;
  final String sucursalId;
  final String sucursalNombre;
  final DateTime createdAt;
  final DateTime updatedAt;

  PromocionSucursal({
    required this.promocionId,
    required this.titulo,
    required this.descripcion,
    required this.tipoDescuento,
    required this.valorDescuento,
    required this.fechaInicio,
    required this.fechaFin,
    required this.activo,
    this.condicionesJson,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PromocionSucursal.fromJson(Map<String, dynamic> json) {
    return PromocionSucursal(
      promocionId: json['promocion_id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipoDescuento: json['tipo_descuento'] ?? '',
      valorDescuento:
          double.tryParse(json['valor_descuento']?.toString() ?? '0') ?? 0.0,
      fechaInicio: DateTime.tryParse(json['fecha_inicio']?.toString() ?? '') ??
          DateTime.now(),
      fechaFin: DateTime.tryParse(json['fecha_fin']?.toString() ?? '') ??
          DateTime.now(),
      activo: json['activo'] ?? false,
      condicionesJson: json['condiciones_json'] as Map<String, dynamic>?,
      sucursalId: json['sucursal_id'] ?? '',
      sucursalNombre: json['sucursal_nombre'] ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promocion_id': promocionId,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo_descuento': tipoDescuento,
      'valor_descuento': valorDescuento,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'activo': activo,
      'condiciones_json': condicionesJson,
      'sucursal_id': sucursalId,
      'sucursal_nombre': sucursalNombre,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Getters de conveniencia
  String get fechaInicioTexto {
    return '${fechaInicio.day.toString().padLeft(2, '0')}/${fechaInicio.month.toString().padLeft(2, '0')}/${fechaInicio.year}';
  }

  String get fechaFinTexto {
    return '${fechaFin.day.toString().padLeft(2, '0')}/${fechaFin.month.toString().padLeft(2, '0')}/${fechaFin.year}';
  }

  String get vigenciaTexto {
    return '$fechaInicioTexto - $fechaFinTexto';
  }

  String get valorDescuentoTexto {
    if (tipoDescuento.toLowerCase() == 'porcentaje') {
      return '${valorDescuento.toStringAsFixed(0)}%';
    } else {
      return '\$${valorDescuento.toStringAsFixed(0)}';
    }
  }

  String get estadoTexto {
    final ahora = DateTime.now();
    if (!activo) return 'Inactiva';
    if (ahora.isBefore(fechaInicio)) return 'Próxima';
    if (ahora.isAfter(fechaFin)) return 'Expirada';
    return 'Vigente';
  }

  bool get esVigente {
    final ahora = DateTime.now();
    return activo &&
        ahora.isAfter(fechaInicio.subtract(const Duration(days: 1))) &&
        ahora.isBefore(fechaFin.add(const Duration(days: 1)));
  }

  bool get esProxima {
    final ahora = DateTime.now();
    return activo && ahora.isBefore(fechaInicio);
  }

  bool get esExpirada {
    final ahora = DateTime.now();
    return ahora.isAfter(fechaFin);
  }

  bool get proximaAVencer {
    final ahora = DateTime.now();
    final diasRestantes = fechaFin.difference(ahora).inDays;
    return esVigente && diasRestantes <= 7 && diasRestantes > 0;
  }

  int get diasRestantes {
    final ahora = DateTime.now();
    return fechaFin.difference(ahora).inDays;
  }

  String get ambitoTexto {
    // Si tiene sucursal específica es Local, si no es Global
    return sucursalId.isNotEmpty ? 'Local' : 'Global';
  }

  String get tipoDescuentoTexto {
    switch (tipoDescuento.toLowerCase()) {
      case 'porcentaje':
        return 'Porcentaje';
      case 'monto_fijo':
        return 'Monto Fijo';
      case 'descuento_especial':
        return 'Descuento Especial';
      default:
        return tipoDescuento;
    }
  }
}

class KPIsPromociones {
  final int totalActivas;
  final int proximasVencer;
  final int expiradasMes;
  final double porcentajeServiciosConPromo;

  KPIsPromociones({
    required this.totalActivas,
    required this.proximasVencer,
    required this.expiradasMes,
    required this.porcentajeServiciosConPromo,
  });

  String get totalActivasTexto => totalActivas.toString();
  String get proximasVencerTexto => proximasVencer.toString();
  String get expiradasMesTexto => expiradasMes.toString();
  String get porcentajeServiciosConPromoTexto =>
      '${porcentajeServiciosConPromo.toStringAsFixed(1)}%';
}

class CrearPromocion {
  final String titulo;
  final String descripcion;
  final String tipoDescuento;
  final double valorDescuento;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool activo;
  final Map<String, dynamic>? condicionesJson;
  final List<String> sucursalesIds;
  final List<String> serviciosIds;

  CrearPromocion({
    required this.titulo,
    required this.descripcion,
    required this.tipoDescuento,
    required this.valorDescuento,
    required this.fechaInicio,
    required this.fechaFin,
    this.activo = true,
    this.condicionesJson,
    this.sucursalesIds = const [],
    this.serviciosIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo_descuento': tipoDescuento,
      'valor_descuento': valorDescuento,
      'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
      'fecha_fin': fechaFin.toIso8601String().split('T')[0],
      'activo': activo,
      'condiciones_json': condicionesJson,
    };
  }
}

class ActualizarPromocion {
  final String promocionId;
  final String? titulo;
  final String? descripcion;
  final String? tipoDescuento;
  final double? valorDescuento;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final bool? activo;
  final Map<String, dynamic>? condicionesJson;
  final List<String>? sucursalesIds;
  final List<String>? serviciosIds;

  ActualizarPromocion({
    required this.promocionId,
    this.titulo,
    this.descripcion,
    this.tipoDescuento,
    this.valorDescuento,
    this.fechaInicio,
    this.fechaFin,
    this.activo,
    this.condicionesJson,
    this.sucursalesIds,
    this.serviciosIds,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (titulo != null) data['titulo'] = titulo;
    if (descripcion != null) data['descripcion'] = descripcion;
    if (tipoDescuento != null) data['tipo_descuento'] = tipoDescuento;
    if (valorDescuento != null) data['valor_descuento'] = valorDescuento;
    if (fechaInicio != null)
      data['fecha_inicio'] = fechaInicio!.toIso8601String().split('T')[0];
    if (fechaFin != null)
      data['fecha_fin'] = fechaFin!.toIso8601String().split('T')[0];
    if (activo != null) data['activo'] = activo;
    if (condicionesJson != null) data['condiciones_json'] = condicionesJson;

    data['updated_at'] = DateTime.now().toIso8601String();

    return data;
  }
}

class ServicioPromocion {
  final String id;
  final String promocionId;
  final String servicioId;
  final String? servicioNombre;

  ServicioPromocion({
    required this.id,
    required this.promocionId,
    required this.servicioId,
    this.servicioNombre,
  });

  factory ServicioPromocion.fromJson(Map<String, dynamic> json) {
    return ServicioPromocion(
      id: json['id'] ?? '',
      promocionId: json['promocion_id'] ?? '',
      servicioId: json['servicio_id'] ?? '',
      servicioNombre: json['servicio_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promocion_id': promocionId,
      'servicio_id': servicioId,
      'servicio_nombre': servicioNombre,
    };
  }
}

class CondicionPromocion {
  final double? montoMinimo;
  final int? cantidadMinima;
  final List<String>? tiposVehiculo;
  final List<String>? serviciosRequeridos;
  final bool? nuevosClientes;
  final String? descripcionEspecial;

  CondicionPromocion({
    this.montoMinimo,
    this.cantidadMinima,
    this.tiposVehiculo,
    this.serviciosRequeridos,
    this.nuevosClientes,
    this.descripcionEspecial,
  });

  factory CondicionPromocion.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CondicionPromocion();

    return CondicionPromocion(
      montoMinimo: double.tryParse(json['monto_minimo']?.toString() ?? ''),
      cantidadMinima: int.tryParse(json['cantidad_minima']?.toString() ?? ''),
      tiposVehiculo: (json['tipos_vehiculo'] as List?)?.cast<String>(),
      serviciosRequeridos:
          (json['servicios_requeridos'] as List?)?.cast<String>(),
      nuevosClientes: json['nuevos_clientes'] as bool?,
      descripcionEspecial: json['descripcion_especial'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (montoMinimo != null) data['monto_minimo'] = montoMinimo;
    if (cantidadMinima != null) data['cantidad_minima'] = cantidadMinima;
    if (tiposVehiculo != null) data['tipos_vehiculo'] = tiposVehiculo;
    if (serviciosRequeridos != null)
      data['servicios_requeridos'] = serviciosRequeridos;
    if (nuevosClientes != null) data['nuevos_clientes'] = nuevosClientes;
    if (descripcionEspecial != null)
      data['descripcion_especial'] = descripcionEspecial;

    return data;
  }

  String get textoAmigable {
    final List<String> condiciones = [];

    if (montoMinimo != null && montoMinimo! > 0) {
      condiciones.add('Monto mínimo: \$${montoMinimo!.toStringAsFixed(0)}');
    }

    if (cantidadMinima != null && cantidadMinima! > 0) {
      condiciones.add('Cantidad mínima: ${cantidadMinima}');
    }

    if (tiposVehiculo != null && tiposVehiculo!.isNotEmpty) {
      condiciones.add('Tipos de vehículo: ${tiposVehiculo!.join(", ")}');
    }

    if (nuevosClientes == true) {
      condiciones.add('Solo nuevos clientes');
    }

    if (descripcionEspecial != null && descripcionEspecial!.isNotEmpty) {
      condiciones.add(descripcionEspecial!);
    }

    return condiciones.isEmpty
        ? 'Sin condiciones especiales'
        : condiciones.join('\n');
  }
}

// =============================================================================
// NUEVOS MODELOS PARA SISTEMA GLOBAL DE PROMOCIONES
// =============================================================================

// Modelo para promoción activa (vista vw_promociones_activas)
class PromocionActiva {
  final String promocionId;
  final String titulo;
  final String descripcion;
  final TipoDescuento tipoDescuento;
  final double valorDescuento;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool activo;
  final Map<String, dynamic> condicionesJson;
  final String? sucursalId;
  final String? sucursalNombre;

  const PromocionActiva({
    required this.promocionId,
    required this.titulo,
    required this.descripcion,
    required this.tipoDescuento,
    required this.valorDescuento,
    required this.fechaInicio,
    required this.fechaFin,
    required this.activo,
    required this.condicionesJson,
    this.sucursalId,
    this.sucursalNombre,
  });

  factory PromocionActiva.fromJson(Map<String, dynamic> json) {
    return PromocionActiva(
      promocionId: json['promocion_id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipoDescuento:
          TipoDescuento.fromString(json['tipo_descuento'] ?? 'porcentaje'),
      valorDescuento: (json['valor_descuento'] ?? 0).toDouble(),
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      activo: json['activo'] ?? false,
      condicionesJson: json['condiciones_json'] ?? {},
      sucursalId: json['sucursal_id'],
      sucursalNombre: json['sucursal_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promocion_id': promocionId,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo_descuento': tipoDescuento.valor,
      'valor_descuento': valorDescuento,
      'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
      'fecha_fin': fechaFin.toIso8601String().split('T')[0],
      'activo': activo,
      'condiciones_json': condicionesJson,
      'sucursal_id': sucursalId,
      'sucursal_nombre': sucursalNombre,
    };
  }

  // Getters auxiliares
  String get valorDescuentoTexto {
    if (tipoDescuento == TipoDescuento.porcentaje) {
      return '${valorDescuento.toStringAsFixed(0)}%';
    } else {
      return '\$${valorDescuento.toStringAsFixed(2)}';
    }
  }

  String get vigenciaTexto {
    final inicio =
        '${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}';
    final fin = '${fechaFin.day}/${fechaFin.month}/${fechaFin.year}';
    return '$inicio - $fin';
  }

  bool get estaVigente {
    final ahora = DateTime.now();
    return ahora.isAfter(fechaInicio) &&
        ahora.isBefore(fechaFin.add(const Duration(days: 1)));
  }

  String get estadoTexto {
    if (!activo) return 'Inactivo';
    if (estaVigente) return 'Activo';
    if (DateTime.now().isBefore(fechaInicio)) return 'Programado';
    return 'Vencido';
  }

  int get diasRestantes {
    final ahora = DateTime.now();
    return fechaFin.difference(ahora).inDays;
  }
}

// Modelo para ROI de promoción (vista vw_promociones_roi)
class PromocionROI {
  final String promocionId;
  final String titulo;
  final int canjes;
  final int clientesUnicos;
  final double descuentoTotal;
  final double ingresoBruto;
  final double ingresoNeto;
  final double roi;

  const PromocionROI({
    required this.promocionId,
    required this.titulo,
    required this.canjes,
    required this.clientesUnicos,
    required this.descuentoTotal,
    required this.ingresoBruto,
    required this.ingresoNeto,
    required this.roi,
  });

  factory PromocionROI.fromJson(Map<String, dynamic> json) {
    return PromocionROI(
      promocionId: json['promocion_id'] ?? '',
      titulo: json['titulo'] ?? '',
      canjes: json['canjes'] ?? 0,
      clientesUnicos: json['clientes_unicos'] ?? 0,
      descuentoTotal: (json['descuento_total'] ?? 0).toDouble(),
      ingresoBruto: (json['ingreso_bruto'] ?? 0).toDouble(),
      ingresoNeto: (json['ingreso_neto'] ?? 0).toDouble(),
      roi: (json['roi'] ?? 0).toDouble(),
    );
  }

  // Getters auxiliares
  String get canjesTexto => canjes.toString();
  String get clientesUnicosTexto => clientesUnicos.toString();
  String get descuentoTotalTexto => '\$${descuentoTotal.toStringAsFixed(2)}';
  String get ingresoBrutoTexto => '\$${ingresoBruto.toStringAsFixed(2)}';
  String get ingresoNetoTexto => '\$${ingresoNeto.toStringAsFixed(2)}';
  String get roiTexto => '${roi.toStringAsFixed(1)}%';

  double get ticketPromedio {
    return canjes > 0 ? ingresoBruto / canjes : 0;
  }

  String get ticketPromedioTexto => '\$${ticketPromedio.toStringAsFixed(2)}';
}

// Modelo para cupón (tabla cupones)
class CuponItem {
  final String id;
  final String codigo;
  final String promocionId;
  final int limiteUsoGlobal;
  final int usosRealizados;
  final int limiteUsoPorCliente;
  final bool activo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final DateTime creadoEn;

  const CuponItem({
    required this.id,
    required this.codigo,
    required this.promocionId,
    required this.limiteUsoGlobal,
    required this.usosRealizados,
    required this.limiteUsoPorCliente,
    required this.activo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.creadoEn,
  });

  factory CuponItem.fromJson(Map<String, dynamic> json) {
    return CuponItem(
      id: json['id'] ?? '',
      codigo: json['codigo'] ?? '',
      promocionId: json['promocion_id'] ?? '',
      limiteUsoGlobal: json['limite_uso_global'] ?? 1,
      usosRealizados: json['usos_realizados'] ?? 0,
      limiteUsoPorCliente: json['limite_uso_por_cliente'] ?? 1,
      activo: json['activo'] ?? true,
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      creadoEn: DateTime.parse(json['creado_en']),
    );
  }

  // Getters auxiliares
  String get usoTexto => '$usosRealizados/$limiteUsoGlobal';

  bool get estaDisponible {
    return activo &&
        usosRealizados < limiteUsoGlobal &&
        DateTime.now().isAfter(fechaInicio) &&
        DateTime.now().isBefore(fechaFin.add(const Duration(days: 1)));
  }

  String get estadoTexto {
    if (!activo) return 'Inactivo';
    if (usosRealizados >= limiteUsoGlobal) return 'Agotado';
    if (DateTime.now().isBefore(fechaInicio)) return 'Programado';
    if (DateTime.now().isAfter(fechaFin)) return 'Vencido';
    return 'Disponible';
  }

  double get porcentajeUso {
    return limiteUsoGlobal > 0 ? (usosRealizados / limiteUsoGlobal) : 0;
  }
}

// Modelo para resultado de canje
class ResultadoCanje {
  final bool ok;
  final String mensaje;
  final String? cuponId;
  final String? promocionId;
  final TipoDescuento? tipoDescuento;
  final double? valorDescuento;
  final double? descuentoAplicado;

  const ResultadoCanje({
    required this.ok,
    required this.mensaje,
    this.cuponId,
    this.promocionId,
    this.tipoDescuento,
    this.valorDescuento,
    this.descuentoAplicado,
  });

  factory ResultadoCanje.fromJson(Map<String, dynamic> json) {
    return ResultadoCanje(
      ok: json['ok'] ?? false,
      mensaje: json['mensaje'] ?? '',
      cuponId: json['cupon_id'],
      promocionId: json['promocion_id'],
      tipoDescuento: json['tipo_descuento'] != null
          ? TipoDescuento.fromString(json['tipo_descuento'])
          : null,
      valorDescuento: json['valor_descuento']?.toDouble(),
      descuentoAplicado: json['descuento_aplicado']?.toDouble(),
    );
  }
}

// Modelo para resultado de publicación
class ResultadoPublicacion {
  final String sucursalId;
  final bool insertado;
  final String? sucursalNombre;

  const ResultadoPublicacion({
    required this.sucursalId,
    required this.insertado,
    this.sucursalNombre,
  });

  factory ResultadoPublicacion.fromJson(Map<String, dynamic> json) {
    return ResultadoPublicacion(
      sucursalId: json['sucursal_id'] ?? '',
      insertado: json['insertado'] ?? false,
      sucursalNombre: json['sucursal_nombre'],
    );
  }
}

// Modelo para cupón recién emitido
class CuponEmitido {
  final String cuponId;
  final String codigo;

  const CuponEmitido({
    required this.cuponId,
    required this.codigo,
  });

  factory CuponEmitido.fromJson(Map<String, dynamic> json) {
    return CuponEmitido(
      cuponId: json['cupon_id'] ?? '',
      codigo: json['codigo'] ?? '',
    );
  }
}

// Modelo para sucursal simple (para selector)
class SucursalSimple {
  final String id;
  final String nombre;
  final bool activo;

  const SucursalSimple({
    required this.id,
    required this.nombre,
    required this.activo,
  });

  factory SucursalSimple.fromJson(Map<String, dynamic> json) {
    return SucursalSimple(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      activo: json['activa'] ??
          false, // Usar 'activa' que es el nombre correcto de la columna
    );
  }
}
