import 'package:pluto_grid/pluto_grid.dart';

/// Modelo para empleados en la vista global desde vw_empleados_grid
class EmpleadoGlobalGrid {
  final String empleadoId;
  final String empleadoNombre;
  final String puesto;
  final bool activo;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final String sucursalId;
  final String sucursalNombre;
  final bool enTurnoNow;
  final DateTime? turnoInicio;
  final DateTime? turnoFin;
  final int minutosHoy;
  final int ordenesAbiertas;
  final String? imagenId;
  final String? imagenPath;

  EmpleadoGlobalGrid({
    required this.empleadoId,
    required this.empleadoNombre,
    required this.puesto,
    required this.activo,
    this.correo,
    this.telefono,
    this.direccion,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.enTurnoNow,
    this.turnoInicio,
    this.turnoFin,
    required this.minutosHoy,
    required this.ordenesAbiertas,
    this.imagenId,
    this.imagenPath,
  });

  factory EmpleadoGlobalGrid.fromMap(Map<String, dynamic> map) {
    return EmpleadoGlobalGrid(
      empleadoId: map['empleado_id'] ?? '',
      empleadoNombre: map['empleado_nombre'] ?? '',
      puesto: map['puesto'] ?? '',
      activo: map['activo'] ?? false,
      correo: map['correo'],
      telefono: map['telefono'],
      direccion: map['direccion'],
      sucursalId: map['sucursal_id'] ?? '',
      sucursalNombre: map['sucursal_nombre'] ?? '',
      enTurnoNow: map['en_turno_now'] ?? false,
      turnoInicio: map['turno_inicio'] != null
          ? DateTime.parse(map['turno_inicio'])
          : null,
      turnoFin:
          map['turno_fin'] != null ? DateTime.parse(map['turno_fin']) : null,
      minutosHoy: map['minutos_hoy'] ?? 0,
      ordenesAbiertas: map['ordenes_abiertas'] ?? 0,
      imagenId: map['imagen_id'],
      imagenPath: map['imagen_path'],
    );
  }

  /// Getter para indicador de estado de turno
  String get estadoTurno {
    if (!activo) return 'Inactivo';
    if (enTurnoNow) return 'En Turno';
    return 'Fuera de Turno';
  }

  /// Getter para color del indicador de turno
  String get colorTurno {
    if (!activo) return 'gris';
    if (enTurnoNow) return 'verde';
    return 'naranja';
  }

  /// Getter para nivel de carga de trabajo
  String get nivelCarga {
    if (ordenesAbiertas == 0) return 'Libre';
    if (ordenesAbiertas <= 2) return 'Baja';
    if (ordenesAbiertas <= 4) return 'Media';
    return 'Alta';
  }

  /// Getter para color de la carga de trabajo
  String get colorCarga {
    if (ordenesAbiertas == 0) return 'verde';
    if (ordenesAbiertas <= 2) return 'azul';
    if (ordenesAbiertas <= 4) return 'naranja';
    return 'rojo';
  }

  /// Getter para horario formateado
  String get horarioTurno {
    if (turnoInicio == null || turnoFin == null) return 'Sin turno';

    final inicio =
        '${turnoInicio!.hour.toString().padLeft(2, '0')}:${turnoInicio!.minute.toString().padLeft(2, '0')}';
    final fin =
        '${turnoFin!.hour.toString().padLeft(2, '0')}:${turnoFin!.minute.toString().padLeft(2, '0')}';

    return '$inicio - $fin';
  }

  /// Getter para descripción de la carga de trabajo
  String get descripcionCarga {
    return '$ordenesAbiertas ${ordenesAbiertas == 1 ? 'orden' : 'órdenes'} ${ordenesAbiertas == 1 ? 'abierta' : 'abiertas'}';
  }

  /// Método para convertir a PlutoRow
  PlutoRow toPlutoRow() {
    return PlutoRow(cells: {
      'numero': PlutoCell(value: ''),
      'empleado': PlutoCell(value: empleadoNombre),
      'puesto': PlutoCell(value: puesto),
      'sucursal': PlutoCell(value: sucursalNombre),
      'turno': PlutoCell(value: estadoTurno),
      'carga': PlutoCell(value: ordenesAbiertas),
      'acciones': PlutoCell(value: empleadoId),
    });
  }

