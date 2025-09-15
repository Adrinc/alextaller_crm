import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/models/talleralex/clientes_globales_models.dart';
import 'package:nethive_neo/providers/talleralex/clientes_globales_provider.dart';

class VehiculosClienteWidget extends StatelessWidget {
  final String clienteId;
  final ClientesGlobalesProvider provider;
  final Function(VehiculoCliente vehiculo)? onVerHistorial;

  const VehiculosClienteWidget({
    super.key,
    required this.clienteId,
    required this.provider,
    this.onVerHistorial,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab bar para vehículos activos/inactivos
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.alternate.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              labelColor: theme.primaryColor,
              unselectedLabelColor: theme.secondaryText,
              indicator: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_car, size: 16),
                      const SizedBox(width: 8),
                      Text('Activos (${provider.vehiculosActivos.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.car_crash, size: 16),
                      const SizedBox(width: 8),
                      Text('Inactivos (${provider.vehiculosInactivos.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido de las tabs
          Expanded(
            child: TabBarView(
              children: [
                _buildVehiculosList(
                  context,
                  theme,
                  provider.vehiculosActivos,
                  isDesktop,
                  esActivo: true,
                ),
                _buildVehiculosList(
                  context,
                  theme,
                  provider.vehiculosInactivos,
                  isDesktop,
                  esActivo: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculosList(BuildContext context, AppTheme theme,
      List<VehiculoCliente> vehiculos, bool isDesktop,
      {required bool esActivo}) {
    if (vehiculos.isEmpty) {
      return _buildEmptyState(
        theme,
        esActivo
            ? 'No hay vehículos activos'
            : 'No hay vehículos dados de baja',
        esActivo
            ? 'Este cliente no tiene vehículos registrados actualmente.'
            : 'No se encontraron vehículos inactivos para este cliente.',
        esActivo ? Icons.directions_car : Icons.car_crash,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehiculos.length,
      itemBuilder: (context, index) {
        final vehiculo = vehiculos[index];
        return _buildVehiculoCard(
            context, theme, vehiculo, isDesktop, esActivo);
      },
    );
  }

  Widget _buildVehiculoCard(
    BuildContext context,
    AppTheme theme,
    VehiculoCliente vehiculo,
    bool isDesktop,
    bool esActivo,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esActivo
              ? theme.primaryColor.withOpacity(0.2)
              : theme.secondaryText.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: isDesktop
            ? _buildDesktopVehiculoLayout(context, theme, vehiculo, esActivo)
            : _buildMobileVehiculoLayout(context, theme, vehiculo, esActivo),
      ),
    );
  }

  Widget _buildDesktopVehiculoLayout(
    BuildContext context,
    AppTheme theme,
    VehiculoCliente vehiculo,
    bool esActivo,
  ) {
    return Row(
      children: [
        // Foto del vehículo
        _buildVehiculoImage(vehiculo, 80, 80),

        const SizedBox(width: 20),

        // Información principal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      vehiculo.nombreCompleto,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                  ),
                  _buildEstadoBadge(theme, vehiculo, esActivo),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 16,
                    color: theme.secondaryText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Placa: ${vehiculo.placa}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.secondaryText,
                    ),
                  ),
                  if (vehiculo.color != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.color_lens_outlined,
                      size: 16,
                      color: theme.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vehiculo.color!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                  if (vehiculo.combustible != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.local_gas_station_outlined,
                      size: 16,
                      color: theme.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vehiculo.combustible!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ],
              ),
              if (vehiculo.vin != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.numbers_outlined,
                      size: 16,
                      color: theme.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'VIN: ${vehiculo.vin}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.secondaryText.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Acciones
        _buildAccionesButtons(context, theme, vehiculo, esActivo),
      ],
    );
  }

  Widget _buildMobileVehiculoLayout(
    BuildContext context,
    AppTheme theme,
    VehiculoCliente vehiculo,
    bool esActivo,
  ) {
    return Column(
      children: [
        Row(
          children: [
            _buildVehiculoImage(vehiculo, 60, 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehiculo.nombreCompleto,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                      _buildEstadoBadge(theme, vehiculo, esActivo),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Placa: ${vehiculo.placa}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.secondaryText,
                    ),
                  ),
                  if (vehiculo.color != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Color: ${vehiculo.color}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAccionesButtons(context, theme, vehiculo, esActivo),
      ],
    );
  }

  Widget _buildVehiculoImage(
      VehiculoCliente vehiculo, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: vehiculo.fotoPath != null
            ? Image.network(
                vehiculo.fotoPath!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder();
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildImageError(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: Icon(
        Icons.directions_car,
        color: Colors.grey.shade400,
        size: 30,
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey.shade100,
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.grey.shade400,
        size: 30,
      ),
    );
  }

  Widget _buildEstadoBadge(
      AppTheme theme, VehiculoCliente vehiculo, bool esActivo) {
    final color = esActivo ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            esActivo ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            vehiculo.estadoTexto,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesButtons(
    BuildContext context,
    AppTheme theme,
    VehiculoCliente vehiculo,
    bool esActivo,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ver historial
        Tooltip(
          message: 'Ver historial del vehículo',
          child: InkWell(
            onTap: () => onVerHistorial?.call(vehiculo),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Historial',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Editar vehículo (solo para activos)
        if (esActivo) ...[
          Tooltip(
            message: 'Editar vehículo',
            child: InkWell(
              onTap: () => _editarVehiculo(context, vehiculo),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(
      AppTheme theme, String titulo, String mensaje, IconData icono) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.alternate.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icono,
                size: 40,
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              titulo,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _editarVehiculo(BuildContext context, VehiculoCliente vehiculo) {
    // TODO: Implementar edición de vehículo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              'Función de edición en desarrollo para: ${vehiculo.descripcionBreve}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
