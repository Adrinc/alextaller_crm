class Cliente {
  final String id;
  final String? usuarioId;
  final String nombre;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final String? rfc;
  final String? notas;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cliente({
    required this.id,
    this.usuarioId,
    required this.nombre,
    this.correo,
    this.telefono,
    this.direccion,
    this.rfc,
    this.notas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String?,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String?,
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
      rfc: json['rfc'] as String?,
      notas: json['notas'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'rfc': rfc,
      'notas': notas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Cliente copyWith({
    String? id,
    String? usuarioId,
    String? nombre,
    String? correo,
    String? telefono,
    String? direccion,
    String? rfc,
    String? notas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cliente(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      rfc: rfc ?? this.rfc,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Cliente(id: $id, nombre: $nombre, correo: $correo, telefono: $telefono)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cliente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
