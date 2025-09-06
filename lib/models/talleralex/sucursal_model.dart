class Sucursal {
  final String id;
  final String nombre;
  final String? direccion;
  final String? telefono;
  final String? emailContacto; // Cambiado de correo a emailContacto
  final double? lat; // Cambiado de latitud a lat
  final double? lng; // Cambiado de longitud a lng
  final int? capacidadBahias; // Nuevo campo
  final String? imagenUrl; // Nuevo campo
  final bool activa;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sucursal({
    required this.id,
    required this.nombre,
    this.direccion,
    this.telefono,
    this.emailContacto,
    this.lat,
    this.lng,
    this.capacidadBahias,
    this.imagenUrl,
    required this.activa,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String?,
      telefono: json['telefono'] as String?,
      emailContacto: json['email_contacto'] as String?,
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      capacidadBahias: json['capacidad_bahias'] as int?,
      imagenUrl: json['imagen_url'] as String?,
      activa: json['activa'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email_contacto': emailContacto,
      'lat': lat,
      'lng': lng,
      'capacidad_bahias': capacidadBahias,
      'imagen_url': imagenUrl,
      'activa': activa,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Sucursal copyWith({
    String? id,
    String? nombre,
    String? direccion,
    String? telefono,
    String? emailContacto,
    double? lat,
    double? lng,
    int? capacidadBahias,
    String? imagenUrl,
    bool? activa,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sucursal(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      emailContacto: emailContacto ?? this.emailContacto,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      capacidadBahias: capacidadBahias ?? this.capacidadBahias,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      activa: activa ?? this.activa,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Sucursal(id: $id, nombre: $nombre, direccion: $direccion, activa: $activa)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sucursal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
