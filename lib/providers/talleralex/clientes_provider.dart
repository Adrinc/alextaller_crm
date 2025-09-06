import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/cliente_model.dart';
import 'package:nethive_neo/models/talleralex/vehiculo_model.dart';

class ClientesProvider extends ChangeNotifier {
  List<Cliente> _clientes = [];
  List<Vehiculo> _vehiculos = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Cliente> get clientes => _clientes;
  List<Vehiculo> get vehiculos => _vehiculos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar clientes
  Future<void> cargarClientes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response =
          await supabaseLU.from('clientes').select('*').order('nombre');

      _clientes = (response as List)
          .map((cliente) => Cliente.fromJson(cliente))
          .toList();

      log('✅ Clientes cargados: ${_clientes.length}');
    } catch (e) {
      _error = 'Error al cargar clientes: $e';
      log('❌ Error cargando clientes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar vehículos de un cliente
  Future<void> cargarVehiculos(String clienteId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await supabaseLU
          .from('vehiculos')
          .select('*')
          .eq('cliente_id', clienteId)
          .order('placa');

      _vehiculos = (response as List)
          .map((vehiculo) => Vehiculo.fromJson(vehiculo))
          .toList();

      log('✅ Vehículos cargados: ${_vehiculos.length}');
    } catch (e) {
      _error = 'Error al cargar vehículos: $e';
      log('❌ Error cargando vehículos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear cliente
  Future<bool> crearCliente(Map<String, dynamic> datos) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response =
          await supabaseLU.from('clientes').insert(datos).select().single();

      final nuevoCliente = Cliente.fromJson(response);
      _clientes.add(nuevoCliente);

      log('✅ Cliente creado: ${nuevoCliente.nombre}');
      return true;
    } catch (e) {
      _error = 'Error al crear cliente: $e';
      log('❌ Error creando cliente: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear vehículo
  Future<bool> crearVehiculo(Map<String, dynamic> datos) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response =
          await supabaseLU.from('vehiculos').insert(datos).select().single();

      final nuevoVehiculo = Vehiculo.fromJson(response);
      _vehiculos.add(nuevoVehiculo);

      log('✅ Vehículo creado: ${nuevoVehiculo.placa}');
      return true;
    } catch (e) {
      _error = 'Error al crear vehículo: $e';
      log('❌ Error creando vehículo: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar clientes
  List<Cliente> buscarClientes(String query) {
    if (query.isEmpty) return _clientes;

    return _clientes
        .where((cliente) =>
            cliente.nombre.toLowerCase().contains(query.toLowerCase()) ||
            (cliente.correo?.toLowerCase().contains(query.toLowerCase()) ??
                false) ||
            (cliente.telefono?.contains(query) ?? false))
        .toList();
  }

  // Buscar vehículos
  List<Vehiculo> buscarVehiculos(String query) {
    if (query.isEmpty) return _vehiculos;

    return _vehiculos
        .where((vehiculo) =>
            vehiculo.placa.toLowerCase().contains(query.toLowerCase()) ||
            vehiculo.marca.toLowerCase().contains(query.toLowerCase()) ||
            vehiculo.modelo.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
