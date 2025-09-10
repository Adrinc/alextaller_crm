import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/empleados_provider.dart';
import 'package:nethive_neo/models/talleralex/empleados_models.dart';

class ProgramarTurnoDialog extends StatefulWidget {
  final EmpleadoGrid empleado;
  final String sucursalId;
  final VoidCallback onTurnoProgramado;

  const ProgramarTurnoDialog({
    super.key,
    required this.empleado,
    required this.sucursalId,
    required this.onTurnoProgramado,
  });

  @override
  State<ProgramarTurnoDialog> createState() => _ProgramarTurnoDialogState();
}

class _ProgramarTurnoDialogState extends State<ProgramarTurnoDialog> {
  final _formKey = GlobalKey<FormState>();

  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _horaFin = const TimeOfDay(hour: 17, minute: 0);
  TipoTurnoEmpleado _tipoTurno = TipoTurnoEmpleado.normal;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con gradiente
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.secondaryColor,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.schedule,
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
                          'Programar Turno',
                          style: theme.title3.override(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.empleado.empleadoNombre,
                          style: theme.bodyText1.override(
                            fontFamily: 'Poppins',
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Contenido del formulario
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fecha
                      _buildSectionTitle('Fecha del turno'),
                      const SizedBox(height: 12),
                      _buildDateSelector(theme),

                      const SizedBox(height: 24),

                      // Horarios
                      _buildSectionTitle('Horarios'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _buildTimeSelector(
                                  theme,
                                  'Inicio',
                                  _horaInicio,
                                  (time) =>
                                      setState(() => _horaInicio = time))),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildTimeSelector(theme, 'Fin', _horaFin,
                                  (time) => setState(() => _horaFin = time))),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tipo de turno
                      _buildSectionTitle('Tipo de turno'),
                      const SizedBox(height: 12),
                      _buildTipoTurnoSelector(theme),

                      const SizedBox(height: 24),

                      // Información adicional
                      _buildInfoCard(theme),
                    ],
                  ),
                ),
              ),
            ),

            // Botones de acción
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancelar',
                      style: theme.bodyText1.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: _isLoading ? null : _programarTurno,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Programar Turno',
                              style: theme.bodyText1.override(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = AppTheme.of(context);
    return Text(
      title,
      style: theme.bodyText1.override(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: theme.primaryText,
      ),
    );
  }

  Widget _buildDateSelector(AppTheme theme) {
    return InkWell(
      onTap: _seleccionarFecha,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  color: theme.primaryText,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(AppTheme theme, String label, TimeOfDay time,
      Function(TimeOfDay) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.bodyText2.override(
            fontFamily: 'Poppins',
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _seleccionarHora(time, onChanged),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    time.format(context),
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      color: theme.primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipoTurnoSelector(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: TipoTurnoEmpleado.values.map((tipo) {
          return RadioListTile<TipoTurnoEmpleado>(
            value: tipo,
            groupValue: _tipoTurno,
            onChanged: (value) => setState(() => _tipoTurno = value!),
            title: Text(
              tipo.displayName,
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                color: theme.primaryText,
              ),
            ),
            activeColor: theme.primaryColor,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoCard(AppTheme theme) {
    final inicioDateTime = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      _horaInicio.hour,
      _horaInicio.minute,
    );

    final finDateTime = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      _horaFin.hour,
      _horaFin.minute,
    );

    final duracion = finDateTime.difference(inicioDateTime);
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen del turno',
                style: theme.bodyText1.override(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Empleado:', widget.empleado.empleadoNombre),
          _buildInfoRow('Puesto:', widget.empleado.puesto.displayName),
          _buildInfoRow('Fecha:',
              '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}'),
          _buildInfoRow('Horario:',
              '${_horaInicio.format(context)} - ${_horaFin.format(context)}'),
          _buildInfoRow('Duración:', '$horas hrs ${minutos}min'),
          _buildInfoRow('Tipo:', _tipoTurno.displayName),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: theme.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.bodyText2.override(
                fontFamily: 'Poppins',
                color: theme.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaSeleccionada = fechaSeleccionada;
      });
    }
  }

  Future<void> _seleccionarHora(
      TimeOfDay horaActual, Function(TimeOfDay) onChanged) async {
    final horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: horaActual,
    );

    if (horaSeleccionada != null) {
      onChanged(horaSeleccionada);
    }
  }

  Future<void> _programarTurno() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar que la hora de fin sea mayor que la de inicio
    final inicioDateTime = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      _horaInicio.hour,
      _horaInicio.minute,
    );

    final finDateTime = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      _horaFin.hour,
      _horaFin.minute,
    );

    if (finDateTime.isBefore(inicioDateTime) ||
        finDateTime.isAtSameMomentAs(inicioDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de fin debe ser mayor que la hora de inicio'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<EmpleadosProvider>().programarTurno(
            widget.empleado.empleadoId,
            inicioDateTime,
            finDateTime,
            _tipoTurno,
          );

      if (success && mounted) {
        widget.onTurnoProgramado();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Turno programado correctamente para ${widget.empleado.empleadoNombre}'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al programar el turno'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
