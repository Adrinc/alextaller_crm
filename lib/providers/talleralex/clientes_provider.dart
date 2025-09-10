import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helpers/globals.dart';
import '../../models/talleralex/clientes_models.dart';

class ClientesProvider extends ChangeNotifier {
  // Variables de estado
  bool _isLoading = false;
  String? _error;
  String _sucursalId = '';

  // Listas principales
  List<ClienteGrid> _clientes = [];
  List<HistorialCliente> _historialCliente = [];
  List<Vehiculo> _vehiculosCliente = [];

  // Cliente seleccionado para detalles
  ClienteGrid? _clienteSeleccionado;

  // Variables de filtrado
  String _filtroTexto = '';
  bool? _filtroConVehiculos;
  bool? _filtroConCitasProximas;
  DateTimeRange? _filtroUltimaVisita;

  // PlutoGrid rows
  List<PlutoRow> clientesRows = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sucursalId => _sucursalId;
  List<ClienteGrid> get clientes => _clientes;
  List<HistorialCliente> get historialCliente => _historialCliente;
  List<Vehiculo> get vehiculosCliente => _vehiculosCliente;
  ClienteGrid? get clienteSeleccionado => _clienteSeleccionado;

  // Getters de filtros
  String get filtroTexto => _filtroTexto;
  bool? get filtroConVehiculos => _filtroConVehiculos;
  bool? get filtroConCitasProximas => _filtroConCitasProximas;
  DateTimeRange? get filtroUltimaVisita => _filtroUltimaVisita;

  // Getter para clientes filtrados
  List<ClienteGrid> get clientesFiltrados {
    List<ClienteGrid> resultado = List.from(_clientes);

    // Filtro por texto
    if (_filtroTexto.isNotEmpty) {
      resultado = resultado
          .where((cliente) =>
              cliente.clienteNombre
                  .toLowerCase()
                  .contains(_filtroTexto.toLowerCase()) ||
              (cliente.correo
                      ?.toLowerCase()
                      .contains(_filtroTexto.toLowerCase()) ??
                  false) ||
              (cliente.telefono?.contains(_filtroTexto) ?? false) ||
              (cliente.rfc
                      ?.toLowerCase()
                      .contains(_filtroTexto.toLowerCase()) ??
                  false))
          .toList();
    }

    // Filtro por vehículos
    if (_filtroConVehiculos != null) {
      resultado = resultado.where((cliente) {
        if (_filtroConVehiculos! && cliente.totalVehiculos == 0) {
          return false;
        }
        if (!_filtroConVehiculos! && cliente.totalVehiculos > 0) {
          return false;
        }
        return true;
      }).toList();
    }

    // Filtro por citas próximas
    if (_filtroConCitasProximas != null) {
      resultado = resultado.where((cliente) {
        if (_filtroConCitasProximas! && cliente.citasProximas == 0) {
          return false;
        }
        if (!_filtroConCitasProximas! && cliente.citasProximas > 0) {
          return false;
        }
        return true;
      }).toList();
    }

    // Filtro por rango de última visita
    if (_filtroUltimaVisita != null) {
      resultado = resultado.where((cliente) {
        if (cliente.ultimaVisita == null) return false;

        final visitaDate = DateTime(
          cliente.ultimaVisita!.year,
          cliente.ultimaVisita!.month,
          cliente.ultimaVisita!.day,
        );
        final inicioRange = DateTime(
          _filtroUltimaVisita!.start.year,
          _filtroUltimaVisita!.start.month,
          _filtroUltimaVisita!.start.day,
        );
        final finRange = DateTime(
          _filtroUltimaVisita!.end.year,
          _filtroUltimaVisita!.end.month,
          _filtroUltimaVisita!.end.day,
        );

        return !visitaDate.isBefore(inicioRange) &&
            !visitaDate.isAfter(finRange);
      }).toList();
    }

    // Ordenar por nombre
    resultado.sort((a, b) => a.clienteNombre.compareTo(b.clienteNombre));
    return resultado;
  }

