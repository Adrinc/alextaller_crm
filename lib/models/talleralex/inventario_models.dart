import 'package:intl/intl.dart';

// Modelo para vw_inventario_sucursal
class RefaccionInventario {
  final String refaccionId;
  final String sucursalId;
  final String sucursalNombre;
  final String sku;
  final String nombre;
  final String descripcion;
  final String proveedor;
  final double precioUnitario;
  final int existencias;
  final int minimoAlerta;
  final bool activo;
  final String? imagenId;
  final String? imagenPath;

  RefaccionInventario({
    required this.refaccionId,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.sku,
    required this.nombre,
    required this.descripcion,
    required this.proveedor,
    required this.precioUnitario,
    required this.existencias,
    required this.minimoAlerta,
    required this.activo,
    this.imagenId,
    this.imagenPath,
  });

  factory RefaccionInventario.fromJson(Map<String, dynamic> json) {
    return RefaccionInventario(
      refaccionId: json['refaccion_id'] as String,
      sucursalId: json['sucursal_id'] as String,
      sucursalNombre: json['sucursal_nombre'] as String,
      sku: json['sku'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      proveedor: json['proveedor'] as String,
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      existencias: json['existencias'] as int,
      minimoAlerta: json['minimo_alerta'] as int,
      activo: json['activo'] as bool,
      imagenId: json['imagen_id'] as String?,
      imagenPath: json['imagen_path'] as String?,
    );
  }

  // Getters de conveniencia
  String get precioTexto => '\$${precioUnitario.toStringAsFixed(2)}';

  String get existenciasTexto => existencias.toString();

  bool get enAlerta => existencias <= minimoAlerta;

  String get estadoTexto => activo ? 'Activo' : 'Inactivo';

  String get alertaTexto {
    if (enAlerta) {
      final diferencia = minimoAlerta - existencias;
      if (diferencia > 0) {
        return 'Faltan $diferencia unidades';
      } else {
        return 'En mínimo exacto';
      }
    }
    return 'Stock normal';
  }

  double get valorInventario => existencias * precioUnitario;

  String get valorInventarioTexto => '\$${valorInventario.toStringAsFixed(2)}';
}

// Modelo para vw_inventario_alerta
class RefaccionAlerta {
  final String refaccionId;
  final String sucursalId;
  final String sku;
  final String nombre;
  final int existencias;
  final int minimoAlerta;
  final String? imagenId;
  final String? imagenPath;

  RefaccionAlerta({
    required this.refaccionId,
    required this.sucursalId,
    required this.sku,
    required this.nombre,
    required this.existencias,
    required this.minimoAlerta,
    this.imagenId,
    this.imagenPath,
  });

  factory RefaccionAlerta.fromJson(Map<String, dynamic> json) {
    return RefaccionAlerta(
      refaccionId: json['refaccion_id'] as String,
      sucursalId: json['sucursal_id'] as String,
      sku: json['sku'] as String,
      nombre: json['nombre'] as String,
      existencias: json['existencias'] as int,
      minimoAlerta: json['minimo_alerta'] as int,
      imagenId: json['imagen_id'] as String?,
      imagenPath: json['imagen_path'] as String?,
    );
  }

  int get faltantes => minimoAlerta - existencias;

  String get faltantesTexto =>
      faltantes > 0 ? 'Faltan $faltantes' : 'En mínimo';
}

// Modelo para vw_historial_refacciones
class HistorialRefaccion {
  final String ordenRefaccionId;
  final String ordenId;
  final String numeroOrden;
  final String estadoOrden;
  final String citaId;
  final String clienteNombre;
  final String placa;
  final String marca;
  final String modelo;
  final String refaccionId;
  final String sku;
  final String refaccionNombre;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  final DateTime fechaInicio;
  final DateTime? fechaFinReal;

  HistorialRefaccion({
    required this.ordenRefaccionId,
    required this.ordenId,
    required this.numeroOrden,
    required this.estadoOrden,
    required this.citaId,
    required this.clienteNombre,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.refaccionId,
    required this.sku,
    required this.refaccionNombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.fechaInicio,
    this.fechaFinReal,
  });

