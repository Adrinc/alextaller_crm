// Modelos para el sistema de inventario global basados en las funciones RPC reales

// Modelo para el detalle del inventario (vw_inventario_sucursal)
class InventarioDetalleItem {
  final String refaccionId;
  final String sucursalId;
  final String sucursalNombre;
  final String sku;
  final String nombre;
  final String? descripcion;
  final String? proveedor;
  final double precioUnitario;
  final int existencias;
  final int minimoAlerta;
  final bool activo;
  final String? imagenId;
  final String? imagenPath;

  InventarioDetalleItem({
    required this.refaccionId,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.sku,
    required this.nombre,
    this.descripcion,
    this.proveedor,
    required this.precioUnitario,
    required this.existencias,
    required this.minimoAlerta,
    required this.activo,
    this.imagenId,
    this.imagenPath,
  });

  factory InventarioDetalleItem.fromJson(Map<String, dynamic> json) {
    return InventarioDetalleItem(
      refaccionId: json['refaccion_id']?.toString() ?? '',
      sucursalId: json['sucursal_id']?.toString() ?? '',
      sucursalNombre: json['sucursal_nombre']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      proveedor: json['proveedor']?.toString(),
      precioUnitario: double.tryParse(json['precio_unitario']?.toString() ?? '0') ?? 0.0,
      existencias: int.tryParse(json['existencias']?.toString() ?? '0') ?? 0,
      minimoAlerta: int.tryParse(json['minimo_alerta']?.toString() ?? '0') ?? 0,
      activo: json['activo'] == true || json['activo']?.toString() == 'true',
      imagenId: json['imagen_id']?.toString(),
      imagenPath: json['imagen_path']?.toString(),
    );
  }

  // Getters calculados
  double get valorTotalStock => existencias * precioUnitario;
  
  bool get tieneStockBajo => existencias <= minimoAlerta && existencias > 0;
  
  bool get sinStock => existencias == 0;
  
  String get nivelStockTexto {
    if (sinStock) return 'Sin Stock';
    if (tieneStockBajo) return 'Stock Bajo';
    return 'Normal';
  }
}

// Modelo para alertas de stock (vw_inventario_alerta)
class InventarioAlertaItem {
  final String refaccionId;
  final String sucursalId;
  final String sku;
  final String nombre;
  final int existencias;
  final int minimoAlerta;
  final String? imagenId;
  final String? imagenPath;

  InventarioAlertaItem({
    required this.refaccionId,
    required this.sucursalId,
    required this.sku,
    required this.nombre,
    required this.existencias,
    required this.minimoAlerta,
    this.imagenId,
    this.imagenPath,
  });

  factory InventarioAlertaItem.fromJson(Map<String, dynamic> json) {
    return InventarioAlertaItem(
      refaccionId: json['refaccion_id']?.toString() ?? '',
      sucursalId: json['sucursal_id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      existencias: int.tryParse(json['existencias']?.toString() ?? '0') ?? 0,
      minimoAlerta: int.tryParse(json['minimo_alerta']?.toString() ?? '0') ?? 0,
      imagenId: json['imagen_id']?.toString(),
      imagenPath: json['imagen_path']?.toString(),
    );
  }

  bool get sinStock => existencias == 0;
  bool get stockBajo => existencias <= minimoAlerta && existencias > 0;
  
  String get tipoAlerta {
    if (sinStock) return 'Sin Stock';
    if (stockBajo) return 'Stock Bajo';
    return 'Normal';
  }
}

// Modelo para caducidad (vw_inventario_caducidad)
class InventarioCaducidadItem {
  final String refaccionId;
  final String sucursalId;
  final String sucursalNombre;
  final String sku;
  final String nombre;
  final int existencias;
  final DateTime fechaCaducidad;
  final int diasParaVencer;

  InventarioCaducidadItem({
    required this.refaccionId,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.sku,
    required this.nombre,
    required this.existencias,
    required this.fechaCaducidad,
    required this.diasParaVencer,
  });

