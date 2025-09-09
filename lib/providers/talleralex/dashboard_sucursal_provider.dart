import 'dart:developer';
import 'package:flutter/foundation.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/dashboard_sucursal_model.dart';

class DashboardSucursalProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  DashboardSucursal? _dashboardData;
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  DashboardSucursal? get dashboardData => _dashboardData;
  DateTime get fechaInicio => _fechaInicio;
  DateTime get fechaFin => _fechaFin;

  // Cargar datos del dashboard usando la función RPC
  Future<void> cargarDashboard(String sucursalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Cargando dashboard para sucursal: $sucursalId');

      final response = await supabaseLU.rpc('get_dashboard_sucursal', params: {
        'p_sucursal_id': sucursalId,
        'p_inicio': _fechaInicio.toIso8601String().split('T')[0], // YYYY-MM-DD
        'p_fin': _fechaFin.toIso8601String().split('T')[0], // YYYY-MM-DD
      });

      if (response != null && response.isNotEmpty) {
        _dashboardData = DashboardSucursal.fromJson(response[0]);
        log('✅ Dashboard cargado: ${_dashboardData?.sucursalNombre}');
      } else {
        _error = 'No se encontraron datos para la sucursal';
        log('⚠️ No hay datos de dashboard para sucursal: $sucursalId');
      }
    } catch (e) {
      _error = 'Error al cargar dashboard: $e';
      log('❌ Error cargando dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cambiar rango de fechas
  Future<void> cambiarRangoFechas(
      DateTime inicio, DateTime fin, String sucursalId) async {
    _fechaInicio = inicio;
    _fechaFin = fin;
    await cargarDashboard(sucursalId);
  }

  // Filtros preestablecidos
  Future<void> filtrarHoy(String sucursalId) async {
    final hoy = DateTime.now();
    await cambiarRangoFechas(hoy, hoy, sucursalId);
  }

  Future<void> filtrarSemana(String sucursalId) async {
    final hoy = DateTime.now();
    final inicioSemana = hoy.subtract(Duration(days: hoy.weekday - 1));
    final finSemana = inicioSemana.add(const Duration(days: 6));
    await cambiarRangoFechas(inicioSemana, finSemana, sucursalId);
  }

  Future<void> filtrarMes(String sucursalId) async {
    final hoy = DateTime.now();
    final inicioMes = DateTime(hoy.year, hoy.month, 1);
    final finMes = DateTime(hoy.year, hoy.month + 1, 0);
    await cambiarRangoFechas(inicioMes, finMes, sucursalId);
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset del provider
  void reset() {
    _dashboardData = null;
    _error = null;
    _isLoading = false;
    _fechaInicio = DateTime.now();
    _fechaFin = DateTime.now();
    notifyListeners();
  }
}
