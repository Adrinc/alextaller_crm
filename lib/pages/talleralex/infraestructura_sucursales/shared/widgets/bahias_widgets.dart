import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/models/talleralex/bahias_models.dart';

class BahiaMetricaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String? subtitulo;
  final IconData icono;
  final Color color;
  final VoidCallback? onTap;

  const BahiaMetricaCard({
    super.key,
    required this.titulo,
    required this.valor,
    this.subtitulo,
    required this.icono,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: const Offset(-8, -8),
              blurRadius: 16,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.4),
              offset: const Offset(8, 8),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icono,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: theme.secondaryText,
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              valor,
              style: theme.title1.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                color: theme.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitulo!,
                style: theme.bodyText2.override(
                  fontFamily: 'Poppins',
                  color: theme.secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BahiaEstadoCard extends StatelessWidget {
  final OcupacionBahia ocupacion;
  final List<ReservaBahia> reservas;
  final VoidCallback? onTap;
  final VoidCallback? onReservar;

  const BahiaEstadoCard({
    super.key,
    required this.ocupacion,
    required this.reservas,
    this.onTap,
    this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colorEstado = _getColorEstado(ocupacion.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-6, -6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(6, 6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la bahía
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.garage,
                  color: colorEstado,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ocupacion.bahiaNombre,
                      style: theme.bodyText1.override(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: theme.primaryText,
                      ),
                    ),
                    Text(
                      ocupacion.estadoTexto,
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: colorEstado,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${ocupacion.porcentajeOcupacion.toStringAsFixed(0)}%',
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: colorEstado,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Barra de progreso de ocupación
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ocupacion.porcentajeOcupacion / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorEstado.withOpacity(0.7),
                      colorEstado,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Información de tiempos
          Row(
            children: [
              Expanded(
                child: _buildTiempoInfo(
                  'Ocupado',
                  ocupacion.tiempoOcupado,
                  colorEstado,
                  theme,
                ),
              ),
              Expanded(
                child: _buildTiempoInfo(
                  'Disponible',
                  ocupacion.tiempoDisponible,
                  Colors.green,
                  theme,
                ),
              ),
              Expanded(
                child: _buildTiempoInfo(
                  'Reservas',
                  '${ocupacion.reservasHoy}',
                  theme.primaryColor,
                  theme,
                ),
              ),
            ],
          ),

          if (reservas.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Próximas reservas:',
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: theme.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...reservas
                .take(2)
                .map((reserva) => _buildReservaItem(reserva, theme)),
          ],

          const SizedBox(height: 12),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Ver Detalles',
                  Icons.visibility,
                  theme.primaryColor,
                  onTap,
                  theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  'Reservar',
                  Icons.add,
                  theme.secondaryColor,
                  onReservar,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTiempoInfo(
      String label, String valor, Color color, AppTheme theme) {
    return Column(
      children: [
        Text(
          valor,
          style: theme.bodyText1.override(
            fontFamily: 'Poppins',
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.bodyText2.override(
            fontFamily: 'Poppins',
            color: theme.secondaryText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildReservaItem(ReservaBahia reserva, AppTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: theme.secondaryText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reserva.horarioFormateado,
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${reserva.clienteNombre} - ${reserva.vehiculo}',
                  style: theme.bodyText2.override(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
    AppTheme theme,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorEstado(EstadoBahia estado) {
    switch (estado) {
      case EstadoBahia.libre:
        return Colors.green;
      case EstadoBahia.parcial:
        return Colors.blue;
      case EstadoBahia.ocupada:
        return Colors.orange;
      case EstadoBahia.casiCompleta:
        return Colors.deepOrange;
      case EstadoBahia.completa:
        return Colors.red;
    }
  }
}

class BahiaTimelineView extends StatelessWidget {
  final List<ReservaBahia> reservas;
  final String bahiaId;
  final DateTime fecha;

  const BahiaTimelineView({
    super.key,
    required this.reservas,
    required this.bahiaId,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final reservasBahia = reservas.where((r) => r.bahiaId == bahiaId).toList();

    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            // Línea de tiempo base
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 26),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Bloques de reservas
            ...reservasBahia.map((reserva) =>
                _buildReservaBlock(reserva, theme, constraints.maxWidth)),
          ],
        ),
      ),
    );
  }

  Widget _buildReservaBlock(
      ReservaBahia reserva, AppTheme theme, double maxWidth) {
    // Calcular posición y ancho basado en las horas (8:00 - 18:00 = 10 horas)
    final inicioJornada = DateTime(fecha.year, fecha.month, fecha.day, 8, 0);
    final finJornada = DateTime(fecha.year, fecha.month, fecha.day, 18, 0);
    final duracionJornada = finJornada.difference(inicioJornada).inMinutes;

    final inicioReserva = reserva.inicio.difference(inicioJornada).inMinutes;
    final duracionReserva = reserva.duracion.inMinutes;

    final left = (inicioReserva / duracionJornada) * maxWidth;
    final width = (duracionReserva / duracionJornada) * maxWidth;

    Color colorEstado;
    switch (reserva.estadoCita) {
      case 'confirmada':
        colorEstado = Colors.green;
        break;
      case 'en_proceso':
        colorEstado = Colors.blue;
        break;
      case 'completada':
        colorEstado = Colors.purple;
        break;
      case 'no_asistio':
        colorEstado = Colors.red;
        break;
      default:
        colorEstado = Colors.orange;
    }

    return Positioned(
      left: left.clamp(0.0, maxWidth - 20),
      width: width.clamp(20.0, maxWidth - left.clamp(0.0, maxWidth - 20)),
      top: 22,
      height: 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorEstado,
              colorEstado.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            reserva.tiempoFormateado,
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class OcupacionChart extends StatelessWidget {
  final List<OcupacionBahia> ocupaciones;

  const OcupacionChart({
    super.key,
    required this.ocupaciones,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    if (ocupaciones.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No hay datos de ocupación',
            style: theme.bodyText1.override(
              fontFamily: 'Poppins',
              color: theme.secondaryText,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-8, -8),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.4),
            offset: const Offset(8, 8),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sections: _generateSections(ocupaciones, theme),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateSections(
      List<OcupacionBahia> ocupaciones, AppTheme theme) {
    final Map<EstadoBahia, int> conteos = {};

    for (final ocupacion in ocupaciones) {
      conteos[ocupacion.estado] = (conteos[ocupacion.estado] ?? 0) + 1;
    }

    return conteos.entries.map((entry) {
      final estado = entry.key;
      final count = entry.value;
      final percentage = (count / ocupaciones.length) * 100;

      Color color;
      String title;

      switch (estado) {
        case EstadoBahia.libre:
          color = Colors.green;
          title = 'Libres';
          break;
        case EstadoBahia.parcial:
          color = Colors.blue;
          title = 'Parciales';
          break;
        case EstadoBahia.ocupada:
          color = Colors.orange;
          title = 'Ocupadas';
          break;
        case EstadoBahia.casiCompleta:
          color = Colors.deepOrange;
          title = 'Casi Completas';
          break;
        case EstadoBahia.completa:
          color = Colors.red;
          title = 'Completas';
          break;
      }

      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '$title\n${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: theme.bodyText2.override(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }
}
