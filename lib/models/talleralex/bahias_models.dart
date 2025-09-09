class ReservaBahia {
  final String reservaId;
  final String bahiaId;
  final String bahiaNombre;
  final String citaId;
  final DateTime inicio;
  final DateTime fin;
  final String clienteNombre;
  final String vehiculo;
  final String estadoCita;

  ReservaBahia({
    required this.reservaId,
    required this.bahiaId,
    required this.bahiaNombre,
    required this.citaId,
    required this.inicio,
    required this.fin,
    required this.clienteNombre,
    required this.vehiculo,
    required this.estadoCita,
  });

  factory ReservaBahia.fromJson(Map<String, dynamic> json) {
    return ReservaBahia(
      reservaId: json['reserva_id']?.toString() ?? '',
      bahiaId: json['bahia_id']?.toString() ?? '',
      bahiaNombre: json['bahia_nombre']?.toString() ?? '',
      citaId: json['cita_id']?.toString() ?? '',
      inicio:
          DateTime.parse(json['inicio'] ?? DateTime.now().toIso8601String()),
      fin: DateTime.parse(json['fin'] ?? DateTime.now().toIso8601String()),
      clienteNombre: json['cliente_nombre']?.toString() ?? '',
      vehiculo: json['vehiculo']?.toString() ?? '',
      estadoCita: json['estado_cita']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reserva_id': reservaId,
      'bahia_id': bahiaId,
      'bahia_nombre': bahiaNombre,
      'cita_id': citaId,
      'inicio': inicio.toIso8601String(),
      'fin': fin.toIso8601String(),
      'cliente_nombre': clienteNombre,
      'vehiculo': vehiculo,
      'estado_cita': estadoCita,
    };
  }

  // Getters útiles
  Duration get duracion => fin.difference(inicio);

  bool get esHoy {
    final now = DateTime.now();
    return inicio.year == now.year &&
        inicio.month == now.month &&
        inicio.day == now.day;
  }

  bool get estaActiva {
    final now = DateTime.now();
    return now.isAfter(inicio) && now.isBefore(fin);
  }

  String get tiempoFormateado {
    final duracionMinutos = duracion.inMinutes;
    final horas = duracionMinutos ~/ 60;
    final minutos = duracionMinutos % 60;
    return '${horas}h ${minutos}m';
  }

  String get horarioFormateado {
    return '${_formatearHora(inicio)} - ${_formatearHora(fin)}';
  }

  String _formatearHora(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class OcupacionBahia {
  final String bahiaId;
  final String bahiaNombre;
  final String sucursalId;
  final int reservasHoy;
  final int minutosOcupados;
  final int minutosDisponibles;
  final double porcentajeOcupacion;

  OcupacionBahia({
    required this.bahiaId,
    required this.bahiaNombre,
    required this.sucursalId,
    required this.reservasHoy,
    required this.minutosOcupados,
    required this.minutosDisponibles,
    required this.porcentajeOcupacion,
  });

  factory OcupacionBahia.fromJson(Map<String, dynamic> json) {
    return OcupacionBahia(
      bahiaId: json['bahia_id']?.toString() ?? '',
      bahiaNombre: json['bahia_nombre']?.toString() ?? '',
      sucursalId: json['sucursal_id']?.toString() ?? '',
      reservasHoy: json['reservas_hoy'] ?? 0,
      minutosOcupados: json['minutos_ocupados'] ?? 0,
      minutosDisponibles: json['minutos_disponibles'] ?? 0,
      porcentajeOcupacion: (json['porcentaje_ocupacion'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bahia_id': bahiaId,
      'bahia_nombre': bahiaNombre,
      'sucursal_id': sucursalId,
      'reservas_hoy': reservasHoy,
      'minutos_ocupados': minutosOcupados,
      'minutos_disponibles': minutosDisponibles,
      'porcentaje_ocupacion': porcentajeOcupacion,
    };
  }

  // Getters útiles
  int get totalMinutosDia => minutosOcupados + minutosDisponibles;

  String get tiempoOcupado {
    final horas = minutosOcupados ~/ 60;
    final minutos = minutosOcupados % 60;
    return '${horas}h ${minutos}m';
  }

  String get tiempoDisponible {
    final horas = minutosDisponibles ~/ 60;
    final minutos = minutosDisponibles % 60;
    return '${horas}h ${minutos}m';
  }

  EstadoBahia get estado {
    if (porcentajeOcupacion >= 100) return EstadoBahia.completa;
    if (porcentajeOcupacion >= 80) return EstadoBahia.casiCompleta;
    if (porcentajeOcupacion >= 40) return EstadoBahia.ocupada;
    if (porcentajeOcupacion > 0) return EstadoBahia.parcial;
    return EstadoBahia.libre;
  }

  String get estadoTexto {
    switch (estado) {
      case EstadoBahia.libre:
        return 'Libre';
      case EstadoBahia.parcial:
        return 'Parcial';
      case EstadoBahia.ocupada:
        return 'Ocupada';
      case EstadoBahia.casiCompleta:
        return 'Casi Completa';
      case EstadoBahia.completa:
        return 'Completa';
    }
  }
}

enum EstadoBahia {
  libre,
  parcial,
  ocupada,
  casiCompleta,
  completa,
}

class ReservaBahiaRequest {
  final String citaId;
  final String bahiaId;
  final DateTime inicio;
  final DateTime fin;

  ReservaBahiaRequest({
    required this.citaId,
    required this.bahiaId,
    required this.inicio,
    required this.fin,
  });

  Map<String, dynamic> toJson() {
    return {
      'p_cita_id': citaId,
      'p_bahia_id': bahiaId,
      'p_inicio': inicio.toIso8601String(),
      'p_fin': fin.toIso8601String(),
    };
  }

  Duration get duracion => fin.difference(inicio);

  bool get esValida {
    return fin.isAfter(inicio) && citaId.isNotEmpty && bahiaId.isNotEmpty;
  }
}

class AgendaBahiasMetricas {
  final int bahiasTotales;
  final int bahiasOcupadas;
  final int bahiasLibres;
  final double porcentajeOcupacionPromedio;
  final int reservasHoy;
  final int alertasSolapadas;
  final int citasSinBahia;

  AgendaBahiasMetricas({
    required this.bahiasTotales,
    required this.bahiasOcupadas,
    required this.bahiasLibres,
    required this.porcentajeOcupacionPromedio,
    required this.reservasHoy,
    required this.alertasSolapadas,
    required this.citasSinBahia,
  });

  factory AgendaBahiasMetricas.calcular(List<OcupacionBahia> ocupaciones) {
    if (ocupaciones.isEmpty) {
      return AgendaBahiasMetricas(
        bahiasTotales: 0,
        bahiasOcupadas: 0,
        bahiasLibres: 0,
        porcentajeOcupacionPromedio: 0.0,
        reservasHoy: 0,
        alertasSolapadas: 0,
        citasSinBahia: 0,
      );
    }

    final bahiasTotales = ocupaciones.length;
    final bahiasOcupadas = ocupaciones.where((o) => o.reservasHoy > 0).length;
    final bahiasLibres = bahiasTotales - bahiasOcupadas;
    final porcentajePromedio = ocupaciones.fold<double>(
          0.0,
          (sum, o) => sum + o.porcentajeOcupacion,
        ) /
        bahiasTotales;
    final reservasHoy = ocupaciones.fold<int>(
      0,
      (sum, o) => sum + o.reservasHoy,
    );

    return AgendaBahiasMetricas(
      bahiasTotales: bahiasTotales,
      bahiasOcupadas: bahiasOcupadas,
      bahiasLibres: bahiasLibres,
      porcentajeOcupacionPromedio: porcentajePromedio,
      reservasHoy: reservasHoy,
      alertasSolapadas: 0, // Se calculará con validaciones específicas
      citasSinBahia: 0, // Se calculará con datos de citas
    );
  }
}
