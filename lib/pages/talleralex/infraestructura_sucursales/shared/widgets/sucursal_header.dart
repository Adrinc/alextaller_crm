import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/talleralex/sucursales_provider.dart';
import 'package:nethive_neo/helpers/globals.dart';

class SucursalHeader extends StatelessWidget {
  final String sucursalId;

  const SucursalHeader({
    Key? key,
    required this.sucursalId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
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
      child: Consumer<SucursalesProvider>(
        builder: (context, sucursalesProvider, child) {
          // Buscar la sucursal en la lista de sucursales
          final sucursal = sucursalesProvider.sucursales
              .where((s) => s.id == sucursalId)
              .firstOrNull;

          return Row(
            children: [
              // Botón de regresar neumórfico
              InkWell(
                onTap: () => context.go('/sucursales'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F3),
                    borderRadius: BorderRadius.circular(16),
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
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Imagen/Ícono de la sucursal
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F3),
                  borderRadius: BorderRadius.circular(20),
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
                child: sucursal != null
                    ? _buildSucursalImage(sucursal, theme)
                    : _buildDefaultIcon(theme),
              ),

              const SizedBox(width: 24),

              // Información de la sucursal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre de la sucursal con gradiente
                    if (sucursal != null) ...[
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.secondaryColor,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          sucursal.nombre,
                          style: theme.title1.override(
                            fontFamily: 'Poppins',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Información de contacto en letras pequeñas
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Teléfono
                          if (sucursal.telefono != null &&
                              sucursal.telefono!.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  color: theme.secondaryText,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  sucursal.telefono!,
                                  style: theme.bodyText2.override(
                                    fontFamily: 'Poppins',
                                    color: theme.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],

                          // Dirección
                          if (sucursal.direccion != null &&
                              sucursal.direccion!.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: theme.secondaryText,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    sucursal.direccion!,
                                    style: theme.bodyText2.override(
                                      fontFamily: 'Poppins',
                                      color: theme.secondaryText,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ] else ...[
                      // Estado de carga
                      Container(
                        height: 32,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Estado y breadcrumbs
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Estado activo/inactivo
                  if (sucursal != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: sucursal.activa
                            ? theme.success.withOpacity(0.1)
                            : theme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: sucursal.activa
                              ? theme.success.withOpacity(0.3)
                              : theme.error.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color:
                                  sucursal.activa ? theme.success : theme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            sucursal.activa ? 'Activa' : 'Inactiva',
                            style: theme.bodyText2.override(
                              fontFamily: 'Poppins',
                              color:
                                  sucursal.activa ? theme.success : theme.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Breadcrumbs estilizados
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F3),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          offset: const Offset(-3, -3),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.grey.shade400.withOpacity(0.4),
                          offset: const Offset(3, 3),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home,
                          color: theme.secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sucursales',
                          style: theme.bodyText2.override(
                            fontFamily: 'Poppins',
                            color: theme.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: theme.secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sucursal?.nombre ?? 'Cargando...',
                          style: theme.bodyText2.override(
                            fontFamily: 'Poppins',
                            color: theme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSucursalImage(dynamic sucursal, AppTheme theme) {
    if (sucursal.imagenUrl != null && sucursal.imagenUrl!.isNotEmpty) {
      final imageUrl =
          "${supabaseLU.supabaseUrl}/storage/v1/object/public/taller_alex/imagenes/${sucursal.imagenUrl}";

      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultIcon(theme),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                strokeWidth: 2,
              ),
            );
          },
        ),
      );
    } else {
      return _buildDefaultIcon(theme);
    }
  }

  Widget _buildDefaultIcon(AppTheme theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.store,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}
