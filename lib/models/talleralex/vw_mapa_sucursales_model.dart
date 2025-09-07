class VwMapaSucursales {
  final String sucursalId;
  final String nombre;
  final String? imagenUrl;
  final String? direccion;
  final double? lat;
  final double? lng;
  final int empleadosActivos;
  final int reportesTotales;
  final int citasHoy;
  final String? telefono;
  final String? emailContacto;
  final int capacidadBahias;

  VwMapaSucursales({
    required this.sucursalId,
    required this.nombre,
    this.imagenUrl,
    this.direccion,
    this.lat,
    this.lng,
    required this.empleadosActivos,
    required this.reportesTotales,
    required this.citasHoy,
    this.telefono,
    this.emailContacto,
    required this.capacidadBahias,
  });

  factory VwMapaSucursales.fromJson(Map<String, dynamic> json) {
    return VwMapaSucursales(
      sucursalId: json['sucursal_id'] as String,
      nombre: json['sucursal_nombre'] as String,
      imagenUrl: json['imagen_url'] as String?,
      direccion: json['direccion'] as String?,
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      empleadosActivos: json['empleados_activos'] as int? ?? 0,
      reportesTotales: json['reportes_totales'] as int? ?? 0,
      citasHoy: json['citas_hoy'] as int? ?? 0,
      telefono: json['telefono'] as String?,
      emailContacto: json['email_contacto'] as String?,
      capacidadBahias: json['capacidad_bahias'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucursal_id': sucursalId,
      'sucursal_nombre': nombre,
      'imagen_url': imagenUrl,
      'direccion': direccion,
      'lat': lat,
      'lng': lng,
      'empleados_activos': empleadosActivos,
      'reportes_totales': reportesTotales,
      'citas_hoy': citasHoy,
      'telefono': telefono,
      'email_contacto': emailContacto,
      'capacidad_bahias': capacidadBahias,
    };
  }

  @override
  String toString() {
    return 'VwMapaSucursales(sucursalId: $sucursalId, nombre: $nombre, empleadosActivos: $empleadosActivos, citasHoy: $citasHoy, capacidadBahias: $capacidadBahias)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VwMapaSucursales && other.sucursalId == sucursalId;
  }

  @override
  int get hashCode => sucursalId.hashCode;
}
