import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/vw_dashboard_global_model.dart';

class DashboardGlobalProvider extends ChangeNotifier {
  List<VwDashboardGlobal> _dashboardData = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<VwDashboardGlobal> get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Métricas agregadas globales
  int get totalCitasGlobal =>
      _dashboardData.fold(0, (sum, item) => sum + item.totalCitas);
  int get citasHoyGlobal =>
      _dashboardData.fold(0, (sum, item) => sum + item.citasHoy);
  int get totalOrdenesGlobal =>
      _dashboardData.fold(0, (sum, item) => sum + item.totalOrdenes);
  int get ordenesAbiertasGlobal =>
      _dashboardData.fold(0, (sum, item) => sum + item.ordenesAbiertas);
  int get ordenesCerradasGlobal =>
      _dashboardData.fold(0, (sum, item) => sum + item.ordenesCerradas);
  double get ingresosTotalesGlobal =>
      _dashboardData.fold(0.0, (sum, item) => sum + item.ingresosTotales);
  int get refaccionesAlertaGlobal =>
      _dashboardData.fold(0, (sum, item) => sum + item.refaccionesAlerta);
  int get empleadosActivosGlobal =>
      _dashboardData.fold(0, (sum, item) => sum + item.empleadosActivos);
  int get totalSucursalesActivas => _dashboardData.length;

  // Métricas calculadas
  double get promedioIngresosXSucursal => totalSucursalesActivas > 0
      ? ingresosTotalesGlobal / totalSucursalesActivas
      : 0.0;
  double get promedioEmpleadosXSucursal => totalSucursalesActivas > 0
      ? empleadosActivosGlobal / totalSucursalesActivas
      : 0.0;
  double get tasaOrdenesCerradas => totalOrdenesGlobal > 0
      ? (ordenesCerradasGlobal / totalOrdenesGlobal) * 100
      : 0.0;

  DashboardGlobalProvider() {
    cargarDashboardGlobal();
  }

  // Cargar datos del dashboard global
  Future<void> cargarDashboardGlobal() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await supabaseLU
          .from('vw_dashboard_global')
          .select('*')
          .order('sucursal_nombre');

      _dashboardData = (response as List)
          .map((item) => VwDashboardGlobal.fromJson(item))
          .toList();

      log('✅ Dashboard global cargado: ${_dashboardData.length} sucursales');
    } catch (e) {
      _error = 'Error al cargar dashboard global: $e';
      log('❌ Error cargando dashboard global: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener datos de una sucursal específica
  VwDashboardGlobal? obtenerDatosSucursal(String sucursalId) {
    try {
      return _dashboardData.firstWhere((item) => item.sucursalId == sucursalId);
    } catch (e) {
      return null;
    }
  }

  // Obtener top sucursales por criterio
  List<VwDashboardGlobal> getTopSucursales({
    required String criterio,
    int limite = 5,
  }) {
    List<VwDashboardGlobal> sorted = List.from(_dashboardData);

    switch (criterio) {
      case 'ingresos':
        sorted.sort((a, b) => b.ingresosTotales.compareTo(a.ingresosTotales));
        break;
      case 'citas':
        sorted.sort((a, b) => b.citasHoy.compareTo(a.citasHoy));
        break;
      case 'ordenes':
        sorted.sort((a, b) => b.ordenesAbiertas.compareTo(a.ordenesAbiertas));
        break;
      case 'empleados':
        sorted.sort((a, b) => b.empleadosActivos.compareTo(a.empleadosActivos));
        break;
      default:
        sorted.sort((a, b) => b.ingresosTotales.compareTo(a.ingresosTotales));
    }

    return sorted.take(limite).toList();
  }

  // Recargar datos
  Future<void> refrescar() async {
    await cargarDashboardGlobal();
  }
}
