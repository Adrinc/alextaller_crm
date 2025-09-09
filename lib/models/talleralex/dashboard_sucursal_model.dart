class DashboardSucursal {
  final String sucursalId;
  final String sucursalNombre;
  final int citasTotal;
  final int citasPendientes;
  final int citasNoAsistio;
  final int ordenesAbiertas;
  final int ordenesCerradas;
  final double ingresosTotal;
  final int bahiasTotales;
  final int bahiasOcupadas;
  final int refaccionesAlerta;

  DashboardSucursal({
    required this.sucursalId,
    required this.sucursalNombre,
    required this.citasTotal,
    required this.citasPendientes,
    required this.citasNoAsistio,
    required this.ordenesAbiertas,
    required this.ordenesCerradas,
    required this.ingresosTotal,
    required this.bahiasTotales,
    required this.bahiasOcupadas,
    required this.refaccionesAlerta,
  });

  factory DashboardSucursal.fromJson(Map<String, dynamic> json) {
    return DashboardSucursal(
      sucursalId: json['sucursal_id']?.toString() ?? '',
      sucursalNombre: json['sucursal_nombre']?.toString() ?? '',
      citasTotal: json['citas_total'] ?? 0,
      citasPendientes: json['citas_pendientes'] ?? 0,
      citasNoAsistio: json['citas_no_asistio'] ?? 0,
      ordenesAbiertas: json['ordenes_abiertas'] ?? 0,
      ordenesCerradas: json['ordenes_cerradas'] ?? 0,
      ingresosTotal: (json['ingresos_total'] ?? 0).toDouble(),
      bahiasTotales: json['bahias_totales'] ?? 0,
      bahiasOcupadas: json['bahias_ocupadas'] ?? 0,
      refaccionesAlerta: json['refacciones_alerta'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucursal_id': sucursalId,
      'sucursal_nombre': sucursalNombre,
      'citas_total': citasTotal,
      'citas_pendientes': citasPendientes,
      'citas_no_asistio': citasNoAsistio,
      'ordenes_abiertas': ordenesAbiertas,
      'ordenes_cerradas': ordenesCerradas,
      'ingresos_total': ingresosTotal,
      'bahias_totales': bahiasTotales,
      'bahias_ocupadas': bahiasOcupadas,
      'refacciones_alerta': refaccionesAlerta,
    };
  }

  // Métodos de utilidad
  double get porcentajeOcupacionBahias {
    if (bahiasTotales == 0) return 0.0;
    return (bahiasOcupadas / bahiasTotales) * 100;
  }

  int get citasCompletadas {
    return citasTotal - citasPendientes - citasNoAsistio;
  }

  double get tasaAsistencia {
    if (citasTotal == 0) return 0.0;
    return ((citasTotal - citasNoAsistio) / citasTotal) * 100;
  }

  String get ingresosFormateados {
    return '\$${ingresosTotal.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }
}