  factory HistorialRefaccion.fromJson(Map<String, dynamic> json) {
    return HistorialRefaccion(
      ordenRefaccionId: json['orden_refaccion_id'] as String,
      ordenId: json['orden_id'] as String,
      numeroOrden: json['numero_orden'] as String,
      estadoOrden: json['estado_orden'] as String,
      citaId: json['cita_id'] as String,
      clienteNombre: json['cliente_nombre'] as String,
      placa: json['placa'] as String,
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      refaccionId: json['refaccion_id'] as String,
      sku: json['sku'] as String,
      refaccionNombre: json['refaccion_nombre'] as String,
      cantidad: (json['cantidad'] as num).toDouble(),
      precioUnitario: (json['precio_unitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFinReal: json['fecha_fin_real'] != null
          ? DateTime.parse(json['fecha_fin_real'] as String)
          : null,
    );
  }

  // Getters de conveniencia
  String get vehiculoTexto => '$marca $modelo ($placa)';

  String get cantidadTexto => cantidad.toStringAsFixed(0);

  String get precioTexto => '\$${precioUnitario.toStringAsFixed(2)}';

  String get subtotalTexto => '\$${subtotal.toStringAsFixed(2)}';

  String get fechaInicioTexto => DateFormat('dd/MM/yyyy').format(fechaInicio);

  String get fechaFinTexto => fechaFinReal != null
      ? DateFormat('dd/MM/yyyy').format(fechaFinReal!)
      : 'En proceso';

  bool get ordenCompletada => fechaFinReal != null;
}

// Modelo para KPIs del inventario
class KPIsInventario {
  final int totalRefacciones;
  final int refaccionesActivas;
  final int refaccionesInactivas;
  final int refaccionesEnAlerta;
  final double valorTotalInventario;
  final double promedioRotacion;
  final int movimientosUltimos30Dias;

  KPIsInventario({
    required this.totalRefacciones,
    required this.refaccionesActivas,
    required this.refaccionesInactivas,
    required this.refaccionesEnAlerta,
    required this.valorTotalInventario,
    required this.promedioRotacion,
    required this.movimientosUltimos30Dias,
  });

  // Getters de conveniencia
  String get valorTotalTexto => '\$${valorTotalInventario.toStringAsFixed(2)}';

  double get porcentajeEnAlerta =>
      totalRefacciones > 0 ? (refaccionesEnAlerta / totalRefacciones) * 100 : 0;

  String get porcentajeEnAlertaTexto =>
      '${porcentajeEnAlerta.toStringAsFixed(1)}%';

  double get porcentajeActivas =>
      totalRefacciones > 0 ? (refaccionesActivas / totalRefacciones) * 100 : 0;

  String get porcentajeActivasTexto =>
      '${porcentajeActivas.toStringAsFixed(1)}%';
}

// Modelo para crear/actualizar refacciones
class NuevaRefaccion {
  final String sku;
  final String nombre;
  final String descripcion;
  final String proveedor;
  final double precioUnitario;
  final int existencias;
  final int minimoAlerta;
  final String? imagenId;

  NuevaRefaccion({
    required this.sku,
    required this.nombre,
    required this.descripcion,
    required this.proveedor,
    required this.precioUnitario,
    required this.existencias,
    required this.minimoAlerta,
    this.imagenId,
  });

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'nombre': nombre,
      'descripcion': descripcion,
      'proveedor': proveedor,
      'precio_unitario': precioUnitario,
      'existencias': existencias,
      'minimo_alerta': minimoAlerta,
      if (imagenId != null) 'imagen_id': imagenId,
    };
  }
}

// Modelo para movimientos de inventario
class MovimientoInventario {
  final String refaccionId;
  final String tipo; // 'entrada', 'salida', 'ajuste'
  final int cantidad;
  final String? motivo;
  final String? ordenId;

  MovimientoInventario({
    required this.refaccionId,
    required this.tipo,
    required this.cantidad,
    this.motivo,
    this.ordenId,
  });

  Map<String, dynamic> toJson() {
    return {
      'refaccion_id': refaccionId,
      'tipo': tipo,
      'cantidad': cantidad,
      if (motivo != null) 'motivo': motivo,
      if (ordenId != null) 'orden_id': ordenId,
    };
  }
}

// Modelo para vw_historial_movimientos_inventario (vista de historial completo)
class HistorialMovimientoInventario {
  final String movimientoId;
  final String refaccionId;
  final String sku;
  final String nombreRefaccion;
  final String tipoMovimiento;
  final int cantidad;
  final int stockAnterior;
  final int stockActual;
  final String? usuario;
  final DateTime fechaMovimiento;
  final String? motivo;
  final String? imagenPath;

  HistorialMovimientoInventario({
    required this.movimientoId,
    required this.refaccionId,
    required this.sku,
    required this.nombreRefaccion,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.stockAnterior,
    required this.stockActual,
    this.usuario,
    required this.fechaMovimiento,
    this.motivo,
    this.imagenPath,
  });

  factory HistorialMovimientoInventario.fromJson(Map<String, dynamic> json) {
    return HistorialMovimientoInventario(
      movimientoId: json['movimiento_id'] as String,
      refaccionId: json['refaccion_id'] as String,
      sku: json['sku'] as String,
      nombreRefaccion: json['nombre_refaccion'] as String,
      tipoMovimiento: json['tipo_movimiento'] as String,
      cantidad: json['cantidad'] as int,
      stockAnterior: json['stock_anterior'] as int,
      stockActual: json['stock_actual'] as int,
      usuario: json['usuario'] as String?,
      fechaMovimiento: DateTime.parse(json['fecha_movimiento'] as String),
      motivo: json['motivo'] as String?,
      imagenPath: json['imagen_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movimiento_id': movimientoId,
      'refaccion_id': refaccionId,
      'sku': sku,
      'nombre_refaccion': nombreRefaccion,
      'tipo_movimiento': tipoMovimiento,
      'cantidad': cantidad,
      'stock_anterior': stockAnterior,
      'stock_actual': stockActual,
      if (usuario != null) 'usuario': usuario,
      'fecha_movimiento': fechaMovimiento.toIso8601String(),
      if (motivo != null) 'motivo': motivo,
      if (imagenPath != null) 'imagen_path': imagenPath,
    };
  }

  // Getters de conveniencia
  String get fechaTexto =>
      '${fechaMovimiento.day.toString().padLeft(2, '0')}/${fechaMovimiento.month.toString().padLeft(2, '0')}/${fechaMovimiento.year}';

  String get horaTexto =>
      '${fechaMovimiento.hour.toString().padLeft(2, '0')}:${fechaMovimiento.minute.toString().padLeft(2, '0')}';

  String get fechaHoraTexto => '$fechaTexto $horaTexto';

  String get cantidadTexto {
    String signo = '';
    if (tipoMovimiento.toLowerCase() == 'entrada') {
      signo = '+';
    } else if (tipoMovimiento.toLowerCase() == 'salida') {
      signo = '-';
    }
    return '$signo$cantidad';
  }

  String get tipoTexto {
    switch (tipoMovimiento.toLowerCase()) {
      case 'entrada':
        return 'Entrada';
      case 'salida':
        return 'Salida';
      case 'ajuste':
        return 'Ajuste';
      default:
        return tipoMovimiento;
    }
  }
}
