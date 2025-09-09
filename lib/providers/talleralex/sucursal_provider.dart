import 'package:flutter/foundation.dart';
import 'package:nethive_neo/models/talleralex/sucursal_model.dart';

class SucursalProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Sucursal? _sucursalActual;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Sucursal? get sucursalActual => _sucursalActual;

  Future<void> cargarSucursal(String sucursalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulamos carga de datos - aquí conectarías con Supabase
      await Future.delayed(const Duration(milliseconds: 800));

      // Datos de ejemplo basados en la tabla sucursales
      _sucursalActual = Sucursal(
        id: sucursalId,
        nombre: _getNombreSucursal(sucursalId),
        telefono: '+52 55 1234 5678',
        emailContacto: 'contacto@talleralex.com',
        direccion: 'Av. Principal 123, Col. Centro, Ciudad de México',
        lat: 19.4326,
        lng: -99.1332,
        capacidadBahias: 8,
        imagenUrl: _getImagenSucursal(sucursalId),
        activa: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar la sucursal: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getNombreSucursal(String id) {
    // Mapeo de IDs a nombres para demo
    final nombres = {
      '1': 'Taller Alex Centro',
      '2': 'Taller Alex Norte',
      '3': 'Taller Alex Sur',
      '4': 'Taller Alex Oriente',
    };
    return nombres[id] ?? 'Sucursal $id';
  }

  String? _getImagenSucursal(String id) {
    // En producción esto vendría de la base de datos
    // Por ahora retornamos null para mostrar el ícono por defecto
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
