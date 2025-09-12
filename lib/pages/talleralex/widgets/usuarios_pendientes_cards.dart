import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/usuarios_pendientes_provider.dart';
import 'package:nethive_neo/models/talleralex/usuarios_pendientes_models.dart';

class UsuariosPendientesCards extends StatelessWidget {
  final UsuariosPendientesProvider provider;

  const UsuariosPendientesCards({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Consumer<UsuariosPendientesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar usuarios',
                    style: theme.title3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: theme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.usuarios.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: theme.secondaryText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Excelente!',
                    style: theme.title2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay usuarios pendientes de aprobación',
                    style: theme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.usuariosFiltrados.length,
          itemBuilder: (context, index) {
            final usuario = provider.usuariosFiltrados[index];
            return _UsuarioCard(
              usuario: usuario,
              provider: provider,
            );
          },
        );
      },
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  final UsuarioPendienteGrid usuario;
  final UsuariosPendientesProvider provider;

  const _UsuarioCard({
    required this.usuario,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    Color estadoColor = theme.primaryColor;
    IconData estadoIcon = Icons.hourglass_empty;
    Color tiempoColor = theme.primaryText;

    switch (usuario.estado.toLowerCase()) {
      case 'pendiente':
        estadoColor = Colors.orange;
        estadoIcon = Icons.hourglass_empty;
        break;
      case 'aprobado':
        estadoColor = Colors.green;
        estadoIcon = Icons.check_circle;
        break;
      case 'rechazado':
        estadoColor = theme.error;
        estadoIcon = Icons.cancel;
        break;
    }

    // Color para tiempo esperando
    if (usuario.diasEsperando > 7) {
      tiempoColor = theme.error;
    } else if (usuario.diasEsperando > 3) {
      tiempoColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: estadoColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(estadoIcon, color: estadoColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  usuario.estadoTexto,
                  style: theme.bodyText1.override(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: estadoColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tiempoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    usuario.tiempoEsperandoTexto,
                    style: theme.bodyText2.override(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: tiempoColor,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Información del usuario
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                Text(
                  usuario.nombreCompleto,
                  style: theme.title3.override(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Información adicional
                if (usuario.telefono != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: theme.secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        usuario.telefono!,
                        style: theme.bodyText2.override(
                          fontFamily: 'Poppins',
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Fecha de registro
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: theme.secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatearFecha(usuario.fechaRegistro),
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botones de acción (solo para usuarios pendientes)
          if (usuario.estado == 'pendiente') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _mostrarDialogoAprobacion(context, usuario),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rechazarUsuario(context, usuario),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Rechazar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      return 'Hoy ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  void _mostrarDialogoAprobacion(
      BuildContext context, UsuarioPendienteGrid usuario) {
    showDialog(
      context: context,
      builder: (context) => _DialogoAprobacionMobile(
        usuario: usuario,
        onAprobar: (rolId) => provider.aprobarUsuario(usuario.usuarioId, rolId),
      ),
    );
  }

  void _rechazarUsuario(BuildContext context, UsuarioPendienteGrid usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Rechazo'),
        content: Text('¿Estás seguro de rechazar a ${usuario.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.rechazarUsuario(usuario.usuarioId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Usuario ${usuario.nombreCompleto} rechazado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}

class _DialogoAprobacionMobile extends StatefulWidget {
  final UsuarioPendienteGrid usuario;
  final Future<bool> Function(int rolId) onAprobar;

  const _DialogoAprobacionMobile({
    required this.usuario,
    required this.onAprobar,
  });

  @override
  State<_DialogoAprobacionMobile> createState() =>
      _DialogoAprobacionMobileState();
}

class _DialogoAprobacionMobileState extends State<_DialogoAprobacionMobile> {
  RolAprobacion? _rolSeleccionado;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return AlertDialog(
      title: const Text('Aprobar Usuario'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.usuario.nombreCompleto,
                    style: theme.bodyText1.override(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (widget.usuario.telefono != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.usuario.telefono!,
                      style: theme.bodyText2.override(
                        fontFamily: 'Poppins',
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Selecciona el rol a asignar:',
              style: theme.bodyText1.override(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...RolAprobacion.rolesDisponibles.map((rol) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<RolAprobacion>(
                    title: Text(rol.nombre),
                    subtitle: Text(rol.descripcion),
                    value: rol,
                    groupValue: _rolSeleccionado,
                    onChanged: _isProcessing
                        ? null
                        : (value) {
                            setState(() {
                              _rolSeleccionado = value;
                            });
                          },
                    activeColor: theme.primaryColor,
                  ),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed:
              _isProcessing || _rolSeleccionado == null ? null : _aprobar,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Aprobar'),
        ),
      ],
    );
  }

  Future<void> _aprobar() async {
    if (_rolSeleccionado == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await widget.onAprobar(_rolSeleccionado!.id);
      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Usuario ${widget.usuario.nombreCompleto} aprobado como ${_rolSeleccionado!.nombre}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al aprobar usuario'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
