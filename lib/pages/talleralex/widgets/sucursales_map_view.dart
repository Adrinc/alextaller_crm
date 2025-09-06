import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/providers/talleralex/sucursales_provider.dart';
import 'package:nethive_neo/models/talleralex/sucursal_model.dart';
import 'package:nethive_neo/theme/theme.dart';

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
      _initializeMap();
    });
  }

  @override
  void didUpdateWidget(SucursalesMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambiaron las sucursales, reinicializar el mapa
    if (oldWidget.provider.sucursales.length !=
        widget.provider.sucursales.length) {
      _initializeMap();
    }
  }

  void _initializeMap() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted && widget.provider.sucursales.isNotEmpty) {
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
    setState(() {
      _hoveredSucursalId = sucursalId;
      _tooltipPosition = position;
      _showTooltip = true;
    });
    _markerAnimationController.forward();
    _tooltipAnimationController.forward();
  }

  void _hideTooltip() {
    setState(() {
      _hoveredSucursalId = null;
      _showTooltip = false;
    });
    _markerAnimationController.reverse();
    _tooltipAnimationController.reverse();
  }

  void _centerMapOnSucursales() {
    final sucursalesConCoordenadas = widget.provider.sucursales
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

  LatLngBounds _calculateBounds(List<Sucursal> sucursales) {
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
    final sucursalesConCoordenadas = widget.provider.sucursales
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
            initialCenter: sucursalesConCoordenadas.isNotEmpty
                ? LatLng(sucursalesConCoordenadas.first.lat!,
                    sucursalesConCoordenadas.first.lng!)
                : const LatLng(
                    19.4326, -99.1332), // Ciudad de México como fallback
            initialZoom: 13.0,
            minZoom: 3.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onTap: (tapPosition, point) => _hideTooltip(),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.talleralex.app',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerLayer(
              markers: _buildMarkers(),
            ),
          ],
        ),

        // Header del mapa
        _buildMapHeader(),

        // Controles del mapa
        _buildMapControls(),

        // Tooltip animado
        if (_showTooltip && _tooltipPosition != null) _buildAnimatedTooltip(),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    return widget.provider.sucursales
        .where((sucursal) => sucursal.lat != null && sucursal.lng != null)
        .map((sucursal) {
      final isHovered = _hoveredSucursalId == sucursal.id;

      return Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(sucursal.lat!, sucursal.lng!),
        child: GestureDetector(
          onTap: () => context.go('/sucursal/${sucursal.id}'),
          child: MouseRegion(
            onEnter: (event) {
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              final position = renderBox.globalToLocal(event.position);
              _showTooltipForSucursal(sucursal.id, position);
            },
            onExit: (event) => _hideTooltip(),
            child: _buildMarkerContent(sucursal, isHovered),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMarkerContent(Sucursal sucursal, bool isHovered) {
    return AnimatedBuilder(
      animation: _markerAnimation,
      builder: (context, child) {
        final scale = isHovered ? _markerAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.4),
                  blurRadius: isHovered ? 20 : 10,
                  spreadRadius: isHovered ? 5 : 2,
                ),
              ],
            ),
            child: _buildMarkerIcon(isHovered),
          ),
        );
      },
    );
  }

  Widget _buildMarkerIcon(bool isHovered) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(8),
      child: Icon(
        Icons.store,
        size: isHovered ? 32 : 24,
        color: AppTheme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildAnimatedTooltip() {
    final sucursal = widget.provider.sucursales
        .firstWhere((s) => s.id == _hoveredSucursalId);

    return Positioned(
      left: _tooltipPosition!.dx - 100,
      top: _tooltipPosition!.dy - 120,
      child: AnimatedBuilder(
        animation: _tooltipAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _tooltipAnimation.value,
            child: SlideTransition(
              position: _tooltipSlideAnimation,
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.of(context).primaryColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _buildTooltipIcon(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sucursal.nombre,
                            style: AppTheme.of(context).bodyText1.override(
                                  fontFamily: 'Poppins',
                                  color: AppTheme.of(context).primaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (sucursal.direccion != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.of(context).secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              sucursal.direccion!,
                              style: AppTheme.of(context).bodyText2.override(
                                    fontFamily: 'Poppins',
                                    color: AppTheme.of(context).secondaryText,
                                    fontSize: 12,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (sucursal.telefono != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: AppTheme.of(context).secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sucursal.telefono!,
                            style: AppTheme.of(context).bodyText2.override(
                                  fontFamily: 'Poppins',
                                  color: AppTheme.of(context).secondaryText,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Clic para ver detalles',
                        style: AppTheme.of(context).bodyText2.override(
                              fontFamily: 'Poppins',
                              color: AppTheme.of(context).primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTooltipIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.store,
        size: 14,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMapHeader() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.of(context).primaryColor.withOpacity(0.3),
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
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.provider.sucursales.where((s) => s.lat != null && s.lng != null).length} ubicadas',
                style: AppTheme.of(context).bodyText2.override(
                      fontFamily: 'Poppins',
                      color: AppTheme.of(context).primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
          // Botón de zoom in
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: FloatingActionButton.small(
              onPressed: () {
                final zoom = _mapController.camera.zoom;
                _mapController.move(_mapController.camera.center, zoom + 1);
              },
              backgroundColor: AppTheme.of(context).primaryBackground,
              foregroundColor: AppTheme.of(context).primaryColor,
              child: const Icon(Icons.add),
            ),
          ),
          // Botón de zoom out
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: FloatingActionButton.small(
              onPressed: () {
                final zoom = _mapController.camera.zoom;
                _mapController.move(_mapController.camera.center, zoom - 1);
              },
              backgroundColor: AppTheme.of(context).primaryBackground,
              foregroundColor: AppTheme.of(context).primaryColor,
              child: const Icon(Icons.remove),
            ),
          ),
          // Botón de centrar
          FloatingActionButton.small(
            onPressed: _centerMapOnSucursales,
            backgroundColor: AppTheme.of(context).primaryBackground,
            foregroundColor: AppTheme.of(context).primaryColor,
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off,
                size: 64,
                color: AppTheme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay sucursales ubicadas',
              style: AppTheme.of(context).title3.override(
                    fontFamily: 'Poppins',
                    color: AppTheme.of(context).primaryText,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega coordenadas a tus sucursales\npara verlas en el mapa',
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
