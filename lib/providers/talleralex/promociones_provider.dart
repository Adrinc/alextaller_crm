import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../models/talleralex/promociones_models.dart';
import '../../helpers/globals.dart';

class PromocionesProvider with ChangeNotifier {
  List<PromocionSucursal> _promociones = [];
  List<PromocionSucursal> _promocionesFiltradas = [];
  KPIsPromociones? _kpis;
  List<PlutoRow> _promocionesRows = [];

  bool _isLoading = false;
  String? _error;
  String _sucursalActual = '';

  // Filtros
  String _filtroTexto = '';
  String? _filtroEstado;
  String? _filtroTipo;
  String? _filtroAmbito;

  // Estados disponibles para filtros
  final List<String> _estadosDisponibles = [
    'vigente',
    'expirada',
    'próxima',
    'inactiva'
  ];
  final List<String> _tiposDisponibles = [
    'porcentaje',
    'monto_fijo',
    'descuento_especial'
  ];
  final List<String> _ambitosDisponibles = ['global', 'local'];

  // Getters
  List<PromocionSucursal> get promociones => _promociones;
  List<PromocionSucursal> get promocionesFiltradas => _promocionesFiltradas;
  KPIsPromociones? get kpis => _kpis;
  List<PlutoRow> get promocionesRows => _promocionesRows;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sucursalActual => _sucursalActual;

  String get filtroTexto => _filtroTexto;
  String? get filtroEstado => _filtroEstado;
  String? get filtroTipo => _filtroTipo;
  String? get filtroAmbito => _filtroAmbito;

  List<String> get estadosDisponibles => _estadosDisponibles;
  List<String> get tiposDisponibles => _tiposDisponibles;
  List<String> get ambitosDisponibles => _ambitosDisponibles;

