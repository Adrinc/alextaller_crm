// ignore_for_file: constant_identifier_names

enum PuestoEmpleado {
  tecnico('tecnico'),
  recepcion('recepcion'),
  gerente('gerente');

  const PuestoEmpleado(this.value);
  final String value;

  static PuestoEmpleado fromString(String value) {
    return PuestoEmpleado.values.firstWhere(
      (element) => element.value == value,
      orElse: () => PuestoEmpleado.tecnico,
    );
  }

  String get displayName {
    switch (this) {
      case PuestoEmpleado.tecnico:
        return 'Técnico';
      case PuestoEmpleado.recepcion:
        return 'Recepción';
      case PuestoEmpleado.gerente:
        return 'Gerente';
    }
  }
}

enum TipoTurnoEmpleado {
  normal('normal'),
  extra('extra'),
  guardia('guardia');

  const TipoTurnoEmpleado(this.value);
  final String value;

  static TipoTurnoEmpleado fromString(String value) {
    return TipoTurnoEmpleado.values.firstWhere(
      (element) => element.value == value,
      orElse: () => TipoTurnoEmpleado.normal,
    );
  }

  String get displayName {
    switch (this) {
      case TipoTurnoEmpleado.normal:
        return 'Normal';
      case TipoTurnoEmpleado.extra:
        return 'Extra';
      case TipoTurnoEmpleado.guardia:
        return 'Guardia';
    }
  }
}

class EmpleadoGrid {
  final String empleadoId;
  final String empleadoNombre;
  final PuestoEmpleado puesto;
  final bool activo;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final String? imagenId;
  final String sucursalId;
  final String sucursalNombre;
  final bool enTurnoNow;
  final DateTime? turnoInicio;
  final DateTime? turnoFin;
  final int minutosHoy;
  final int ordenesAbiertas;

  const EmpleadoGrid({
    required this.empleadoId,
    required this.empleadoNombre,
    required this.puesto,
    required this.activo,
    this.correo,
    this.telefono,
    this.direccion,
    this.imagenId,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.enTurnoNow,
    this.turnoInicio,
    this.turnoFin,
    required this.minutosHoy,
    required this.ordenesAbiertas,
  });

  factory EmpleadoGrid.fromJson(Map<String, dynamic> json) {
    return EmpleadoGrid(
      empleadoId: json['empleado_id'] as String,
      empleadoNombre: json['empleado_nombre'] as String,
      puesto: PuestoEmpleado.fromString(json['puesto'] as String),
      activo: json['activo'] as bool,
      correo: json['correo'] as String?,
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
      imagenId: json['imagen_id'] as String?,
      sucursalId: json['sucursal_id'] as String,
      sucursalNombre: json['sucursal_nombre'] as String,
      enTurnoNow: json['en_turno_now'] as bool,
      turnoInicio: json['turno_inicio'] != null
          ? DateTime.parse(json['turno_inicio'] as String)
          : null,
      turnoFin: json['turno_fin'] != null
          ? DateTime.parse(json['turno_fin'] as String)
          : null,
      minutosHoy: json['minutos_hoy'] as int,
      ordenesAbiertas: json['ordenes_abiertas'] as int,
    );
  }

  String get turnoTexto {
    if (!enTurnoNow || turnoInicio == null || turnoFin == null) {
      return 'Sin turno';
    }

    final inicioStr =
        '${turnoInicio!.hour.toString().padLeft(2, '0')}:${turnoInicio!.minute.toString().padLeft(2, '0')}';
    final finStr =
        '${turnoFin!.hour.toString().padLeft(2, '0')}:${turnoFin!.minute.toString().padLeft(2, '0')}';

    return '$inicioStr - $finStr';
  }

  String get horasHoyTexto {
    if (minutosHoy == 0) return '0 hrs';

    final horas = minutosHoy ~/ 60;
    final minutos = minutosHoy % 60;

    if (horas == 0) {
      return '${minutos}min';
    } else if (minutos == 0) {
      return '${horas}h';
    } else {
      return '${horas}h ${minutos}m';
    }
  }
}

class TurnoEmpleado {
  final String id;
  final String empleadoId;
  final String sucursalId;
  final DateTime inicio;
  final DateTime fin;
  final TipoTurnoEmpleado tipo;

  const TurnoEmpleado({
    required this.id,
    required this.empleadoId,
    required this.sucursalId,
    required this.inicio,
    required this.fin,
    required this.tipo,
  });

  factory TurnoEmpleado.fromJson(Map<String, dynamic> json) {
    return TurnoEmpleado(
      id: json['id'] as String,
      empleadoId: json['empleado_id'] as String,
      sucursalId: json['sucursal_id'] as String,
      inicio: DateTime.parse(json['inicio'] as String),
      fin: DateTime.parse(json['fin'] as String),
      tipo: TipoTurnoEmpleado.fromString(json['tipo'] as String),
    );
  }
}

class NuevoEmpleado {
  final String nombre;
  final String apellido;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final PuestoEmpleado puesto;
  final String? password;

  const NuevoEmpleado({
    required this.nombre,
    required this.apellido,
    this.correo,
    this.telefono,
    this.direccion,
    required this.puesto,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      if (correo != null) 'correo': correo,
      if (telefono != null) 'telefono': telefono,
      if (direccion != null) 'direccion': direccion,
      'puesto': puesto.value,
      if (password != null) 'password': password,
    };
  }
}
