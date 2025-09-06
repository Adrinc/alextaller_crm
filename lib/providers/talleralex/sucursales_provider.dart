import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/sucursal_model.dart';
import 'package:nethive_neo/models/talleralex/vw_mapa_sucursales_model.dart';

class SucursalesProvider extends ChangeNotifier {
  List<Sucursal> _sucursales = [];
  List<VwMapaSucursales> _sucursalesMapa = [];
  Sucursal? _sucursalSeleccionada;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Sucursal> get sucursales => _sucursales;
  List<VwMapaSucursales> get sucursalesMapa => _sucursalesMapa;
  Sucursal? get sucursalSeleccionada => _sucursalSeleccionada;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar todas las sucursales
  Future<void> cargarSucursales() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response =
          await supabaseLU.from('sucursales').select('*').order('nombre');

      _sucursales = (response as List)
          .map((sucursal) => Sucursal.fromJson(sucursal))
          .toList();

      // Si no hay sucursales, crear datos de prueba
      /*     if (_sucursales.isEmpty) {
        await _crearDatosDePrueba();
      } */

      // Cargar datos del mapa
      await cargarSucursalesMapa();

      log('✅ Sucursales cargadas: ${_sucursales.length}');
    } catch (e) {
      _error = 'Error al cargar sucursales: $e';
      log('❌ Error cargando sucursales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar datos específicos para el mapa
  Future<void> cargarSucursalesMapa() async {
    try {
      final response = await supabaseLU
          .from('vw_mapa_sucursales')
          .select('*')
          .order('sucursal_nombre');

      _sucursalesMapa = (response as List)
          .map((item) => VwMapaSucursales.fromJson(item))
          .toList();

      log('✅ Datos de mapa cargados: ${_sucursalesMapa.length}');
    } catch (e) {
      log('❌ Error cargando datos de mapa: $e');
      // Si falla la vista, usar datos básicos de sucursales
      _sucursalesMapa = _sucursales
          .map((s) => VwMapaSucursales(
                sucursalId: s.id,
                nombre: s.nombre,
                imagenUrl: s.imagenUrl,
                direccion: s.direccion,
                lat: s.lat,
                lng: s.lng,
                empleadosActivos: 0,
                reportesTotales: 0,
                citasHoy: 0,
              ))
          .toList();
    }
  }

  // Crear datos de prueba
/*   Future<void> _crearDatosDePrueba() async {
    try {
      final sucursalesPrueba = [
        {
          'nombre': 'Taller Alex - Centro',
          'telefono': '555-0001',
          'email_contacto': 'centro@talleralex.com',
          'direccion': 'Av. Principal 123, Col. Centro, Ciudad de México',
          'lat': 19.4326,
          'lng': -99.1332,
          'capacidad_bahias': 8,
          'imagen_url': 'sucursales/taller-centro.jpg',
        },
        {
          'nombre': 'Taller Alex - Norte',
          'telefono': '555-0002',
          'email_contacto': 'norte@talleralex.com',
          'direccion': 'Blvd. Norte 456, Col. Industrial, Ciudad de México',
          'lat': 19.5051,
          'lng': -99.1470,
          'capacidad_bahias': 6,
          'imagen_url': 'sucursales/taller-norte.jpg',
        },
        {
          'nombre': 'Taller Alex - Sur',
          'telefono': '555-0003',
          'email_contacto': 'sur@talleralex.com',
          'direccion': 'Calzada del Sur 789, Col. Del Valle, Ciudad de México',
          'lat': 19.3687,
          'lng': -99.1640,
          'capacidad_bahias': 10,
          'imagen_url': 'sucursales/taller-sur.jpg',
        },
        {
          'nombre': 'Taller Alex - Express',
          'telefono': '555-0004',
          'email_contacto': 'express@talleralex.com',
          'direccion': 'Plaza Comercial Express, Local 5, Ciudad de México',
          'lat': 19.4200,
          'lng': -99.1100,
          'capacidad_bahias': 4,
          'imagen_url': 'sucursales/taller-express.jpg',
        },
      ];

      for (final sucursalData in sucursalesPrueba) {
        await supabaseLU.from('sucursales').insert(sucursalData);
      }

      // Recargar las sucursales después de crear los datos de prueba
      final response =
          await supabaseLU.from('sucursales').select('*').order('nombre');

      _sucursales = (response as List)
          .map((sucursal) => Sucursal.fromJson(sucursal))
          .toList();

      log('✅ Datos de prueba creados: ${_sucursales.length} sucursales');
    } catch (e) {
      log('❌ Error creando datos de prueba: $e');
    }
  } */

  // Seleccionar una sucursal
  void seleccionarSucursal(Sucursal sucursal) {
    _sucursalSeleccionada = sucursal;
    log('🏢 Sucursal seleccionada: ${sucursal.nombre}');
    notifyListeners();
  }

  // Limpiar selección
  void limpiarSeleccion() {
    _sucursalSeleccionada = null;
    notifyListeners();
  }

  // Crear nueva sucursal
  Future<bool> crearSucursal(Map<String, dynamic> datos) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response =
          await supabaseLU.from('sucursales').insert(datos).select().single();

      final nuevaSucursal = Sucursal.fromJson(response);
      _sucursales.add(nuevaSucursal);

      log('✅ Sucursal creada: ${nuevaSucursal.nombre}');
      return true;
    } catch (e) {
      _error = 'Error al crear sucursal: $e';
      log('❌ Error creando sucursal: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar sucursal
  Future<bool> actualizarSucursal(String id, Map<String, dynamic> datos) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await supabaseLU.from('sucursales').update(datos).eq('id', id);

      // Actualizar en la lista local
      final index = _sucursales.indexWhere((s) => s.id == id);
      if (index != -1) {
        _sucursales[index] =
            Sucursal.fromJson({..._sucursales[index].toJson(), ...datos});
      }

      log('✅ Sucursal actualizada: $id');
      return true;
    } catch (e) {
      _error = 'Error al actualizar sucursal: $e';
      log('❌ Error actualizando sucursal: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar (desactivar) sucursal
  Future<bool> eliminarSucursal(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await supabaseLU
          .from('sucursales')
          .update({'activa': false}).eq('id', id);

      _sucursales.removeWhere((s) => s.id == id);

      // Si era la sucursal seleccionada, limpiar selección
      if (_sucursalSeleccionada?.id == id) {
        _sucursalSeleccionada = null;
      }

      log('✅ Sucursal eliminada: $id');
      return true;
    } catch (e) {
      _error = 'Error al eliminar sucursal: $e';
      log('❌ Error eliminando sucursal: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
