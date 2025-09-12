import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/talleralex/usuarios_pendientes_models.dart';

class UsuariosPendientesProvider extends ChangeNotifier {
  List<UsuarioPendienteGrid> _usuarios = [];
  List<PlutoRow> usuariosRows = [];

  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';

  // Getters
  List<UsuarioPendienteGrid> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;

  // Usuarios filtrados por búsqueda
  List<UsuarioPendienteGrid> get usuariosFiltrados {
    if (_searchTerm.isEmpty) return _usuarios;

    return _usuarios.where((usuario) {
      final searchLower = _searchTerm.toLowerCase();
      return usuario.nombreCompleto.toLowerCase().contains(searchLower) ||
          (usuario.telefono?.toLowerCase().contains(searchLower) ?? false) ||
          usuario.estado.toLowerCase().contains(searchLower);
    }).toList();
  }

  // Estadísticas rápidas
  int get totalUsuarios => _usuarios.length;
  int get usuariosPendientes =>
      _usuarios.where((u) => u.estado == 'pendiente').length;
  int get usuariosAprobados =>
      _usuarios.where((u) => u.estado == 'aprobado').length;
  int get usuariosRechazados =>
      _usuarios.where((u) => u.estado == 'rechazado').length;

  /// Cargar usuarios pendientes desde la vista vw_usuarios_pendientes
  Future<void> cargarUsuariosPendientes() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('🔄 Cargando usuarios pendientes desde vw_usuarios_pendientes');

      final response = await supabaseLU
          .from('vw_usuarios_pendientes')
          .select()
          .order('fecha_registro', ascending: false);

      _usuarios = (response as List)
          .map((json) => UsuarioPendienteGrid.fromJson(json))
          .toList();

      _buildUsuariosRows();

      log('✅ ${_usuarios.length} usuarios pendientes cargados');
    } catch (e) {
      _error = 'Error al cargar usuarios pendientes: $e';
      log('❌ Error en cargarUsuariosPendientes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Construir filas para PlutoGrid
  void _buildUsuariosRows() {
    usuariosRows.clear();

    final usuariosMostrar = usuariosFiltrados;

    for (int i = 0; i < usuariosMostrar.length; i++) {
      final usuario = usuariosMostrar[i];
      usuariosRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'nombre': PlutoCell(value: usuario.nombreCompleto),
        'telefono': PlutoCell(value: usuario.telefono ?? 'Sin teléfono'),
        'dias_esperando': PlutoCell(value: usuario.tiempoEsperandoTexto),
        'fecha_registro':
            PlutoCell(value: _formatearFecha(usuario.fechaRegistro)),
        'estado': PlutoCell(value: usuario.estadoTexto),
        'acciones': PlutoCell(value: usuario.usuarioId), // ID para acciones
      }));
    }
  }

  /// Aprobar usuario con rol específico
  Future<bool> aprobarUsuario(String usuarioId, int rolId) async {
    try {
      log('🔄 Aprobando usuario $usuarioId con rol $rolId');

      final response = await supabaseLU.rpc('aprobar_usuario', params: {
        'usuario_uuid': usuarioId,
        'role_id': rolId,
      });

      log('✅ Usuario aprobado exitosamente: $response');

      // Recargar datos
      await cargarUsuariosPendientes();

      return true;
    } catch (e) {
      _error = 'Error al aprobar usuario: $e';
      log('❌ Error en aprobarUsuario: $e');
      notifyListeners();
      return false;
    }
  }

  /// Rechazar usuario
  Future<bool> rechazarUsuario(String usuarioId) async {
    try {
      log('🔄 Rechazando usuario $usuarioId');

      final response = await supabaseLU.rpc('rechazar_usuario', params: {
        'usuario_uuid': usuarioId,
      });

      log('✅ Usuario rechazado exitosamente: $response');

      // Recargar datos
      await cargarUsuariosPendientes();

      return true;
    } catch (e) {
      _error = 'Error al rechazar usuario: $e';
      log('❌ Error en rechazarUsuario: $e');
      notifyListeners();
      return false;
    }
  }

  /// Filtrar usuarios por término de búsqueda
  void filtrarUsuarios(String term) {
    _searchTerm = term;
    _buildUsuariosRows();
    notifyListeners();
  }

  /// Limpiar filtros
  void limpiarFiltros() {
    _searchTerm = '';
    _buildUsuariosRows();
    notifyListeners();
  }

  /// Obtener usuario por ID
  UsuarioPendienteGrid? getUsuarioById(String usuarioId) {
    try {
      return _usuarios.firstWhere((usuario) => usuario.usuarioId == usuarioId);
    } catch (e) {
      return null;
    }
  }

  /// Formatear fecha para mostrar
  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      return 'Hoy ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return '${diferencia.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refrescar datos
  Future<void> refresh() async {
    await cargarUsuariosPendientes();
  }
}
