class Vehiculo {
  final String id;
  final String clienteId;
  final String placa;
  final String marca;
  final String modelo;
  final int anio;
  final String? color;
  final String? numeroSerie;
  final String? tipoMotor;
  final String? transmision;
  final int? kilometraje;
  final String? notas;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehiculo({
    required this.id,
    required this.clienteId,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    this.color,
    this.numeroSerie,
    this.tipoMotor,
    this.transmision,
    this.kilometraje,
    this.notas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'] as String,
      clienteId: json['cliente_id'] as String,
      placa: json['placa'] as String,
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      anio: json['anio'] as int,
      color: json['color'] as String?,
      numeroSerie: json['numero_serie'] as String?,
      tipoMotor: json['tipo_motor'] as String?,
      transmision: json['transmision'] as String?,
      kilometraje: json['kilometraje'] as int?,
      notas: json['notas'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'placa': placa,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'color': color,
      'numero_serie': numeroSerie,
      'tipo_motor': tipoMotor,
      'transmision': transmision,
      'kilometraje': kilometraje,
      'notas': notas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Vehiculo copyWith({
    String? id,
    String? clienteId,
    String? placa,
    String? marca,
    String? modelo,
    int? anio,
    String? color,
    String? numeroSerie,
    String? tipoMotor,
    String? transmision,
    int? kilometraje,
    String? notas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      placa: placa ?? this.placa,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      color: color ?? this.color,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      tipoMotor: tipoMotor ?? this.tipoMotor,
      transmision: transmision ?? this.transmision,
      kilometraje: kilometraje ?? this.kilometraje,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get descripcionCompleta => '$marca $modelo ($anio)';
  String get identificacion => '$placa - $descripcionCompleta';

  @override
  String toString() {
    return 'Vehiculo(id: $id, placa: $placa, marca: $marca, modelo: $modelo, anio: $anio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vehiculo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
