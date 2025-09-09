import 'dart:developer';
import 'package:flutter/foundation.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/bahias_models.dart';

class AgendaBahiasProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isReservando = false;
  String? _error;
  List<ReservaBahia> _reservas = [];
  List<OcupacionBahia> _ocupaciones = [];
  AgendaBahiasMetricas? _metricas;
  DateTime _fechaSeleccionada = DateTime.now();
  String _filtroEstado = 'todos';
  String _filtroTecnico = 'todos';

  // Getters
  bool get isLoading => _isLoading;
  bool get isReservando => _isReservando;
  String? get error => _error;
  List<ReservaBahia> get reservas => _reservas;
  List<OcupacionBahia> get ocupaciones => _ocupaciones;
  AgendaBahiasMetricas? get metricas => _metricas;
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  String get filtroEstado => _filtroEstado;
  String get filtroTecnico => _filtroTecnico;

  // Getters calculados
  List<ReservaBahia> get reservasHoy {
    return _reservas.where((r) => r.esHoy).toList();
  }

  List<ReservaBahia> get reservasActivas {
    return _reservas.where((r) => r.estaActiva).toList();
  }

  List<OcupacionBahia> get ocupacionesFiltradas {
    return _aplicarFiltros(_ocupaciones);
  }

  // Cargar reservas de bahías
  Future<void> cargarReservas(String sucursalId, {DateTime? fecha}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Cargando reservas de bahías para sucursal: $sucursalId');

      final fechaConsulta = fecha ?? _fechaSeleccionada;
      final fechaInicio =
          DateTime(fechaConsulta.year, fechaConsulta.month, fechaConsulta.day);
      final fechaFin = fechaInicio.add(const Duration(days: 1));

      // Cargar reservas usando la vista vw_reservas_bahias
      dynamic responseReservas;
      try {
        responseReservas = await supabaseLU
            .from('vw_reservas_bahias')
            .select()
            .gte('inicio', fechaInicio.toIso8601String())
            .lt('inicio', fechaFin.toIso8601String())
            .order('inicio');
      } catch (e) {
        log('⚠️ Error consultando vw_reservas_bahias: $e');
        responseReservas = null;
      }

      // Cargar ocupación de bahías usando la vista vw_ocupacion_bahias_hoy
      dynamic responseOcupacion;
      try {
        responseOcupacion = await supabaseLU
            .from('vw_ocupacion_bahias_hoy')
            .select()
            .eq('sucursal_id', sucursalId);
      } catch (e) {
        log('⚠️ Error consultando vw_ocupacion_bahias_hoy: $e');
        responseOcupacion = null;
      }

      if (responseReservas != null && responseReservas is List) {
        try {
          _reservas = responseReservas
              .map(
                  (json) => ReservaBahia.fromJson(json as Map<String, dynamic>))
              .toList();
          log('✅ Reservas cargadas: ${_reservas.length}');
        } catch (e) {
          log('❌ Error parseando reservas: $e');
          _reservas = [];
        }
      } else {
        _reservas = [];
        log('⚠️ No se encontraron reservas');
      }

      if (responseOcupacion != null && responseOcupacion is List) {
        try {
          _ocupaciones = responseOcupacion
              .map((json) =>
                  OcupacionBahia.fromJson(json as Map<String, dynamic>))
              .toList();
          log('✅ Ocupaciones cargadas: ${_ocupaciones.length}');
        } catch (e) {
          log('❌ Error parseando ocupaciones: $e');
          _ocupaciones = [];
        }
      } else {
        _ocupaciones = [];
        log('⚠️ No se encontraron ocupaciones');
      }

      // Calcular métricas
      _calcularMetricas();
    } catch (e) {
      _error = 'Error al cargar reservas de bahías: $e';
      log('❌ Error cargando reservas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reservar bahía usando la función RPC
  Future<bool> reservarBahia(ReservaBahiaRequest request) async {
    if (!request.esValida) {
      _error = 'Datos de reserva inválidos';
      notifyListeners();
      return false;
    }

    _isReservando = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Reservando bahía: ${request.bahiaId} para cita: ${request.citaId}');

      final response =
          await supabaseLU.rpc('reservar_bahia', params: request.toJson());

      if (response != null) {
        log('✅ Bahía reservada exitosamente. ID: $response');

        // Recargar datos después de la reserva
        // Nota: Necesitaríamos el sucursalId, lo podrías pasar como parámetro
        // await cargarReservas(sucursalId);

        return true;
      } else {
        _error = 'No se pudo crear la reserva';
        return false;
      }
    } catch (e) {
      _error = 'Error al reservar bahía: $e';
      log('❌ Error reservando bahía: $e');
      return false;
    } finally {
      _isReservando = false;
      notifyListeners();
    }
  }

  // Cambiar fecha seleccionada
  void cambiarFecha(DateTime nuevaFecha) {
    if (_fechaSeleccionada != nuevaFecha) {
      _fechaSeleccionada = nuevaFecha;
      notifyListeners();
    }
  }

  // Aplicar filtros
  void aplicarFiltroEstado(String estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  void aplicarFiltroTecnico(String tecnico) {
    _filtroTecnico = tecnico;
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtroEstado = 'todos';
    _filtroTecnico = 'todos';
    notifyListeners();
  }

  // Métodos de utilidad
  List<ReservaBahia> getReservasPorBahia(String bahiaId) {
    return _reservas.where((r) => r.bahiaId == bahiaId).toList();
  }

  OcupacionBahia? getOcupacionBahia(String bahiaId) {
    try {
      return _ocupaciones.firstWhere((o) => o.bahiaId == bahiaId);
    } catch (e) {
      return null;
    }
  }

  bool hayConflictoHorario(String bahiaId, DateTime inicio, DateTime fin) {
    final reservasBahia = getReservasPorBahia(bahiaId);

    return reservasBahia.any((reserva) {
      return (inicio.isBefore(reserva.fin) && fin.isAfter(reserva.inicio));
    });
  }

  List<DateTime> getHorariosDisponibles(
      String bahiaId, Duration duracionServicio) {
    final ocupacion = getOcupacionBahia(bahiaId);
    if (ocupacion == null) return [];

    // Lógica para calcular horarios disponibles
    // (Esta es una implementación básica, se puede mejorar)
    final List<DateTime> horariosDisponibles = [];
    final inicioJornada = DateTime(_fechaSeleccionada.year,
        _fechaSeleccionada.month, _fechaSeleccionada.day, 8, 0);
    final finJornada = DateTime(_fechaSeleccionada.year,
        _fechaSeleccionada.month, _fechaSeleccionada.day, 18, 0);

    DateTime horaActual = inicioJornada;
    while (horaActual.add(duracionServicio).isBefore(finJornada) ||
        horaActual.add(duracionServicio).isAtSameMomentAs(finJornada)) {
      if (!hayConflictoHorario(
          bahiaId, horaActual, horaActual.add(duracionServicio))) {
        horariosDisponibles.add(horaActual);
      }
      horaActual = horaActual
          .add(const Duration(minutes: 30)); // Intervalos de 30 minutos
    }

    return horariosDisponibles;
  }

  // Métodos privados
  void _calcularMetricas() {
    _metricas = AgendaBahiasMetricas.calcular(_ocupaciones);
  }

  List<OcupacionBahia> _aplicarFiltros(List<OcupacionBahia> ocupaciones) {
    List<OcupacionBahia> filtradas = List.from(ocupaciones);

    // Filtro por estado
    if (_filtroEstado != 'todos') {
      switch (_filtroEstado) {
        case 'libre':
          filtradas =
              filtradas.where((o) => o.estado == EstadoBahia.libre).toList();
          break;
        case 'ocupada':
          filtradas =
              filtradas.where((o) => o.estado != EstadoBahia.libre).toList();
          break;
        case 'completa':
          filtradas =
              filtradas.where((o) => o.estado == EstadoBahia.completa).toList();
          break;
      }
    }

    return filtradas;
  }

  // Limpiar datos
  void limpiar() {
    _reservas.clear();
    _ocupaciones.clear();
    _metricas = null;
    _error = null;
    _isLoading = false;
    _isReservando = false;
    notifyListeners();
  }

  // Navegación temporal (para vista calendario)
  void irDiaAnterior() {
    cambiarFecha(_fechaSeleccionada.subtract(const Duration(days: 1)));
  }

  void irDiaSiguiente() {
    cambiarFecha(_fechaSeleccionada.add(const Duration(days: 1)));
  }

  void irSemanaAnterior() {
    cambiarFecha(_fechaSeleccionada.subtract(const Duration(days: 7)));
  }

  void irSemanaSiguiente() {
    cambiarFecha(_fechaSeleccionada.add(const Duration(days: 7)));
  }

  void irHoy() {
    cambiarFecha(DateTime.now());
  }

  // Validaciones
  String? validarReserva(ReservaBahiaRequest request) {
    if (!request.esValida) {
      return 'Datos de reserva inválidos';
    }

    if (hayConflictoHorario(request.bahiaId, request.inicio, request.fin)) {
      return 'La bahía ya está ocupada en ese horario';
    }

    // Validar horarios de trabajo (8:00 - 18:00)
    final horaInicio = request.inicio.hour;
    final horaFin = request.fin.hour;

    if (horaInicio < 8 || horaFin > 18) {
      return 'La reserva debe estar dentro del horario de trabajo (8:00 - 18:00)';
    }

    return null; // Sin errores
  }
}
