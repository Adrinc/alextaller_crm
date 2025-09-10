// ignore_for_file: constant_identifier_names

enum EstadoOrdenServicio {
  pendiente('pendiente'),
  en_progreso('en_progreso'),
  pausada('pausada'),
  esperando_refacciones('esperando_refacciones'),
  esperando_aprobacion('esperando_aprobacion'),
  completada('completada'),
  cerrada('cerrada'),
  entregada('entregada'),
  cancelada('cancelada');

  const EstadoOrdenServicio(this.value);
  final String value;

  static EstadoOrdenServicio fromString(String value) {
    return EstadoOrdenServicio.values.firstWhere(
      (element) => element.value == value,
      orElse: () => EstadoOrdenServicio.pendiente,
    );
  }

  String get displayName {
    switch (this) {
      case EstadoOrdenServicio.pendiente:
        return 'Pendiente';
      case EstadoOrdenServicio.en_progreso:
        return 'En progreso';
      case EstadoOrdenServicio.pausada:
        return 'Pausada';
      case EstadoOrdenServicio.esperando_refacciones:
        return 'Esperando refacciones';
      case EstadoOrdenServicio.esperando_aprobacion:
        return 'Esperando aprobación';
      case EstadoOrdenServicio.completada:
        return 'Completada';
      case EstadoOrdenServicio.cerrada:
        return 'Cerrada';
      case EstadoOrdenServicio.entregada:
        return 'Entregada';
      case EstadoOrdenServicio.cancelada:
        return 'Cancelada';
    }
  }
}

enum CombustibleTipo {
  gasolina('gasolina'),
  diesel('diesel'),
  electrico('electrico'),
  hibrido('hibrido'),
  gas('gas');

  const CombustibleTipo(this.value);
  final String value;

  static CombustibleTipo fromString(String value) {
    return CombustibleTipo.values.firstWhere(
      (element) => element.value == value,
      orElse: () => CombustibleTipo.gasolina,
    );
  }

  String get displayName {
    switch (this) {
      case CombustibleTipo.gasolina:
        return 'Gasolina';
      case CombustibleTipo.diesel:
        return 'Diésel';
      case CombustibleTipo.electrico:
        return 'Eléctrico';
      case CombustibleTipo.hibrido:
        return 'Híbrido';
      case CombustibleTipo.gas:
        return 'Gas';
    }
  }
}

class ClienteGrid {
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

  const ClienteGrid({
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
  });

  factory ClienteGrid.fromJson(Map<String, dynamic> json) {
    return ClienteGrid(
      clienteId: json['cliente_id'] as String,
      clienteNombre: json['cliente_nombre'] as String,
      correo: json['correo'] as String?,
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
      rfc: json['rfc'] as String?,
      notas: json['notas'] as String?,
      totalVehiculos: json['total_vehiculos'] as int,
      citasProximas: json['citas_proximas'] as int,
      ultimaVisita: json['ultima_visita'] != null
          ? DateTime.parse(json['ultima_visita'] as String)
          : null,
      totalGastado: (json['total_gastado'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get ultimaVisitaTexto {
    if (ultimaVisita == null) return 'Sin visitas';

    final now = DateTime.now();
    final difference = now.difference(ultimaVisita!);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks semana${weeks != 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months mes${months != 1 ? 'es' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years año${years != 1 ? 's' : ''}';
    }
  }

  String get totalGastadoTexto {
    if (totalGastado == 0) return '\$0.00';
    return '\$${totalGastado.toStringAsFixed(2)}';
  }
}

class HistorialCliente {
  final String clienteId;
  final String clienteNombre;
  final String vehiculoId;
  final String placa;
  final String marca;
  final String modelo;
  final int anio;
  final String ordenId;
  final EstadoOrdenServicio estado;
  final DateTime fechaInicio;
  final DateTime? fechaFinReal;
  final double totalServicios;
  final double totalRefacciones;
  final double totalGeneral;

  const HistorialCliente({
    required this.clienteId,
    required this.clienteNombre,
    required this.vehiculoId,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.ordenId,
    required this.estado,
    required this.fechaInicio,
    this.fechaFinReal,
    required this.totalServicios,
    required this.totalRefacciones,
    required this.totalGeneral,
  });

  factory HistorialCliente.fromJson(Map<String, dynamic> json) {
    return HistorialCliente(
      clienteId: json['cliente_id'] as String,
      clienteNombre: json['cliente_nombre'] as String,
      vehiculoId: json['vehiculo_id'] as String,
      placa: json['placa'] as String,
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      anio: json['anio'] as int,
      ordenId: json['orden_id'] as String,
      estado: EstadoOrdenServicio.fromString(json['estado'] as String),
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFinReal: json['fecha_fin_real'] != null
          ? DateTime.parse(json['fecha_fin_real'] as String)
          : null,
      totalServicios: (json['total_servicios'] as num?)?.toDouble() ?? 0.0,
      totalRefacciones: (json['total_refacciones'] as num?)?.toDouble() ?? 0.0,
      totalGeneral: (json['total_general'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get vehiculoTexto => '$marca $modelo $anio';
  String get totalTexto => '\$${totalGeneral.toStringAsFixed(2)}';
}

class Vehiculo {
  final String id;
  final String clienteId;
  final String marca;
  final String modelo;
  final int anio;
  final String placa;
  final String? vin;
  final String? color;
  final CombustibleTipo combustible;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehiculo({
    required this.id,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
    this.vin,
    this.color,
    required this.combustible,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'] as String,
      clienteId: json['cliente_id'] as String,
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      anio: json['anio'] as int,
      placa: json['placa'] as String,
      vin: json['vin'] as String?,
      color: json['color'] as String?,
      combustible: CombustibleTipo.fromString(json['combustible'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get descripcionCompleta => '$marca $modelo $anio';
}

class NuevoCliente {
  final String nombre;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final String? rfc;
  final String? notas;

  const NuevoCliente({
    required this.nombre,
    this.correo,
    this.telefono,
    this.direccion,
    this.rfc,
    this.notas,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (correo != null && correo!.isNotEmpty) 'correo': correo,
      if (telefono != null && telefono!.isNotEmpty) 'telefono': telefono,
      if (direccion != null && direccion!.isNotEmpty) 'direccion': direccion,
      if (rfc != null && rfc!.isNotEmpty) 'rfc': rfc,
      if (notas != null && notas!.isNotEmpty) 'notas': notas,
    };
  }
}

class NuevoVehiculo {
  final String clienteId;
  final String marca;
  final String modelo;
  final int anio;
  final String placa;
  final String? vin;
  final String? color;
  final CombustibleTipo combustible;

  const NuevoVehiculo({
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
    this.vin,
    this.color,
    required this.combustible,
  });

  Map<String, dynamic> toJson() {
    return {
      'cliente_id': clienteId,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'placa': placa,
      if (vin != null && vin!.isNotEmpty) 'vin': vin,
      if (color != null && color!.isNotEmpty) 'color': color,
      'combustible': combustible.value,
    };
  }
}
