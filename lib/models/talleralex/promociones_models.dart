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
