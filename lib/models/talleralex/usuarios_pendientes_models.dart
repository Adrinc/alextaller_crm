/// Modelo para la vista vw_usuarios_pendientes
/// Representa usuarios en estado pendiente de aprobación
class UsuarioPendienteGrid {
  final String usuarioId;
  final String nombre;
  final String? apellido;
  final String? telefono;
  final String estado;
  final DateTime fechaRegistro;
  final int diasEsperando;
  final int? organizationFk;
  final int? roleFk;
  final String? rolNombre;

  UsuarioPendienteGrid({
    required this.usuarioId,
    required this.nombre,
    this.apellido,
    this.telefono,
    required this.estado,
    required this.fechaRegistro,
    required this.diasEsperando,
    this.organizationFk,
    this.roleFk,
    this.rolNombre,
  });

  factory UsuarioPendienteGrid.fromJson(Map<String, dynamic> json) {
    return UsuarioPendienteGrid(
      usuarioId: json['usuario_id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString(),
      telefono: json['telefono']?.toString(),
      estado: json['estado']?.toString() ?? 'pendiente',
      fechaRegistro:
          DateTime.tryParse(json['fecha_registro']?.toString() ?? '') ??
              DateTime.now(),
      diasEsperando:
          int.tryParse(json['dias_esperando']?.toString() ?? '0') ?? 0,
      organizationFk: json['organization_fk'] != null
          ? int.tryParse(json['organization_fk'].toString())
          : null,
      roleFk: json['role_fk'] != null
          ? int.tryParse(json['role_fk'].toString())
          : null,
      rolNombre: json['rol_nombre']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'estado': estado,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'dias_esperando': diasEsperando,
      'organization_fk': organizationFk,
      'role_fk': roleFk,
      'rol_nombre': rolNombre,
    };
  }

  /// Nombre completo del usuario
  String get nombreCompleto {
    if (apellido != null && apellido!.isNotEmpty) {
      return '$nombre $apellido';
    }
    return nombre;
  }

  /// Descripción del tiempo esperando
  String get tiempoEsperandoTexto {
    if (diasEsperando == 0) {
      return 'Hoy';
    } else if (diasEsperando == 1) {
      return '1 día';
    } else {
      return '$diasEsperando días';
    }
  }

  /// Estado con color para UI
  String get estadoTexto {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'aprobado':
        return 'Aprobado';
      case 'rechazado':
        return 'Rechazado';
      default:
        return estado;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioPendienteGrid &&
          runtimeType == other.runtimeType &&
          usuarioId == other.usuarioId;

  @override
  int get hashCode => usuarioId.hashCode;

  @override
  String toString() {
    return 'UsuarioPendienteGrid{usuarioId: $usuarioId, nombre: $nombreCompleto, estado: $estado, diasEsperando: $diasEsperando}';
  }
}

/// Roles disponibles para aprobación
class RolAprobacion {
  final int id;
  final String nombre;
  final String descripcion;

  const RolAprobacion({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  /// Roles predefinidos para Taller Alex (organization_fk = 11)
  static const List<RolAprobacion> rolesDisponibles = [
    RolAprobacion(
        id: 33, nombre: 'Técnico', descripcion: 'Personal técnico operativo'),
    RolAprobacion(
        id: 34, nombre: 'Admin', descripcion: 'Administrador de sucursal'),
    RolAprobacion(id: 35, nombre: 'Cliente', descripcion: 'Cliente del taller'),
    RolAprobacion(id: 36, nombre: 'Jefe', descripcion: 'Jefe de sucursal'),
  ];

  static RolAprobacion? getRolById(int id) {
    try {
      return rolesDisponibles.firstWhere((rol) => rol.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => nombre;
}
