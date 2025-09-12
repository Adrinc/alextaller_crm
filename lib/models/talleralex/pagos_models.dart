// Modelo para vw_pagos_detalle
class PagoDetalle {
  final String pagoId;
  final DateTime fechaPago;
  final double monto;
  final String moneda;
  final String metodo;
  final String estado;
  final String sucursalId;
  final String sucursalNombre;
  final String ordenId;
  final String numeroOrden;
  final String clienteId;
  final String clienteNombre;
  final String? clienteRfc;
  final String vehiculoId;
  final String placa;
  final String marca;
  final String modelo;
  final String? facturaId;
  final String? facturaFolio;
  final DateTime? facturaFecha;
  final String? pdfUrl;
  final String? xmlUrl;

  PagoDetalle({
    required this.pagoId,
    required this.fechaPago,
    required this.monto,
    required this.moneda,
    required this.metodo,
    required this.estado,
    required this.sucursalId,
    required this.sucursalNombre,
    required this.ordenId,
    required this.numeroOrden,
    required this.clienteId,
    required this.clienteNombre,
    this.clienteRfc,
    required this.vehiculoId,
    required this.placa,
    required this.marca,
    required this.modelo,
    this.facturaId,
    this.facturaFolio,
    this.facturaFecha,
    this.pdfUrl,
    this.xmlUrl,
  });

  factory PagoDetalle.fromJson(Map<String, dynamic> json) {
    return PagoDetalle(
      pagoId: json['pago_id'] as String,
      fechaPago: DateTime.parse(json['fecha_pago'] as String),
      monto: (json['monto'] as num).toDouble(),
      moneda: json['moneda'] as String,
      metodo: json['metodo'] as String,
      estado: json['estado'] as String,
      sucursalId: json['sucursal_id'] as String,
      sucursalNombre: json['sucursal_nombre'] as String,
      ordenId: json['orden_id'] as String,
      numeroOrden: json['numero_orden'] as String,
      clienteId: json['cliente_id'] as String,
      clienteNombre: json['cliente_nombre'] as String,
      clienteRfc: json['cliente_rfc'] as String?,
      vehiculoId: json['vehiculo_id'] as String,
      placa: json['placa'] as String,
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      facturaId: json['factura_id'] as String?,
      facturaFolio: json['factura_folio'] as String?,
      facturaFecha: json['factura_fecha'] != null
          ? DateTime.parse(json['factura_fecha'] as String)
          : null,
      pdfUrl: json['pdf_url'] as String?,
      xmlUrl: json['xml_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pago_id': pagoId,
      'fecha_pago': fechaPago.toIso8601String(),
      'monto': monto,
      'moneda': moneda,
      'metodo': metodo,
      'estado': estado,
      'sucursal_id': sucursalId,
      'sucursal_nombre': sucursalNombre,
      'orden_id': ordenId,
      'numero_orden': numeroOrden,
      'cliente_id': clienteId,
      'cliente_nombre': clienteNombre,
      if (clienteRfc != null) 'cliente_rfc': clienteRfc,
      'vehiculo_id': vehiculoId,
      'placa': placa,
      'marca': marca,
      'modelo': modelo,
      if (facturaId != null) 'factura_id': facturaId,
      if (facturaFolio != null) 'factura_folio': facturaFolio,
      if (facturaFecha != null)
        'factura_fecha': facturaFecha!.toIso8601String(),
      if (pdfUrl != null) 'pdf_url': pdfUrl,
      if (xmlUrl != null) 'xml_url': xmlUrl,
    };
  }

  // Getters de conveniencia
  String get fechaTexto =>
      '${fechaPago.day.toString().padLeft(2, '0')}/${fechaPago.month.toString().padLeft(2, '0')}/${fechaPago.year}';

  String get horaTexto =>
      '${fechaPago.hour.toString().padLeft(2, '0')}:${fechaPago.minute.toString().padLeft(2, '0')}';

  String get fechaHoraTexto => '$fechaTexto $horaTexto';

  String get montoTexto => '\$${monto.toStringAsFixed(2)} $moneda';

  String get vehiculoTexto => '$marca $modelo ($placa)';

  String get metodoTexto {
    switch (metodo.toLowerCase()) {
      case 'efectivo':
        return 'Efectivo';
      case 'tarjeta':
        return 'Tarjeta';
      case 'transferencia':
        return 'Transferencia';
      case 'cheque':
        return 'Cheque';
      default:
        return metodo;
    }
  }

  String get estadoTexto {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'pagado':
        return 'Pagado';
      case 'fallido':
        return 'Fallido';
      case 'reembolsado':
        return 'Reembolsado';
      case 'parcial':
        return 'Parcial';
      default:
        return estado;
    }
  }

  bool get tieneFactura => facturaId != null && facturaFolio != null;

  String get facturaTexto => tieneFactura ? facturaFolio! : 'Sin factura';

  String get facturaFechaTexto {
    if (facturaFecha == null) return '';
    return '${facturaFecha!.day.toString().padLeft(2, '0')}/${facturaFecha!.month.toString().padLeft(2, '0')}/${facturaFecha!.year}';
  }