  @override
  String toString() {
    return 'EmpleadoGlobalGrid(id: $empleadoId, nombre: $empleadoNombre, sucursal: $sucursalNombre, turno: $estadoTurno, carga: $ordenesAbiertas)';
  }
}

/// Modelo para roles de empleados
class RolEmpleado {
  final int id;
  final String nombre;
  final String descripcion;

  const RolEmpleado({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  /// Roles disponibles en el sistema (organization_fk = 11)
  static const List<RolEmpleado> rolesDisponibles = [
    RolEmpleado(
      id: 33,
      nombre: 'Técnico',
      descripcion: 'Técnico especializado en servicios automotrices',
    ),
    RolEmpleado(
      id: 34,
      nombre: 'Admin',
      descripcion: 'Administrador del sistema',
    ),
    RolEmpleado(
      id: 36,
      nombre: 'Jefe',
      descripcion: 'Jefe de taller o supervisor',
    ),
  ];

  static RolEmpleado? getRolById(int id) {
    try {
      return rolesDisponibles.firstWhere((rol) => rol.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => nombre;
}

/// Modelo para sucursales disponibles
class SucursalEmpleado {
  final String id;
  final String nombre;
  final String? direccion;

  const SucursalEmpleado({
    required this.id,
    required this.nombre,
    this.direccion,
  });

  factory SucursalEmpleado.fromMap(Map<String, dynamic> map) {
    return SucursalEmpleado(
      id: map['sucursal_id'] ?? '',
      nombre: map['sucursal_nombre'] ?? '',
      direccion: map['direccion'],
    );
  }

  @override
  String toString() => nombre;
}

/// Modelo para filtros de empleados
class FiltrosEmpleados {
  String? sucursalId;
  String? puesto;
  bool? activo;
  bool? enTurno;
  String? estadoTurno;
  String? nivelCarga;
  String searchTerm;

  FiltrosEmpleados({
    this.sucursalId,
    this.puesto,
    this.activo,
    this.enTurno,
    this.estadoTurno,
    this.nivelCarga,
    this.searchTerm = '',
  });

  /// Verificar si un empleado pasa todos los filtros
  bool cumpleFiltros(EmpleadoGlobalGrid empleado) {
    // Filtro por sucursal
    if (sucursalId != null && empleado.sucursalId != sucursalId) {
      return false;
    }

    // Filtro por puesto
    if (puesto != null && empleado.puesto != puesto) {
      return false;
    }

    // Filtro por estado activo
    if (activo != null && empleado.activo != activo) {
      return false;
    }

    // Filtro por turno
    if (enTurno != null && empleado.enTurnoNow != enTurno) {
      return false;
    }

    // Filtro por estado de turno
    if (estadoTurno != null && empleado.estadoTurno != estadoTurno) {
      return false;
    }

    // Filtro por nivel de carga
    if (nivelCarga != null && empleado.nivelCarga != nivelCarga) {
      return false;
    }

    // Filtro por término de búsqueda
    if (searchTerm.isNotEmpty) {
      final searchLower = searchTerm.toLowerCase();
      final nombreMatch =
          empleado.empleadoNombre.toLowerCase().contains(searchLower);
      final sucursalMatch =
          empleado.sucursalNombre.toLowerCase().contains(searchLower);
      final puestoMatch = empleado.puesto.toLowerCase().contains(searchLower);
      final correoMatch =
          empleado.correo?.toLowerCase().contains(searchLower) ?? false;

      if (!nombreMatch && !sucursalMatch && !puestoMatch && !correoMatch) {
        return false;
      }
    }

    return true;
  }

  /// Limpiar todos los filtros
  void limpiar() {
    sucursalId = null;
    puesto = null;
    activo = null;
    enTurno = null;
    estadoTurno = null;
    nivelCarga = null;
    searchTerm = '';
  }

  /// Verificar si hay filtros activos
  bool get tieneFiltrosActivos {
    return sucursalId != null ||
        puesto != null ||
        activo != null ||
        enTurno != null ||
        nivelCarga != null ||
        searchTerm.isNotEmpty;
  }
}
