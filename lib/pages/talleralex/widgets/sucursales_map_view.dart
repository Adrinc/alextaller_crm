import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/providers/talleralex/sucursales_provider.dart';
import 'package:nethive_neo/models/talleralex/vw_mapa_sucursales_model.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/helpers/globals.dart';

class SucursalesMapView extends StatefulWidget {
  final SucursalesProvider provider;

  const SucursalesMapView({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  State<SucursalesMapView> createState() => _SucursalesMapViewState();
}

class _SucursalesMapViewState extends State<SucursalesMapView>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _markerAnimationController;
  late AnimationController _tooltipAnimationController;
  late Animation<double> _markerAnimation;
  late Animation<double> _tooltipAnimation;
  late Animation<Offset> _tooltipSlideAnimation;

  String? _hoveredSucursalId;
  Offset? _tooltipPosition;
  bool _showTooltip = false;

  @override
  void initState() {
    super.initState();
    _markerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tooltipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _markerAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _markerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _tooltipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tooltipAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _tooltipSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _tooltipAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Centrar el mapa después de que se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMapIfNeeded();
    });
  }

  @override
  void didUpdateWidget(SucursalesMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambiaron las sucursales, reinicializar el mapa
    if (oldWidget.provider.sucursalesMapa.length !=
        widget.provider.sucursalesMapa.length) {
      _initializeMapIfNeeded();
    }
  }

  void _initializeMapIfNeeded() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted && widget.provider.sucursalesMapa.isNotEmpty) {
      _centerMapOnSucursales();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _markerAnimationController.dispose();
    _tooltipAnimationController.dispose();
    super.dispose();
  }

  void _showTooltipForSucursal(String sucursalId, Offset position) {
    if (_hoveredSucursalId != sucursalId) {
      setState(() {
        _hoveredSucursalId = sucursalId;
        _tooltipPosition = position;
        _showTooltip = true;
      });
      _markerAnimationController.forward();
      _tooltipAnimationController.forward();
    }
  }

  void _hideTooltip() {
    if (_hoveredSucursalId != null) {
      setState(() {
        _hoveredSucursalId = null;
        _showTooltip = false;
      });
      _markerAnimationController.reverse();
      _tooltipAnimationController.reverse();
    }
  }

  void _centerMapOnSucursales() {
    final sucursalesConCoordenadas = widget.provider.sucursalesMapa
        .where((sucursal) => sucursal.lat != null && sucursal.lng != null)
        .toList();

    if (sucursalesConCoordenadas.isEmpty) return;

    if (sucursalesConCoordenadas.length == 1) {
      // Si solo hay una sucursal, centrar en ella
      final sucursal = sucursalesConCoordenadas.first;
      _mapController.move(
        LatLng(sucursal.lat!, sucursal.lng!),
        13.0,
      );
    } else {
      // Si hay múltiples sucursales, ajustar bounds
      final bounds = _calculateBounds(sucursalesConCoordenadas);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  LatLngBounds _calculateBounds(List<VwMapaSucursales> sucursales) {
    double minLat = sucursales.first.lat!;
    double maxLat = sucursales.first.lat!;
    double minLng = sucursales.first.lng!;
    double maxLng = sucursales.first.lng!;

    for (final sucursal in sucursales) {
      if (sucursal.lat != null && sucursal.lng != null) {
        minLat = minLat < sucursal.lat! ? minLat : sucursal.lat!;
        maxLat = maxLat > sucursal.lat! ? maxLat : sucursal.lat!;
        minLng = minLng < sucursal.lng! ? minLng : sucursal.lng!;
        maxLng = maxLng > sucursal.lng! ? maxLng : sucursal.lng!;
      }
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sucursalesConCoordenadas = widget.provider.sucursalesMapa
        .where((sucursal) => sucursal.lat != null && sucursal.lng != null)
        .toList();

    if (sucursalesConCoordenadas.isEmpty) {
      return _buildEmptyMapState();
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(19.4326, -99.1332), // Ciudad de México
            initialZoom: 11.0,
            minZoom: 3.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.talleralex.crm',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerLayer(
              markers: _buildMarkers(),
            ),
          ],
        ),
        _buildMapHeader(),
        _buildMapControls(),
        if (_showTooltip && _tooltipPosition != null) _buildAnimatedTooltip(),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    return widget.provider.sucursalesMapa
        .where((sucursal) => sucursal.lat != null && sucursal.lng != null)
        .map((sucursal) {
      final isHovered = _hoveredSucursalId == sucursal.sucursalId;

      return Marker(
        point: LatLng(sucursal.lat!, sucursal.lng!),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () => context.go('/sucursal/${sucursal.sucursalId}'),
          child: MouseRegion(
            onEnter: (event) {
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              final position = renderBox.globalToLocal(event.position);
              _showTooltipForSucursal(sucursal.sucursalId, position);
            },
            onExit: (event) => _hideTooltip(),
            child: _buildMarkerContent(sucursal, isHovered),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMarkerContent(VwMapaSucursales sucursal, bool isHovered) {
    return AnimatedBuilder(
      animation: _markerAnimation,
      builder: (context, child) {
        final scale = isHovered ? _markerAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Stack(
            children: [
              // Sombra del marcador
              Positioned(
                bottom: 5,
                left: 15,
                right: 15,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // Marcador principal
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.of(context).primaryColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildMarkerImage(sucursal),
                ),
              ),
              // Indicador de actividad (si hay citas hoy)
              if (sucursal.citasHoy > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${sucursal.citasHoy}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarkerImage(VwMapaSucursales sucursal) {
    if (sucursal.imagenUrl != null && sucursal.imagenUrl!.isNotEmpty) {
      final imageUrl =
          "${supabaseLU.supabaseUrl}/storage/v1/object/public/taller_alex/imagenes/${sucursal.imagenUrl}";

      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultMarkerIcon();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.of(context).primaryColor,
              ),
            ),
          );
        },
      );
    } else {
      return _buildDefaultMarkerIcon();
    }
  }

  Widget _buildDefaultMarkerIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.of(context).primaryGradient,
      ),
      child: Icon(
        Icons.car_repair,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildAnimatedTooltip() {
    final sucursal = widget.provider.sucursalesMapa
        .firstWhere((s) => s.sucursalId == _hoveredSucursalId);

    return Positioned(
      left: _tooltipPosition!.dx - 150,
      top: _tooltipPosition!.dy - 150,
      child: AnimatedBuilder(
        animation: _tooltipAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _tooltipAnimation.value,
            child: SlideTransition(
              position: _tooltipSlideAnimation,
              child: Opacity(
                opacity: _tooltipAnimation.value,
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.of(context).secondaryBackground,
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.of(context).secondaryBackground,
                          AppTheme.of(context).primaryBackground,
                        ],
                      ),
                      border: Border.all(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header con imagen
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: _buildTooltipImage(sucursal),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sucursal.nombre,
                                    style: AppTheme.of(context).title3.override(
                                          fontFamily: 'Poppins',
                                          color:
                                              AppTheme.of(context).primaryText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (sucursal.direccion != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      sucursal.direccion!,
                                      style: AppTheme.of(context)
                                          .bodyText2
                                          .override(
                                            fontFamily: 'Poppins',
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            fontSize: 12,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Métricas
                        Row(
                          children: [
                            Expanded(
                              child: _buildTooltipMetric(
                                'Empleados',
                                '${sucursal.empleadosActivos}',
                                Icons.people,
                                AppTheme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTooltipMetric(
                                'Citas Hoy',
                                '${sucursal.citasHoy}',
                                Icons.calendar_today,
                                AppTheme.of(context).tertiaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTooltipMetric(
                                'Reportes',
                                '${sucursal.reportesTotales}',
                                Icons.assessment,
                                AppTheme.of(context).success,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Botón de acción
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                context.go('/sucursal/${sucursal.sucursalId}'),
                            icon: Icon(
                              Icons.arrow_forward,
                              color: AppTheme.of(context).primaryText,
                              size: 16,
                            ),
                            label: Text(
                              'Ver Sucursal',
                              style: AppTheme.of(context).bodyText2.override(
                                    fontFamily: 'Poppins',
                                    color: AppTheme.of(context).primaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.of(context).primaryColor,
                              foregroundColor: AppTheme.of(context).primaryText,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTooltipImage(VwMapaSucursales sucursal) {
    if (sucursal.imagenUrl != null && sucursal.imagenUrl!.isNotEmpty) {
      final imageUrl =
          "${supabaseLU.supabaseUrl}/storage/v1/object/public/taller_alex/imagenes/${sucursal.imagenUrl}";

      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildTooltipIcon();
        },
      );
    } else {
      return _buildTooltipIcon();
    }
  }

  Widget _buildTooltipIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.of(context).primaryGradient,
      ),
      child: const Icon(
        Icons.car_repair,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildTooltipMetric(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.of(context).bodyText2.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
          ),
          Text(
            label,
            style: AppTheme.of(context).bodyText2.override(
                  fontFamily: 'Poppins',
                  color: AppTheme.of(context).secondaryText,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapHeader() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.map,
              color: AppTheme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Mapa de Sucursales',
              style: AppTheme.of(context).bodyText1.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).primaryText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.provider.sucursalesMapa.length} sucursales',
                style: AppTheme.of(context).bodyText2.override(
                      fontFamily: 'Poppins',
                      color: AppTheme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            mini: true,
            backgroundColor: AppTheme.of(context).secondaryBackground,
            foregroundColor: AppTheme.of(context).primaryColor,
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: AppTheme.of(context).secondaryBackground,
            foregroundColor: AppTheme.of(context).primaryColor,
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: AppTheme.of(context).secondaryBackground,
            foregroundColor: AppTheme.of(context).primaryColor,
            onPressed: _centerMapOnSucursales,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMapState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: AppTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay sucursales con ubicación',
              style: AppTheme.of(context).title3.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).primaryText,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega coordenadas a las sucursales para verlas en el mapa',
              style: AppTheme.of(context).bodyText2.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