  factory InventarioCaducidadItem.fromJson(Map<String, dynamic> json) {
    return InventarioCaducidadItem(
      refaccionId: json['refaccion_id']?.toString() ?? '',
      sucursalId: json['sucursal_id']?.toString() ?? '',
      sucursalNombre: json['sucursal_nombre']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      existencias: int.tryParse(json['existencias']?.toString() ?? '0') ?? 0,
      fechaCaducidad: json['fecha_caducidad'] != null
          ? DateTime.tryParse(json['fecha_caducidad'].toString()) ?? DateTime.now()
          : DateTime.now(),
      diasParaVencer: int.tryParse(json['dias_para_vencer']?.toString() ?? '0') ?? 0,
    );
  }

  bool get yaCaduco => diasParaVencer < 0;
  bool get caducaHoy => diasParaVencer == 0;
  bool get caducaEstaSemana => diasParaVencer <= 7 && diasParaVencer > 0;
  bool get caducaEsteMes => diasParaVencer <= 30 && diasParaVencer > 7;

  String get estadoCaducidad {
    if (yaCaduco) return 'Caducado';
    if (caducaHoy) return 'Caduca Hoy';
    if (caducaEstaSemana) return 'Esta Semana';
    if (caducaEsteMes) return 'Este Mes';
    return 'Próximamente';
  }
}

// Modelo para resumen de inventario (vw_inventario_resumen)
class InventarioResumenItem {
  final String sku;
  final String nombre;
  final String? descripcion;
  final String? proveedor;
  final int existenciasTotales;
  final int minimoAlertaGlobal;
  final int posicionesConStock;
  final int sucursalesConStock;

  InventarioResumenItem({
    required this.sku,
    required this.nombre,
    this.descripcion,
    this.proveedor,
    required this.existenciasTotales,
    required this.minimoAlertaGlobal,
    required this.posicionesConStock,
    required this.sucursalesConStock,
  });

  factory InventarioResumenItem.fromJson(Map<String, dynamic> json) {
    return InventarioResumenItem(
      sku: json['sku']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      proveedor: json['proveedor']?.toString(),
      existenciasTotales: int.tryParse(json['existencias_totales']?.toString() ?? '0') ?? 0,
      minimoAlertaGlobal: int.tryParse(json['minimo_alerta_global']?.toString() ?? '0') ?? 0,
      posicionesConStock: int.tryParse(json['posiciones_con_stock']?.toString() ?? '0') ?? 0,
      sucursalesConStock: int.tryParse(json['sucursales_con_stock']?.toString() ?? '0') ?? 0,
    );
  }
}

// Modelo para rotación mensual (vw_refacciones_rotacion_mensual)
class RefaccionRotacionItem {
  final String refaccionId;
  final String sku;
  final String refaccionNombre;
  final String sucursalId;
  final String sucursalNombre;
  final DateTime periodo;
  final double qtyUsada;
  final double ingresosGenerados;

  RefaccionRotacionItem({
    required this.refaccionId,
    required this.sku,
    required this.refaccionNombre,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.periodo,
    required this.qtyUsada,
    required this.ingresosGenerados,
  });

  factory RefaccionRotacionItem.fromJson(Map<String, dynamic> json) {
    return RefaccionRotacionItem(
      refaccionId: json['refaccion_id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      refaccionNombre: json['refaccion_nombre']?.toString() ?? '',
      sucursalId: json['sucursal_id']?.toString() ?? '',
      sucursalNombre: json['sucursal_nombre']?.toString() ?? '',
      periodo: json['periodo'] != null
          ? DateTime.tryParse(json['periodo'].toString()) ?? DateTime.now()
          : DateTime.now(),
      qtyUsada: double.tryParse(json['qty_usada']?.toString() ?? '0') ?? 0.0,
      ingresosGenerados: double.tryParse(json['ingresos_generados']?.toString() ?? '0') ?? 0.0,
    );
  }
}

// Modelo para predicción de demanda (opcional)
class PrediccionDemandaItem {
  final String refaccionId;
  final String sucursalId;
  final String sku;
  final double avgDiaria;

  PrediccionDemandaItem({
    required this.refaccionId,
    required this.sucursalId,
    required this.sku,
    required this.avgDiaria,
  });

