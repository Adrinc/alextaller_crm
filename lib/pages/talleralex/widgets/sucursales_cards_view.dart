import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/providers/talleralex/sucursales_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/helpers/globals.dart';

class SucursalesCardsView extends StatelessWidget {
  final SucursalesProvider provider;

  const SucursalesCardsView({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (provider.sucursalesMapa.isEmpty) {
      return _buildNoDataState(context);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: provider.sucursalesMapa.length,
        itemBuilder: (context, index) {
          final sucursal = provider.sucursalesMapa[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(16),
                      color: AppTheme.of(context).secondaryBackground,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _handleCardTap(context, sucursal),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.of(context).secondaryBackground,
                                AppTheme.of(context)
                                    .secondaryBackground
                                    .withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header con imagen y nombre
                              Row(
                                children: [
                                  // Imagen de la sucursal
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.of(context)
                                            .primaryColor
                                            .withOpacity(0.2),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF007F)
                                              .withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _buildSucursalImage(sucursal),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Información principal
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sucursal.nombre,
                                          style: TextStyle(
                                            color: AppTheme.of(context)
                                                .primaryText,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        if (sucursal.direccion != null)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: const Color(0xFFFF6B00),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  sucursal.direccion!,
                                                  style: TextStyle(
                                                    color: AppTheme.of(context)
                                                        .secondaryText,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 8),
                                        // Información de contacto
                                        Row(
                                          children: [
                                            if (sucursal.telefono != null)
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.phone,
                                                      size: 14,
                                                      color: const Color(
                                                          0xFFFF007F),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        sucursal.telefono!,
                                                        style: TextStyle(
                                                          color: AppTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                          fontSize: 12,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Menú de acciones
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: AppTheme.of(context).primaryText,
                                    ),
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                    onSelected: (action) => _handleMenuAction(
                                        context, action, sucursal),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'view_details',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.visibility,
                                              color: AppTheme.of(context)
                                                  .primaryColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Ver detalles',
                                              style: TextStyle(
                                                color: AppTheme.of(context)
                                                    .primaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'manage',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.settings,
                                              color: const Color(0xFFFF6B00),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Administrar',
                                              style: TextStyle(
                                                color: AppTheme.of(context)
                                                    .primaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Editar',
                                              style: TextStyle(
                                                color: AppTheme.of(context)
                                                    .primaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                color: AppTheme.of(context)
                                                    .primaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Métricas principales
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoChip(
                                      context,
                                      icon: Icons.people,
                                      label: 'Empleados',
                                      value: '${sucursal.empleadosActivos}',
                                      color: const Color(0xFFFF007F),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInfoChip(
                                      context,
                                      icon: Icons.garage,
                                      label: 'Bahías',
                                      value: '${sucursal.capacidadBahias}',
                                      color: const Color(0xFFFF6B00),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInfoChip(
                                      context,
                                      icon: Icons.assessment,
                                      label: 'Reportes',
                                      value: '${sucursal.reportesTotales}',
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInfoChip(
                                      context,
                                      icon: Icons.event_available,
                                      label: 'Citas Hoy',
                                      value: '${sucursal.citasHoy}',
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              if (sucursal.emailContacto != null) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      size: 14,
                                      color: AppTheme.of(context).secondaryText,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        sucursal.emailContacto!,
                                        style: TextStyle(
                                          color: AppTheme.of(context)
                                              .secondaryText,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSucursalImage(dynamic sucursal) {
    return Builder(
      builder: (BuildContext context) {
        if (sucursal.imagenUrl != null && sucursal.imagenUrl!.isNotEmpty) {
          final imageUrl =
              "${supabaseLU.supabaseUrl}/storage/v1/object/public/taller_alex/imagenes/${sucursal.imagenUrl}";

          return Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultIcon(context);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildDefaultIcon(context);
            },
          );
        } else {
          return _buildDefaultIcon(context);
        }
      },
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF007F),
            Color(0xFFFF6B00),
          ],
        ),
      ),
      child: const Icon(
        Icons.build_circle,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF007F), Color(0xFFFF6B00)],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.store_mall_directory,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No hay sucursales disponibles',
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega sucursales para comenzar a gestionar tu taller',
              style: TextStyle(
                color: AppTheme.of(context).secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleCardTap(BuildContext context, dynamic sucursal) {
    _showSucursalDetails(context, sucursal);
  }

  void _showSucursalDetails(BuildContext context, dynamic sucursal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildSucursalImage(sucursal),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sucursal.nombre,
                                style: TextStyle(
                                  color: AppTheme.of(context).primaryText,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (sucursal.direccion != null)
                                Text(
                                  sucursal.direccion!,
                                  style: TextStyle(
                                    color: AppTheme.of(context).secondaryText,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Métricas detalladas
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildDetailMetric(
                          context,
                          'Empleados Activos',
                          '${sucursal.empleadosActivos}',
                          Icons.people,
                          const Color(0xFFFF007F),
                        ),
                        _buildDetailMetric(
                          context,
                          'Capacidad de Bahías',
                          '${sucursal.capacidadBahias}',
                          Icons.garage,
                          const Color(0xFFFF6B00),
                        ),
                        _buildDetailMetric(
                          context,
                          'Reportes Totales',
                          '${sucursal.reportesTotales}',
                          Icons.assessment,
                          Colors.blue,
                        ),
                        _buildDetailMetric(
                          context,
                          'Citas de Hoy',
                          '${sucursal.citasHoy}',
                          Icons.event_available,
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Información de contacto
                    if (sucursal.telefono != null ||
                        sucursal.emailContacto != null) ...[
                      Text(
                        'Información de Contacto',
                        style: TextStyle(
                          color: AppTheme.of(context).primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (sucursal.telefono != null)
                        _buildContactInfo(
                          context,
                          Icons.phone,
                          'Teléfono',
                          sucursal.telefono!,
                        ),
                      if (sucursal.emailContacto != null)
                        _buildContactInfo(
                          context,
                          Icons.email,
                          'Email',
                          sucursal.emailContacto!,
                        ),
                      const SizedBox(height: 24),
                    ],
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              context.go('/sucursal/${sucursal.sucursalId}');
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Administrar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // TODO: Implementar edición
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppTheme.of(context).primaryColor,
                              side: BorderSide(
                                  color: AppTheme.of(context).primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailMetric(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.of(context).secondaryText,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(
      BuildContext context, String action, dynamic sucursal) {
    switch (action) {
      case 'manage':
        context.go('/sucursal/${sucursal.sucursalId}');
        break;
      case 'view_details':
        _showSucursalDetails(context, sucursal);
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Editar sucursal: ${sucursal.nombre} (En desarrollo)'),
            backgroundColor: AppTheme.of(context).primaryColor,
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(context, sucursal);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, dynamic sucursal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).primaryBackground,
        title: Text(
          'Eliminar Sucursal',
          style: TextStyle(color: AppTheme.of(context).primaryText),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la sucursal "${sucursal.nombre}"? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppTheme.of(context).secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.of(context).secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar eliminación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Eliminación de "${sucursal.nombre}" (En desarrollo)'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
