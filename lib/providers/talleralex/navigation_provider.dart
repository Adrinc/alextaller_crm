import 'package:flutter/material.dart';
import 'package:nethive_neo/models/talleralex/sucursal_model.dart';

enum TallerAlexModulo {
  dashboard,
  sucursales,
  agenda,
  empleados,
  clientes,
  citas,
  inventario,
  pagos,
  promociones,
  reportes,
  configuracion
}

class TallerAlexNavigationProvider extends ChangeNotifier {
  TallerAlexModulo _moduloActual = TallerAlexModulo.dashboard;
  Sucursal? _sucursalActual;
  String? _sucursalSeleccionadaId; // Para el sidebar
  bool _verMapaSucursales = true; // true = mapa, false = tabla
  String _breadcrumbPath = 'Dashboard Global';

  // Getters
  TallerAlexModulo get moduloActual => _moduloActual;
  Sucursal? get sucursalActual => _sucursalActual;
  String? get sucursalSeleccionadaId => _sucursalSeleccionadaId;
  bool get verMapaSucursales => _verMapaSucursales;
  String get breadcrumbPath => _breadcrumbPath;

  // Estado de navegación
  bool get estoyEnSucursalEspecifica => _sucursalActual != null;
  bool get estoyEnDashboardGlobal =>
      _moduloActual == TallerAlexModulo.dashboard && _sucursalActual == null;
  bool get estoyEnSelectorSucursales =>
      _moduloActual == TallerAlexModulo.sucursales && _sucursalActual == null;

  // Navegar al dashboard global
  void irADashboardGlobal() {
    _moduloActual = TallerAlexModulo.dashboard;
    _sucursalActual = null;
    _breadcrumbPath = 'Dashboard Global';
    notifyListeners();
  }

  // Navegar al selector de sucursales
  void irASelectorSucursales() {
    _moduloActual = TallerAlexModulo.sucursales;
    _sucursalActual = null;
    _breadcrumbPath = 'Sucursales';
    notifyListeners();
  }

  // Entrar a una sucursal específica
  void entrarEnSucursal(Sucursal sucursal,
      {TallerAlexModulo modulo = TallerAlexModulo.dashboard}) {
    _sucursalActual = sucursal;
    _moduloActual = modulo;
    _actualizarBreadcrumb();
    notifyListeners();
  }

  // Cambiar módulo dentro de una sucursal
  void cambiarModulo(TallerAlexModulo modulo) {
    _moduloActual = modulo;
    _actualizarBreadcrumb();
    notifyListeners();
  }

  // Alternar vista de sucursales (mapa/tabla)
  void alternarVistaSucursales() {
    _verMapaSucursales = !_verMapaSucursales;
    notifyListeners();
  }

  // Salir de sucursal
  void salirDeSucursal() {
    _sucursalActual = null;
    _moduloActual = TallerAlexModulo.sucursales;
    _breadcrumbPath = 'Sucursales';
    notifyListeners();
  }

  // Actualizar breadcrumb basado en estado actual
  void _actualizarBreadcrumb() {
    if (_sucursalActual == null) {
      switch (_moduloActual) {
        case TallerAlexModulo.dashboard:
          _breadcrumbPath = 'Dashboard Global';
          break;
        case TallerAlexModulo.sucursales:
          _breadcrumbPath = 'Sucursales';
          break;
        default:
          _breadcrumbPath = 'Taller Alex';
      }
    } else {
      String moduloNombre = getNombreModulo(_moduloActual);
      _breadcrumbPath =
          'Sucursales > ${_sucursalActual!.nombre} > $moduloNombre';
    }
  }

  // Obtener nombre amigable del módulo
  String getNombreModulo(TallerAlexModulo modulo) {
    switch (modulo) {
      case TallerAlexModulo.dashboard:
        return 'Dashboard';
      case TallerAlexModulo.sucursales:
        return 'Sucursales';
      case TallerAlexModulo.agenda:
        return 'Agenda';
      case TallerAlexModulo.empleados:
        return 'Empleados';
      case TallerAlexModulo.clientes:
        return 'Clientes';
      case TallerAlexModulo.citas:
        return 'Citas y Órdenes';
      case TallerAlexModulo.inventario:
        return 'Inventario';
      case TallerAlexModulo.pagos:
        return 'Pagos';
      case TallerAlexModulo.promociones:
        return 'Promociones';
      case TallerAlexModulo.reportes:
        return 'Reportes';
      case TallerAlexModulo.configuracion:
        return 'Configuración';
    }
  }

  // Obtener íconos para cada módulo
  IconData getIconoModulo(TallerAlexModulo modulo) {
    switch (modulo) {
      case TallerAlexModulo.dashboard:
        return Icons.dashboard;
      case TallerAlexModulo.sucursales:
        return Icons.store;
      case TallerAlexModulo.agenda:
        return Icons.calendar_today;
      case TallerAlexModulo.empleados:
        return Icons.people;
      case TallerAlexModulo.clientes:
        return Icons.person;
      case TallerAlexModulo.citas:
        return Icons.build;
      case TallerAlexModulo.inventario:
        return Icons.inventory;
      case TallerAlexModulo.pagos:
        return Icons.payment;
      case TallerAlexModulo.promociones:
        return Icons.local_offer;
      case TallerAlexModulo.reportes:
        return Icons.analytics;
      case TallerAlexModulo.configuracion:
        return Icons.settings;
    }
  }

  // Obtener lista de módulos disponibles para sucursal
  List<TallerAlexModulo> get modulosSucursal => [
        TallerAlexModulo.dashboard,
        TallerAlexModulo.agenda,
        TallerAlexModulo.empleados,
        TallerAlexModulo.clientes,
        TallerAlexModulo.citas,
        TallerAlexModulo.inventario,
        TallerAlexModulo.pagos,
        TallerAlexModulo.promociones,
        TallerAlexModulo.reportes,
        TallerAlexModulo.configuracion,
      ];

  // Métodos para selección de sucursal en sidebar
  void setSucursalSeleccionada(String sucursalId) {
    _sucursalSeleccionadaId = sucursalId;
    notifyListeners();
  }

  void clearSucursalSeleccionada() {
    _sucursalSeleccionadaId = null;
    notifyListeners();
  }
}