  // Método para cargar clientes de una sucursal usando la vista
  Future<void> cargarClientesSucursal(String sucursalId) async {
    if (_sucursalId == sucursalId && _clientes.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    _sucursalId = sucursalId;
    notifyListeners();

    try {
      final response = await supabaseLU
          .from('vw_clientes_sucursal')
          .select()
          .eq('sucursal_id', sucursalId);

      _clientes = (response as List<dynamic>)
          .map((json) => ClienteGrid.fromJson(json as Map<String, dynamic>))
          .toList();

      // Construir filas para PlutoGrid
      _buildClientesRows();

      _error = null;
      log('✅ Clientes cargados: ${_clientes.length}');
    } catch (e) {
      _error = 'Error al cargar clientes: $e';
      _clientes = [];
      log('❌ Error cargando clientes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Construir filas para PlutoGrid usando datos de clientes
  void _buildClientesRows() {
    clientesRows.clear();

    for (int i = 0; i < clientesFiltrados.length; i++) {
      final cliente = clientesFiltrados[i];
      clientesRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'nombre': PlutoCell(value: cliente.clienteNombre),
        'telefono': PlutoCell(value: cliente.telefono ?? ''),
        'correo': PlutoCell(value: cliente.correo ?? ''),
        'rfc': PlutoCell(value: cliente.rfc ?? ''),
        'direccion': PlutoCell(value: cliente.direccion ?? ''),
        'vehiculos': PlutoCell(value: cliente.totalVehiculos),
        'citas_proximas': PlutoCell(value: cliente.citasProximas),
        'ultima_visita': PlutoCell(value: cliente.ultimaVisitaTexto),
        'total_gastado': PlutoCell(value: cliente.totalGastadoTexto),
        'acciones': PlutoCell(value: cliente.clienteId),
      }));
    }
  }

  // Método para refrescar datos
  Future<void> refrescarClientes() async {
    if (_sucursalId.isEmpty) return;

    final sucursalActual = _sucursalId;
    _clientes.clear();
    await cargarClientesSucursal(sucursalActual);
  }

  // Métodos de filtrado
  void aplicarFiltroTexto(String texto) {
    _filtroTexto = texto;
    _buildClientesRows();
    notifyListeners();
  }

  void aplicarFiltroConVehiculos(bool? conVehiculos) {
    _filtroConVehiculos = conVehiculos;
    _buildClientesRows();
    notifyListeners();
  }

  void aplicarFiltroConCitasProximas(bool? conCitas) {
    _filtroConCitasProximas = conCitas;
    _buildClientesRows();
    notifyListeners();
  }

  void aplicarFiltroUltimaVisita(DateTimeRange? rango) {
    _filtroUltimaVisita = rango;
    _buildClientesRows();
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtroTexto = '';
    _filtroConVehiculos = null;
    _filtroConCitasProximas = null;
    _filtroUltimaVisita = null;
    _buildClientesRows();
    notifyListeners();
  }

  // Seleccionar cliente para ver detalles
  void seleccionarCliente(ClienteGrid cliente) {
    _clienteSeleccionado = cliente;
    // Cargar datos adicionales del cliente
    cargarHistorialCliente(cliente.clienteId);
    cargarVehiculosCliente(cliente.clienteId);
    notifyListeners();
  }

  void limpiarSeleccion() {
    _clienteSeleccionado = null;
    _historialCliente.clear();
    _vehiculosCliente.clear();
    notifyListeners();
  }

  // Cargar historial del cliente
  Future<void> cargarHistorialCliente(String clienteId) async {
    try {
      final response = await supabaseLU
          .from('vw_historial_cliente')
          .select()
          .eq('cliente_id', clienteId)
          .order('fecha_inicio', ascending: false);

      _historialCliente = (response as List<dynamic>)
          .map(
              (json) => HistorialCliente.fromJson(json as Map<String, dynamic>))
          .toList();

      log('✅ Historial cliente cargado: ${_historialCliente.length} registros');
    } catch (e) {
      log('❌ Error cargando historial cliente: $e');
    }
  }

  // Cargar vehículos del cliente
  Future<void> cargarVehiculosCliente(String clienteId) async {
    try {
      final response = await supabaseLU
          .from('vehiculos')
          .select()
          .eq('cliente_id', clienteId)
          .order('placa');

      _vehiculosCliente = (response as List<dynamic>)
          .map((json) => Vehiculo.fromJson(json as Map<String, dynamic>))
          .toList();

      log('✅ Vehículos cliente cargados: ${_vehiculosCliente.length}');
    } catch (e) {
      log('❌ Error cargando vehículos cliente: $e');
    }
  }

  // Crear nuevo cliente
  Future<bool> crearCliente(NuevoCliente nuevoCliente) async {
    try {
      _isLoading = true;
      notifyListeners();

      await supabaseLU.from('clientes').insert(nuevoCliente.toJson());

      // Refrescar la lista de clientes
      await refrescarClientes();
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

  // Crear nuevo vehículo
  Future<bool> crearVehiculo(NuevoVehiculo nuevoVehiculo) async {
    try {
      _isLoading = true;
      notifyListeners();

      await supabaseLU.from('vehiculos').insert(nuevoVehiculo.toJson());

      // Refrescar vehículos del cliente si está seleccionado
      if (_clienteSeleccionado?.clienteId == nuevoVehiculo.clienteId) {
        await cargarVehiculosCliente(nuevoVehiculo.clienteId);
      }

      // Refrescar la lista de clientes para actualizar contador de vehículos
      await refrescarClientes();

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

  // Actualizar cliente
  Future<bool> actualizarCliente(
      String clienteId, Map<String, dynamic> datos) async {
    try {
      _isLoading = true;
      notifyListeners();

      await supabaseLU.from('clientes').update(datos).eq('id', clienteId);

      // Refrescar la lista de clientes
      await refrescarClientes();

      log('✅ Cliente actualizado');
      return true;
    } catch (e) {
      _error = 'Error al actualizar cliente: $e';
      log('❌ Error actualizando cliente: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar clientes (para uso local con filtros aplicados)
  List<ClienteGrid> buscarClientes(String query) {
    if (query.isEmpty) return clientesFiltrados;

    return clientesFiltrados
        .where((cliente) =>
            cliente.clienteNombre.toLowerCase().contains(query.toLowerCase()) ||
            (cliente.correo?.toLowerCase().contains(query.toLowerCase()) ??
                false) ||
            (cliente.telefono?.contains(query) ?? false))
        .toList();
  }

  // Buscar vehículos del cliente seleccionado
  List<Vehiculo> buscarVehiculosCliente(String query) {
    if (query.isEmpty) return _vehiculosCliente;

    return _vehiculosCliente
        .where((vehiculo) =>
            vehiculo.placa.toLowerCase().contains(query.toLowerCase()) ||
            vehiculo.marca.toLowerCase().contains(query.toLowerCase()) ||
            vehiculo.modelo.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
