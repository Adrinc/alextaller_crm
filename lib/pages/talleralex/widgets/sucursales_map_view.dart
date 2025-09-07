import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/providers/talleralex/sucursales_provider.dart';
import 'package:nethive_neo/providers/talleralex/navigation_provider.dart';
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
  String?
      _lastSelectedSucursalId; // Para detectar cambios de sucursal seleccionada

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
    // Detectar si cambió la sucursal seleccionada desde el sidebar
    final navigationProvider = context.read<TallerAlexNavigationProvider>();
    final currentSelectedSucursalId = navigationProvider.sucursalSeleccionadaId;

    if (oldWidget.provider.sucursalesMapa.length !=
            widget.provider.sucursalesMapa.length ||
        currentSelectedSucursalId != _lastSelectedSucursalId) {
      _initializeMapIfNeeded();
      _lastSelectedSucursalId = currentSelectedSucursalId;
    }
  }

  // Nuevo método que verifica si debe inicializar el mapa
  void _initializeMapIfNeeded() {
    final navigationProvider = context.read<TallerAlexNavigationProvider>();
    final selectedSucursalId = navigationProvider.sucursalSeleccionadaId;

    if (selectedSucursalId != null &&
        widget.provider.sucursalesMapa.isNotEmpty) {
      // Si hay una sucursal seleccionada, centrar en ella
      final selectedSucursal = widget.provider.sucursalesMapa
          .where((s) => s.sucursalId == selectedSucursalId)
          .firstOrNull;

      if (selectedSucursal != null &&
          selectedSucursal.lat != null &&
          selectedSucursal.lng != null) {
        _initializeMapWithSelected(selectedSucursal);
      } else {
        _initializeMap();
      }
    } else if (widget.provider.sucursalesMapa.isNotEmpty) {
      _initializeMap();
    }
  }

  // Nuevo método para inicializar el mapa con una sucursal seleccionada
  void _initializeMapWithSelected(VwMapaSucursales sucursal) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      _mapController.move(
        LatLng(sucursal.lat!, sucursal.lng!),
        15.0, // Zoom más cercano para sucursal individual
      );
      _forceMapRefresh();
    }
  }

  // Nuevo método para inicializar el mapa con refresh forzado
  void _initializeMap() async {
    // Esperar un poco más para asegurar que el widget esté completamente construido
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      _centerMapOnSucursales();
      _forceMapRefresh();
    }
  }

  // Método para forzar el refresh del mapa
  void _forceMapRefresh() {
    // Hacer un pequeño movimiento para forzar el renderizado de los tiles
    final currentCenter = _mapController.camera.center;
    final currentZoom = _mapController.camera.zoom;

    // Mover ligeramente y regresar a la posición original
    _mapController.move(
      LatLng(currentCenter.latitude + 0.00001, currentCenter.longitude),
      currentZoom,
    );

    // Regresar a la posición original después de un breve delay
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _mapController.move(currentCenter, currentZoom);
      }
    });
  }

  @override
  void dispose() {
    _markerAnimationController.dispose();
    _tooltipAnimationController.dispose();
    super.dispose();
  }

  void _showTooltipForSucursal(String sucursalId, Offset position) {
    setState(() {
      _hoveredSucursalId = sucursalId;
      _tooltipPosition = position;
      _showTooltip = true;
    });

    _markerAnimationController.forward();
    _tooltipAnimationController.forward();
  }

  void _centerMapOnSucursales() {
    final sucursalesConCoordenadas = widget.provider.sucursalesMapa
        .where((s) => s.lat != null && s.lng != null)
        .toList();

    if (sucursalesConCoordenadas.isEmpty) return;

    if (sucursalesConCoordenadas.length == 1) {
      final sucursal = sucursalesConCoordenadas.first;
      _mapController.move(
        LatLng(sucursal.lat!, sucursal.lng!),
        15.0,
      );
    } else {
      final bounds = _calculateBounds();
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  LatLngBounds _calculateBounds() {
    if (widget.provider.sucursalesMapa.isEmpty) {
      return LatLngBounds(
        const LatLng(0, 0),
        const LatLng(0, 0),
      );
    }

    final sucursalesConCoordenadas = widget.provider.sucursalesMapa
        .where((s) => s.lat != null && s.lng != null)
        .toList();

    if (sucursalesConCoordenadas.isEmpty) {
      return LatLngBounds(
        const LatLng(0, 0),
        const LatLng(0, 0),
      );
    }

    double minLat = sucursalesConCoordenadas.first.lat!;
    double maxLat = sucursalesConCoordenadas.first.lat!;
    double minLng = sucursalesConCoordenadas.first.lng!;
    double maxLng = sucursalesConCoordenadas.first.lng!;

    for (final sucursal in sucursalesConCoordenadas) {
      if (sucursal.lat! < minLat) minLat = sucursal.lat!;
      if (sucursal.lat! > maxLat) maxLat = sucursal.lat!;
      if (sucursal.lng! < minLng) minLng = sucursal.lng!;
      if (sucursal.lng! > maxLng) maxLng = sucursal.lng!;
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sucursalesConCoordenadas = widget.provider.sucursalesMapa
        .where((s) => s.lat != null && s.lng != null)
        .toList();

    if (sucursalesConCoordenadas.isEmpty) {
      return _buildEmptyMapState();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    const LatLng(19.4326, -99.1332), // Ciudad de México
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
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                MarkerLayer(
                  markers: _buildMarkers(),
                ),
              ],
            ),
            _buildMapHeader(),
            _buildMapControls(),
            if (_showTooltip && _hoveredSucursalId != null)
              _buildAnimatedTooltip(),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return widget.provider.sucursalesMapa
        .where((s) => s.lat != null && s.lng != null)
        .map((sucursal) {
      final isHovered = _hoveredSucursalId == sucursal.sucursalId;
      return Marker(
        point: LatLng(sucursal.lat!, sucursal.lng!),
        width: 60,
        height: 60,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (event) {
            final renderBox = context.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final localPosition = renderBox.globalToLocal(event.position);
              _showTooltipForSucursal(sucursal.sucursalId, localPosition);
            }
          },
          onExit: (event) {
            // No ocultar el tooltip al salir del marker
            // Solo se ocultará cuando se haga hover en otro marker
          },
          child: GestureDetector(
            onTap: () {
              // Navegar a la sucursal específica
              context.go('/sucursal/${sucursal.sucursalId}');
            },
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
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildMarkerImage(sucursal),
            ),
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
          return _buildDefaultMarkerIcon();
        },
      );
    } else {
      return _buildDefaultMarkerIcon();
    }
  }

  Widget _buildDefaultMarkerIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF007F), // Fuchsia de Taller Alex
            const Color(0xFFFF6B00), // Orange de Taller Alex
          ],
        ),
      ),
      child: const Icon(
        Icons.build_circle,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildAnimatedTooltip() {
    final sucursal = widget.provider.sucursalesMapa
        .firstWhere((s) => s.sucursalId == _hoveredSucursalId);

    return Positioned(
      left: (_tooltipPosition?.dx ?? 0) + 70,
      top: (_tooltipPosition?.dy ?? 0) - 100,
      child: AnimatedBuilder(
        animation: _tooltipAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _tooltipAnimation.value,
            child: SlideTransition(
              position: _tooltipSlideAnimation,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.of(context).secondaryBackground,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header con imagen y nombre
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.of(context)
                                    .primaryColor
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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
                                  style: TextStyle(
                                    color: AppTheme.of(context).primaryText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (sucursal.direccion != null)
                                  Text(
                                    sucursal.direccion!,
                                    style: TextStyle(
                                      color: AppTheme.of(context).secondaryText,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                              const Color(0xFFFF007F),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTooltipMetric(
                              'Bahías',
                              '${sucursal.capacidadBahias}',
                              Icons.garage,
                              const Color(0xFFFF6B00),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTooltipMetric(
                              'Reportes',
                              '${sucursal.reportesTotales}',
                              Icons.assessment,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTooltipMetric(
                              'Citas Hoy',
                              '${sucursal.citasHoy}',
                              Icons.event_available,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
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
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF007F),
            const Color(0xFFFF6B00),
          ],
        ),
      ),
      child: const Icon(
        Icons.build_circle,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildTooltipMetric(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
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
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 14,
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

  Widget _buildMapHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.of(context).secondaryBackground.withOpacity(0.9),
              AppTheme.of(context).secondaryBackground.withOpacity(0.0),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF007F), Color(0xFFFF6B00)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF007F).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.provider.sucursalesMapa.length} Sucursales',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                _centerMapOnSucursales();
              },
              icon: Icon(
                Icons.center_focus_strong,
                color: AppTheme.of(context).primaryColor,
              ),
              tooltip: 'Centrar mapa',
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
          Container(
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom + 1,
                    );
                  },
                  icon: Icon(
                    Icons.add,
                    color: AppTheme.of(context).primaryText,
                  ),
                  tooltip: 'Acercar',
                ),
                Container(
                  height: 1,
                  color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                ),
                IconButton(
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom - 1,
                    );
                  },
                  icon: Icon(
                    Icons.remove,
                    color: AppTheme.of(context).primaryText,
                  ),
                  tooltip: 'Alejar',
                ),
                Container(
                  height: 1,
                  color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                ),
                IconButton(
                  onPressed: () {
                    _centerMapOnSucursales();
                  },
                  icon: Icon(
                    Icons.center_focus_strong,
                    color: AppTheme.of(context).primaryColor,
                  ),
                  tooltip: 'Centrar mapa',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMapState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                Icons.location_off,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin ubicaciones disponibles',
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay sucursales con coordenadas para mostrar en el mapa',
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
}