  factory PrediccionDemandaItem.fromJson(Map<String, dynamic> json) {
    return PrediccionDemandaItem(
      refaccionId: json['refaccion_id']?.toString() ?? '',
      sucursalId: json['sucursal_id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      avgDiaria: double.tryParse(json['avg_diaria']?.toString() ?? '0') ?? 0.0,
    );
  }
}

// Modelo para sugerencias de reorden (opcional)
class SugerenciaReordenItem {
  final String sucursalId;
  final String sucursalNombre;
  final String sku;
  final String nombre;
  final int existencias;
  final int minimoAlerta;
  final double avgDiaria30d;
  final double stockObjetivo;
  final int sugerido;

  SugerenciaReordenItem({
    required this.sucursalId,
    required this.sucursalNombre,
    required this.sku,
    required this.nombre,
    required this.existencias,
    required this.minimoAlerta,
    required this.avgDiaria30d,
    required this.stockObjetivo,
    required this.sugerido,
  });

  factory SugerenciaReordenItem.fromJson(Map<String, dynamic> json) {
    return SugerenciaReordenItem(
      sucursalId: json['sucursal_id']?.toString() ?? '',
      sucursalNombre: json['sucursal_nombre']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      existencias: int.tryParse(json['existencias']?.toString() ?? '0') ?? 0,
      minimoAlerta: int.tryParse(json['minimo_alerta']?.toString() ?? '0') ?? 0,
      avgDiaria30d: double.tryParse(json['avg_diaria_30d']?.toString() ?? '0') ?? 0.0,
      stockObjetivo: double.tryParse(json['stock_objetivo']?.toString() ?? '0') ?? 0.0,
      sugerido: int.tryParse(json['sugerido']?.toString() ?? '0') ?? 0,
    );
  }

  bool get esUrgente => sugerido > 0 && existencias <= minimoAlerta;
}

// Modelo para el resultado de redistribución
class RedistribucionResult {
  final String movimientoSalidaId;
  final String movimientoEntradaId;
  final String refaccionDestinoId;

  RedistribucionResult({
    required this.movimientoSalidaId,
    required this.movimientoEntradaId,
    required this.refaccionDestinoId,
  });

  factory RedistribucionResult.fromJson(Map<String, dynamic> json) {
    return RedistribucionResult(
      movimientoSalidaId: json['movimiento_salida_id']?.toString() ?? '',
      movimientoEntradaId: json['movimiento_entrada_id']?.toString() ?? '',
      refaccionDestinoId: json['refaccion_destino_id']?.toString() ?? '',
    );
  }
}

// Modelo para el bundle completo que retorna inventario_global_bundle
class InventarioGlobalBundle {
  final List<InventarioDetalleItem> detalle;
  final List<InventarioAlertaItem> alertas;
  final List<InventarioCaducidadItem> caducidad;
  final List<InventarioResumenItem> resumen;
  final List<RefaccionRotacionItem> rotacion;

  InventarioGlobalBundle({
    required this.detalle,
    required this.alertas,
    required this.caducidad,
    required this.resumen,
    required this.rotacion,
  });

  factory InventarioGlobalBundle.fromJson(Map<String, dynamic> json) {
    return InventarioGlobalBundle(
      detalle: (json['detalle'] as List<dynamic>? ?? [])
          .map((item) => InventarioDetalleItem.fromJson(item))
          .toList(),
      alertas: (json['alertas'] as List<dynamic>? ?? [])
          .map((item) => InventarioAlertaItem.fromJson(item))
          .toList(),
      caducidad: (json['caducidad'] as List<dynamic>? ?? [])
          .map((item) => InventarioCaducidadItem.fromJson(item))
          .toList(),
      resumen: (json['resumen'] as List<dynamic>? ?? [])
          .map((item) => InventarioResumenItem.fromJson(item))
          .toList(),
      rotacion: (json['rotacion'] as List<dynamic>? ?? [])
          .map((item) => RefaccionRotacionItem.fromJson(item))
          .toList(),
    );
  }

  // Cálculos de KPIs
  int get totalRefacciones => resumen.length;

  double get valorTotal => detalle.fold(0.0, (sum, item) => sum + item.valorTotalStock);

  int get totalSinStock => alertas.where((item) => item.sinStock).length;

  int get totalStockBajo => alertas.where((item) => item.stockBajo).length;

  int get totalPorCaducar => caducidad.length;

  int get sucursalesActivas => detalle.map((item) => item.sucursalId).toSet().length;
}