  bool get esPagado => estado.toLowerCase() == 'pagado';
  bool get esPendiente => estado.toLowerCase() == 'pendiente';
  bool get esFallido => estado.toLowerCase() == 'fallido';
  bool get esReembolsado => estado.toLowerCase() == 'reembolsado';
  bool get esParcial => estado.toLowerCase() == 'parcial';
}

// Modelo para vw_pagos_totales_sucursal
class PagosTotalesSucursal {
  final String sucursalId;
  final String sucursalNombre;
  final DateTime fecha;
  final int cantidadPagos;
  final double totalPagado;
  final double totalPendiente;
  final double totalFallido;

  PagosTotalesSucursal({
    required this.sucursalId,
    required this.sucursalNombre,
    required this.fecha,
    required this.cantidadPagos,
    required this.totalPagado,
    required this.totalPendiente,
    required this.totalFallido,
  });

  factory PagosTotalesSucursal.fromJson(Map<String, dynamic> json) {
    return PagosTotalesSucursal(
      sucursalId: json['sucursal_id'] as String,
      sucursalNombre: json['sucursal_nombre'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      cantidadPagos: json['cantidad_pagos'] as int,
      totalPagado: (json['total_pagado'] as num).toDouble(),
      totalPendiente: (json['total_pendiente'] as num).toDouble(),
      totalFallido: (json['total_fallido'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucursal_id': sucursalId,
      'sucursal_nombre': sucursalNombre,
      'fecha': fecha.toIso8601String(),
      'cantidad_pagos': cantidadPagos,
      'total_pagado': totalPagado,
      'total_pendiente': totalPendiente,
      'total_fallido': totalFallido,
    };
  }

  // Getters de conveniencia
  String get fechaTexto =>
      '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  String get totalPagadoTexto => '\$${totalPagado.toStringAsFixed(2)}';
  String get totalPendienteTexto => '\$${totalPendiente.toStringAsFixed(2)}';
  String get totalFallidoTexto => '\$${totalFallido.toStringAsFixed(2)}';
  double get totalGeneral => totalPagado + totalPendiente + totalFallido;
  String get totalGeneralTexto => '\$${totalGeneral.toStringAsFixed(2)}';
}

// Modelo para KPIs de pagos
class KPIsPagos {
  final double totalPagadoHoy;
  final double totalPagadoMes;
  final double totalPendiente;
  final int facturasPendientes;
  final int facturasEmitidas;
  final double porcentajeFacturado;
  final int totalPagosHoy;
  final int totalPagosMes;

  KPIsPagos({
    required this.totalPagadoHoy,
    required this.totalPagadoMes,
    required this.totalPendiente,
    required this.facturasPendientes,
    required this.facturasEmitidas,
    required this.porcentajeFacturado,
    required this.totalPagosHoy,
    required this.totalPagosMes,
  });

  // Getters de conveniencia
  String get totalPagadoHoyTexto => '\$${totalPagadoHoy.toStringAsFixed(2)}';
  String get totalPagadoMesTexto => '\$${totalPagadoMes.toStringAsFixed(2)}';
  String get totalPendienteTexto => '\$${totalPendiente.toStringAsFixed(2)}';
  String get porcentajeFacturadoTexto =>
      '${porcentajeFacturado.toStringAsFixed(1)}%';
}

// Modelo para crear nuevo pago
class CrearPago {
  final String ordenId;
  final String clienteId;
  final double monto;
  final String moneda;
  final String metodo;
  final String? externoId;

  CrearPago({
    required this.ordenId,
    required this.clienteId,
    required this.monto,
    required this.moneda,
    required this.metodo,
    this.externoId,
  });

  Map<String, dynamic> toJson() {
    return {
      'orden_id': ordenId,
      'cliente_id': clienteId,
      'monto': monto,
      'moneda': moneda,
      'metodo': metodo,
      'estado': 'pendiente',
      'fecha_pago': DateTime.now().toIso8601String(),
      if (externoId != null) 'externo_id': externoId,
    };
  }
}

// Modelo para actualizar estado de pago
class ActualizarPago {
  final String pagoId;
  final String? estado;
  final String? externoId;
  final DateTime? fechaPago;

  ActualizarPago({
    required this.pagoId,
    this.estado,
    this.externoId,
    this.fechaPago,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (estado != null) data['estado'] = estado;
    if (externoId != null) data['externo_id'] = externoId;
    if (fechaPago != null) data['fecha_pago'] = fechaPago!.toIso8601String();
    return data;
  }
}

// Modelo para crear factura
class CrearFactura {
  final String pagoId;
  final String folio;
  final String? pdfUrl;
  final String? xmlUrl;

  CrearFactura({
    required this.pagoId,
    required this.folio,
    this.pdfUrl,
    this.xmlUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'pago_id': pagoId,
      'folio': folio,
      'fecha_emision': DateTime.now().toIso8601String(),
      if (pdfUrl != null) 'pdf_url': pdfUrl,
      if (xmlUrl != null) 'xml_url': xmlUrl,
    };
  }
}
