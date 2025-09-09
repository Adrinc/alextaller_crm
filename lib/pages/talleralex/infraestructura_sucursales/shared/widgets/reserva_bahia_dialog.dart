import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/agenda_bahias_provider.dart';
import 'package:nethive_neo/models/talleralex/bahias_models.dart';

class ReservaBahiaDialog extends StatefulWidget {
  final OcupacionBahia ocupacion;
  final String sucursalId;

  const ReservaBahiaDialog({
    super.key,
    required this.ocupacion,
    required this.sucursalId,
  });

  @override
  State<ReservaBahiaDialog> createState() => _ReservaBahiaDialogState();
}

class _ReservaBahiaDialogState extends State<ReservaBahiaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _vehiculoController = TextEditingController();

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  String _tipoServicio = 'diagnostico';

  final Map<String, Duration> _duracionesServicios = {
    'diagnostico': const Duration(hours: 1),
    'mantenimiento': const Duration(hours: 2),
    'reparacion': const Duration(hours: 4),
    'revision': const Duration(minutes: 30),
  };

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = DateTime.now();
    _horaInicio = const TimeOfDay(hour: 9, minute: 0);
    _horaFin = const TimeOfDay(hour: 10, minute: 0);
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _vehiculoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: const Offset(-12, -12),
              blurRadius: 24,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.4),
              offset: const Offset(12, 12),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, theme.secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_task,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservar Bahía',
                          style: theme.title2.override(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.ocupacion.bahiaNombre,
                          style: theme.bodyText1.override(
                            fontFamily: 'Poppins',
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Información del cliente
              Text(
                'Información del Cliente',
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _clienteController,
                      label: 'Nombre del Cliente',
                      hint: 'Ingrese el nombre completo',
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _vehiculoController,
                      label: 'Vehículo',
                      hint: 'Marca, modelo, año',
                      theme: theme,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Información del servicio
              Text(
                'Detalles del Servicio',
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Tipo de servicio
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Servicio',
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _tipoServicio,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'diagnostico',
                          child:
                              Text('Diagnóstico (1h)', style: theme.bodyText1),
                        ),
                        DropdownMenuItem(
                          value: 'mantenimiento',
                          child: Text('Mantenimiento (2h)',
                              style: theme.bodyText1),
                        ),
                        DropdownMenuItem(
                          value: 'reparacion',
                          child:
                              Text('Reparación (4h)', style: theme.bodyText1),
                        ),
                        DropdownMenuItem(
                          value: 'revision',
                          child:
                              Text('Revisión (30min)', style: theme.bodyText1),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _tipoServicio = value!;
                          _actualizarHoraFin();
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Fecha y hora
              Row(
                children: [
                  Expanded(
                    child: _buildDateSelector(theme),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeSelector(theme),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Estado de la reserva
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.ocupacion.estado == EstadoBahia.libre
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.ocupacion.estado == EstadoBahia.libre
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.ocupacion.estado == EstadoBahia.libre
                          ? Icons.check_circle
                          : Icons.warning,
                      color: widget.ocupacion.estado == EstadoBahia.libre
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.ocupacion.estado == EstadoBahia.libre
                                ? 'Bahía Disponible'
                                : 'Bahía Parcialmente Ocupada',
                            style: theme.bodyText1.override(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Ocupación actual: ${widget.ocupacion.porcentajeOcupacion.toStringAsFixed(0)}%',
                            style: theme.bodyText2.override(
                              fontFamily: 'Poppins',
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Cancelar',
                      Icons.close,
                      Colors.grey.shade600,
                      () => Navigator.of(context).pop(),
                      theme,
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer<AgendaBahiasProvider>(
                      builder: (context, provider, child) {
                        return _buildActionButton(
                          provider.isReservando
                              ? 'Reservando...'
                              : 'Confirmar Reserva',
                          Icons.check,
                          theme.primaryColor,
                          provider.isReservando ? null : _confirmarReserva,
                          theme,
                          isPrimary: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required AppTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es requerido';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fecha',
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _seleccionarFecha,
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: theme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatearFecha(_fechaSeleccionada!),
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horario',
            style: theme.bodyText2.override(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _seleccionarHoraInicio,
                  child: Row(
                    children: [
                      Icon(Icons.access_time,
                          color: theme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _horaInicio!.format(context),
                        style: theme.bodyText1.override(fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
              ),
              const Text(' - '),
              Expanded(
                child: Text(
                  _horaFin!.format(context),
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    color: theme.secondaryText,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
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
    AppTheme theme, {
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary && onPressed != null
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : null,
          color: isPrimary ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                color: isPrimary ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de utilidad
  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _seleccionarHoraInicio() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaInicio!,
    );

    if (hora != null) {
      setState(() {
        _horaInicio = hora;
        _actualizarHoraFin();
      });
    }
  }

  void _actualizarHoraFin() {
    final duracion = _duracionesServicios[_tipoServicio]!;
    final inicioMinutos = _horaInicio!.hour * 60 + _horaInicio!.minute;
    final finMinutos = inicioMinutos + duracion.inMinutes;

    setState(() {
      _horaFin = TimeOfDay(
        hour: (finMinutos ~/ 60) % 24,
        minute: finMinutos % 60,
      );
    });
  }

  void _confirmarReserva() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AgendaBahiasProvider>();

    final inicioDateTime = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaInicio!.hour,
      _horaInicio!.minute,
    );

    final finDateTime = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaFin!.hour,
      _horaFin!.minute,
    );

    final request = ReservaBahiaRequest(
      citaId:
          'temp-cita-id', // En un caso real, esto vendría de una cita existente
      bahiaId: widget.ocupacion.bahiaId,
      inicio: inicioDateTime,
      fin: finDateTime,
    );

    // Validar la reserva
    final error = provider.validarReserva(request);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await provider.reservarBahia(request);

    if (success) {
      Navigator.of(context).pop(true); // Devolver true para indicar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bahía reservada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al reservar bahía'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dias = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];

    return '${dias[fecha.weekday % 7]} ${fecha.day} de ${meses[fecha.month - 1]}';
  }
}
