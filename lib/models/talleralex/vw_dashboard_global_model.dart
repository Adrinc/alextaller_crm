class VwDashboardGlobal {
  final String sucursalId;
  final String sucursalNombre;
  final int totalCitas;
  final int citasHoy;
  final int totalOrdenes;
  final int ordenesAbiertas;
  final int ordenesCerradas;
  final double ingresosTotales;
  final int refaccionesAlerta;
  final int empleadosActivos;

  VwDashboardGlobal({
    required this.sucursalId,
    required this.sucursalNombre,
    required this.totalCitas,
    required this.citasHoy,
    required this.totalOrdenes,
    required this.ordenesAbiertas,
    required this.ordenesCerradas,
    required this.ingresosTotales,
    required this.refaccionesAlerta,
    required this.empleadosActivos,
  });

  factory VwDashboardGlobal.fromJson(Map<String, dynamic> json) {
    return VwDashboardGlobal(
      sucursalId: json['sucursal_id'] as String,
      sucursalNombre: json['sucursal_nombre'] as String,
      totalCitas: json['total_citas'] as int? ?? 0,
      citasHoy: json['citas_hoy'] as int? ?? 0,
      totalOrdenes: json['total_ordenes'] as int? ?? 0,
      ordenesAbiertas: json['ordenes_abiertas'] as int? ?? 0,
      ordenesCerradas: json['ordenes_cerradas'] as int? ?? 0,
      ingresosTotales: (json['ingresos_totales'] as num?)?.toDouble() ?? 0.0,
      refaccionesAlerta: json['refacciones_alerta'] as int? ?? 0,
      empleadosActivos: json['empleados_activos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucursal_id': sucursalId,
      'sucursal_nombre': sucursalNombre,
      'total_citas': totalCitas,
      'citas_hoy': citasHoy,
      'total_ordenes': totalOrdenes,
      'ordenes_abiertas': ordenesAbiertas,
      'ordenes_cerradas': ordenesCerradas,
      'ingresos_totales': ingresosTotales,
      'refacciones_alerta': refaccionesAlerta,
      'empleados_activos': empleadosActivos,
    };
  }

  @override
  String toString() {
    return 'VwDashboardGlobal(sucursalId: $sucursalId, sucursalNombre: $sucursalNombre, citasHoy: $citasHoy, ingresosTotales: $ingresosTotales)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VwDashboardGlobal && other.sucursalId == sucursalId;
  }

  @override
  int get hashCode => sucursalId.hashCode;
}