  // Cargar datos principales
  Future<void> cargarDatos(String sucursalId) async {
    if (_sucursalActual == sucursalId && _promociones.isNotEmpty) {
      return;
    }

    _sucursalActual = sucursalId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _cargarPromociones(sucursalId),
        _calcularKPIs(),
      ]);

      _aplicarFiltros();
      _buildPromocionesRows();
    } catch (e) {
      _error = 'Error al cargar promociones: ${e.toString()}';
      debugPrint('Error en cargarDatos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar promociones desde la vista
  Future<void> _cargarPromociones(String sucursalId) async {
    try {
      final response = await supabaseLU
          .from('vw_promociones_sucursal')
          .select('*')
          .eq('sucursal_id', sucursalId)
          .order('created_at', ascending: false);

      if (response is List) {
        _promociones =
            response.map((item) => PromocionSucursal.fromJson(item)).toList();
      } else {
        throw Exception('Formato de respuesta inválido');
      }
    } catch (e) {
      debugPrint('Error al cargar promociones: $e');
      throw Exception('Error al cargar promociones: ${e.toString()}');
    }
  }

  // Calcular KPIs
  Future<void> _calcularKPIs() async {
    try {
      final ahora = DateTime.now();
      final inicioMes = DateTime(ahora.year, ahora.month, 1);

      // Total promociones activas
      final totalActivas = _promociones.where((p) => p.esVigente).length;

      // Próximas a vencer (menos de 7 días)
      final proximasVencer = _promociones.where((p) => p.proximaAVencer).length;

      // Expiradas este mes
      final expiradasMes = _promociones
          .where((p) => p.esExpirada && p.fechaFin.isAfter(inicioMes))
          .length;

      // Obtener total de servicios para calcular porcentaje
      final responseServicios = await supabaseLU
          .from('sucursal_servicios')
          .select('servicio_id')
          .eq('sucursal_id', _sucursalActual)
          .eq('activo', true);

      int totalServicios = 0;
      if (responseServicios is List) {
        totalServicios = responseServicios.length;
      }

      // Obtener servicios con promoción
      final promocionesVigentesIds = _promociones
          .where((p) => p.esVigente)
          .map((p) => p.promocionId)
          .toList();

      var responseServiciosConPromo = [];
      if (promocionesVigentesIds.isNotEmpty) {
        responseServiciosConPromo = await supabaseLU
            .from('promocion_servicios')
            .select('servicio_id')
            .in_('promocion_id', promocionesVigentesIds);
      }

      int serviciosConPromo = 0;
      if (responseServiciosConPromo.isNotEmpty) {
        // Contar servicios únicos
        final serviciosUnicos = <String>{};
        for (final item in responseServiciosConPromo) {
          serviciosUnicos.add(item['servicio_id'].toString());
        }
        serviciosConPromo = serviciosUnicos.length;
      }

      final porcentajeServiciosConPromo =
          totalServicios > 0 ? (serviciosConPromo / totalServicios) * 100 : 0.0;

      _kpis = KPIsPromociones(
        totalActivas: totalActivas,
        proximasVencer: proximasVencer,
        expiradasMes: expiradasMes,
        porcentajeServiciosConPromo: porcentajeServiciosConPromo,
      );
    } catch (e) {
      debugPrint('Error al calcular KPIs: $e');
      _kpis = KPIsPromociones(
        totalActivas: 0,
        proximasVencer: 0,
        expiradasMes: 0,
        porcentajeServiciosConPromo: 0.0,
      );
    }
  }

  // Aplicar filtros
  void _aplicarFiltros() {
    _promocionesFiltradas = _promociones.where((promocion) {
      // Filtro por texto
      if (_filtroTexto.isNotEmpty) {
        final texto = _filtroTexto.toLowerCase();
        if (!promocion.titulo.toLowerCase().contains(texto) &&
            !promocion.descripcion.toLowerCase().contains(texto) &&
            !promocion.sucursalNombre.toLowerCase().contains(texto)) {
          return false;
        }
      }

      // Filtro por estado
      if (_filtroEstado != null) {
        final estado = promocion.estadoTexto.toLowerCase();
        if (estado != _filtroEstado!.toLowerCase()) {
          return false;
        }
      }

      // Filtro por tipo de descuento
      if (_filtroTipo != null) {
        if (promocion.tipoDescuento.toLowerCase() !=
            _filtroTipo!.toLowerCase()) {
          return false;
        }
      }

      // Filtro por ámbito
      if (_filtroAmbito != null) {
        final ambito = promocion.ambitoTexto.toLowerCase();
        if (ambito != _filtroAmbito!.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Métodos de filtrado
  void aplicarFiltroTexto(String texto) {
    _filtroTexto = texto;
    _aplicarFiltros();
    _buildPromocionesRows();
    notifyListeners();
  }

  void aplicarFiltroEstado(String? estado) {
    _filtroEstado = estado;
    _aplicarFiltros();
    _buildPromocionesRows();
    notifyListeners();
  }

  void aplicarFiltroTipo(String? tipo) {
    _filtroTipo = tipo;
    _aplicarFiltros();
    _buildPromocionesRows();
    notifyListeners();
  }

  void aplicarFiltroAmbito(String? ambito) {
    _filtroAmbito = ambito;
    _aplicarFiltros();
    _buildPromocionesRows();
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtroTexto = '';
    _filtroEstado = null;
    _filtroTipo = null;
    _filtroAmbito = null;
    _aplicarFiltros();
    _buildPromocionesRows();
    notifyListeners();
  }

  // Construir filas para PlutoGrid
  void _buildPromocionesRows() {
    _promocionesRows.clear();

    for (int i = 0; i < _promocionesFiltradas.length; i++) {
      final promocion = _promocionesFiltradas[i];
      _promocionesRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'titulo': PlutoCell(value: promocion.titulo),
        'descripcion': PlutoCell(value: promocion.descripcion),
        'tipo_descuento': PlutoCell(value: promocion.tipoDescuentoTexto),
        'valor_descuento': PlutoCell(value: promocion.valorDescuentoTexto),
        'vigencia': PlutoCell(value: promocion.vigenciaTexto),
        'estado': PlutoCell(value: promocion.estadoTexto),
        'ambito': PlutoCell(value: promocion.ambitoTexto),
        'fecha_creacion': PlutoCell(value: promocion.fechaInicioTexto),
        'dias_restantes': PlutoCell(value: promocion.diasRestantes.toString()),
        'acciones': PlutoCell(value: promocion.promocionId),
      }));
    }
  }

  // Refrescar datos
  Future<void> refrescarDatos() async {
    if (_sucursalActual.isNotEmpty) {
      _promociones.clear();
      await cargarDatos(_sucursalActual);
    }
  }

  // CRUD Operations
  Future<bool> crearPromocion(CrearPromocion nuevaPromocion) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Crear la promoción
      final response = await supabaseLU
          .from('promociones')
          .insert(nuevaPromocion.toJson())
          .select()
          .single();

      final promocionId = response['id'] as String;

      // Asociar a sucursales si es necesario
      if (nuevaPromocion.sucursalesIds.isNotEmpty) {
        final sucursalesData = nuevaPromocion.sucursalesIds
            .map((sucursalId) => {
                  'promocion_id': promocionId,
                  'sucursal_id': sucursalId,
                })
            .toList();

        await supabaseLU.from('promocion_sucursales').insert(sucursalesData);
      }

      // Asociar servicios si es necesario
      if (nuevaPromocion.serviciosIds.isNotEmpty) {
        final serviciosData = nuevaPromocion.serviciosIds
            .map((servicioId) => {
                  'promocion_id': promocionId,
                  'servicio_id': servicioId,
                })
            .toList();

        await supabaseLU.from('promocion_servicios').insert(serviciosData);
      }

      await refrescarDatos();
      return true;
    } catch (e) {
      _error = 'Error al crear promoción: ${e.toString()}';
      debugPrint('Error al crear promoción: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarPromocion(ActualizarPromocion actualizacion) async {
    try {
      _isLoading = true;
      notifyListeners();

      await supabaseLU
          .from('promociones')
          .update(actualizacion.toJson())
          .eq('id', actualizacion.promocionId);

      // Actualizar asociaciones de sucursales si se proporcionaron
      if (actualizacion.sucursalesIds != null) {
        // Eliminar asociaciones existentes
        await supabaseLU
            .from('promocion_sucursales')
            .delete()
            .eq('promocion_id', actualizacion.promocionId);

        // Crear nuevas asociaciones
        if (actualizacion.sucursalesIds!.isNotEmpty) {
          final sucursalesData = actualizacion.sucursalesIds!
              .map((sucursalId) => {
                    'promocion_id': actualizacion.promocionId,
                    'sucursal_id': sucursalId,
                  })
              .toList();

          await supabaseLU.from('promocion_sucursales').insert(sucursalesData);
        }
      }

      // Actualizar asociaciones de servicios si se proporcionaron
      if (actualizacion.serviciosIds != null) {
        // Eliminar asociaciones existentes
        await supabaseLU
            .from('promocion_servicios')
            .delete()
            .eq('promocion_id', actualizacion.promocionId);

        // Crear nuevas asociaciones
        if (actualizacion.serviciosIds!.isNotEmpty) {
          final serviciosData = actualizacion.serviciosIds!
              .map((servicioId) => {
                    'promocion_id': actualizacion.promocionId,
                    'servicio_id': servicioId,
                  })
              .toList();

          await supabaseLU.from('promocion_servicios').insert(serviciosData);
        }
      }

      await refrescarDatos();
      return true;
    } catch (e) {
      _error = 'Error al actualizar promoción: ${e.toString()}';
      debugPrint('Error al actualizar promoción: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstadoPromocion(String promocionId, bool activo) async {
    try {
      await supabaseLU.from('promociones').update({
        'activo': activo,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', promocionId);

      await refrescarDatos();
      return true;
    } catch (e) {
      _error = 'Error al cambiar estado: ${e.toString()}';
      debugPrint('Error al cambiar estado: $e');
      return false;
    }
  }

  Future<bool> eliminarPromocion(String promocionId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Eliminar asociaciones primero
      await supabaseLU
          .from('promocion_servicios')
          .delete()
          .eq('promocion_id', promocionId);

      await supabaseLU
          .from('promocion_sucursales')
          .delete()
          .eq('promocion_id', promocionId);

      // Eliminar la promoción
      await supabaseLU.from('promociones').delete().eq('id', promocionId);

      await refrescarDatos();
      return true;
    } catch (e) {
      _error = 'Error al eliminar promoción: ${e.toString()}';
      debugPrint('Error al eliminar promoción: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener servicios asociados a una promoción
  Future<List<ServicioPromocion>> obtenerServiciosPromocion(
      String promocionId) async {
    try {
      final response = await supabaseLU.from('promocion_servicios').select('''
            *,
            servicios!inner(nombre)
          ''').eq('promocion_id', promocionId);

      if (response is List) {
        return response.map((item) {
          return ServicioPromocion(
            id: item['id'],
            promocionId: item['promocion_id'],
            servicioId: item['servicio_id'],
            servicioNombre: item['servicios']['nombre'],
          );
        }).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error al obtener servicios de promoción: $e');
      return [];
    }
  }

  // Duplicar promoción
  Future<bool> duplicarPromocion(String promocionId) async {
    try {
      // Obtener la promoción original
      final promocionOriginal = _promociones.firstWhere(
        (p) => p.promocionId == promocionId,
      );

      // Obtener servicios asociados
      final servicios = await obtenerServiciosPromocion(promocionId);

      // Crear nueva promoción con datos similares
      final nuevaPromocion = CrearPromocion(
        titulo: '${promocionOriginal.titulo} (Copia)',
        descripcion: promocionOriginal.descripcion,
        tipoDescuento: promocionOriginal.tipoDescuento,
        valorDescuento: promocionOriginal.valorDescuento,
        fechaInicio: DateTime.now(),
        fechaFin: DateTime.now().add(const Duration(days: 30)),
        activo: false, // Crear como inactiva para que el usuario la revise
        condicionesJson: promocionOriginal.condicionesJson,
        sucursalesIds: [promocionOriginal.sucursalId],
        serviciosIds: servicios.map((s) => s.servicioId).toList(),
      );

      return await crearPromocion(nuevaPromocion);
    } catch (e) {
      _error = 'Error al duplicar promoción: ${e.toString()}';
      debugPrint('Error al duplicar promoción: $e');
      return false;
    }
  }

  // Buscar promoción por ID
  PromocionSucursal? obtenerPromocionPorId(String promocionId) {
    try {
      return _promociones.firstWhere((p) => p.promocionId == promocionId);
    } catch (e) {
      return null;
    }
  }
}
