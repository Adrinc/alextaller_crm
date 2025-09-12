import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/talleralex/usuarios_pendientes_provider.dart';
import '../../../theme/theme.dart';
import '../widgets/usuarios_pendientes_table.dart';
import '../widgets/usuarios_pendientes_cards.dart';
import '../widgets/global_sidebar.dart';
import '../widgets/responsive_drawer.dart';

/// Página para gestión de usuarios pendientes de aprobación
class UsuariosPendientesPage extends StatefulWidget {
  const UsuariosPendientesPage({super.key});

  @override
  State<UsuariosPendientesPage> createState() => _UsuariosPendientesPageState();
}

class _UsuariosPendientesPageState extends State<UsuariosPendientesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar datos al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsuariosPendientesProvider>(context, listen: false)
          .cargarUsuariosPendientes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    // Obtener la ruta actual desde GoRouter
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final currentRoute = currentLocation;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      drawer: isSmallScreen
          ? Drawer(
              child: ResponsiveDrawer(
                currentRoute: currentRoute,
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar
          if (!isSmallScreen) GlobalSidebar(currentRoute: currentRoute),

          // Contenido principal
          Expanded(
            child: _buildMainContent(theme, isSmallScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(AppTheme theme, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(theme),
        const SizedBox(height: 24),
        _buildStatsCards(theme),
        const SizedBox(height: 32),
        _buildSearchBar(theme),
        const SizedBox(height: 24),
        Expanded(
          child: _buildContent(isSmallScreen),
        ),
      ],
    );
  }

  Widget _buildHeader(theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 32,
        24,
        isSmallScreen ? 16 : 32,
        16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0066CC),
            Color(0xFF2ECC71),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menú hamburguesa para pantallas pequeñas
          if (isSmallScreen) ...[
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ],

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_add,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuarios Pendientes',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestión y aprobación de usuarios del sistema',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    return Consumer<UsuariosPendientesProvider>(
      builder: (context, provider, _) {
        final total = provider.totalUsuarios;
        final pendientes = provider.usuariosPendientes;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 32),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Total de Solicitudes',
                  '$total',
                  Icons.people,
                  Color(0xFF0066CC),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Pendientes de Aprobación',
                  '$pendientes',
                  Icons.pending,
                  Color(0xFFFF6B00),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: theme.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o email...',
            hintStyle: GoogleFonts.poppins(
              color: theme.secondaryText,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: theme.secondaryText,
            ),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.secondaryText,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      Provider.of<UsuariosPendientesProvider>(context,
                              listen: false)
                          .filtrarUsuarios('');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            Provider.of<UsuariosPendientesProvider>(context, listen: false)
                .filtrarUsuarios(value);
          },
        ),
      ),
    );
  }

  Widget _buildContent(bool isSmallScreen) {
    return Consumer<UsuariosPendientesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar usuarios',
                  style: GoogleFonts.poppins(
                    color: Colors.red.shade400,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: AppTheme.of(context).secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => provider.cargarUsuariosPendientes(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (provider.usuariosFiltrados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppTheme.of(context).secondaryText,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay usuarios pendientes',
                  style: GoogleFonts.poppins(
                    color: AppTheme.of(context).secondaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreenContent = screenWidth < 1200;

        return Padding(
          padding:
              EdgeInsets.symmetric(horizontal: isSmallScreenContent ? 16 : 32),
          child: isSmallScreen
              ? UsuariosPendientesCards(provider: provider)
              : UsuariosPendientesTable(provider: provider),
        );
      },
    );
  }
}
