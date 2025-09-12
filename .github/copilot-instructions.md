# Instrucciones para AI Coding Agents - Taller Alex CRM

## Visión General del Proyecto

**Taller Alex CRM** es una aplicación Flutter Web para gestión integral de talleres automotrices con múltiples sucursales. Centraliza operaciones de clientes, vehículos, citas, órdenes de servicio, empleados e inventario con arquitectura multicapa (Global → Sucursales → Módulos específicos).

## Arquitectura del Sistema

### Estructura de Navegación Jerárquica
```
Login → Capa Global (HQ) → Selector Sucursales → Gestión Sucursal
```

**Capa Global**: Dashboard ejecutivo, gestión de todas las sucursales, usuarios, reportes globales, inventario consolidado, promociones, administración de catálogos.

**Selector Sucursales**: Mapa interactivo + tabla PlutoGrid con acciones (entrar, editar, crear).

**Gestión Sucursal**: Módulos operativos encapsulados por sucursal (dashboard, agenda, empleados, clientes, citas, inventario, pagos, reportes, configuración).

### Backend & Base de Datos
- **Supabase** con schema `taller_alex` para operaciones del taller
- Conexión dual: cliente principal (`supabase`) y específico del dominio (`supabaseLU`)
- Vistas materializadas: `vw_*` prefijo (ej: `vw_mapa_sucursales`, `vw_ocupacion_bahias_hoy`, `vw_inventario_alerta`)
- Funciones RPC: `crear_empleado_completo`, `get_dashboard_sucursal`, `crear_orden_desde_cita_v2`
- Organización ID: 11 para filtrado de datos

### Gestión de Estado (Provider Pattern)
- **TallerAlexNavigationProvider**: Navegación entre capas y módulos
- **SucursalesProvider**: Datos de sucursales + vista mapa/tabla
- **AgendaBahiasProvider**: Reservas de bahías con fechas y filtros
- **CitasOrdenesProvider**: Flujo completo de órdenes de servicio
- **InventarioProvider**: Stock, alertas, consumos por orden
- **UsuariosProvider**: Aprobaciones, empleados globales/locales
- **ReportesProvider**: Métricas globales y por sucursal
- **ThemeConfigProvider**: Sistema avanzado con Material Design 3

## Patrones Esenciales

### Enums de Navegación
```dart
enum TallerAlexModulo {
  dashboard, sucursales, agenda, empleados, clientes, 
  citas, inventario, pagos, promociones, reportes, configuracion
}
```

### Widgets de Layout
- **SucursalSidebar**: Navegación lateral neumórfica con animaciones
- **SucursalLayout**: Container principal que renderiza módulos según estado
- **PlutoGrid**: Tablas interactivas con paginación y acciones personalizadas

### Sistema de Temas Personalizado
- **AppTheme.of(context)**: Acceso al tema actual (light/dark)
- Neumorphic shadows predefinidas: `neumorphicShadows`, `neumorphicInsetShadows`
- Override de TextStyle: `theme.bodyText1.override(fontFamily: 'Poppins', color: ...)`

## Flujos de Trabajo Críticos

### Comandos de Desarrollo
```bash
# Desarrollo web
flutter run -d chrome --web-port 8080

# Build para producción
flutter build web --release

# Análisis estático
flutter analyze
```

### Providers - Patrón de Carga
```dart
// Siempre verificar si ya están cargados los datos
if (_sucursalId == sucursalId && _datos.isNotEmpty) return;

// Pattern estándar de loading
_isLoading = true;
_error = null;
notifyListeners();
```

### Consultas a Supabase
- Usar `supabaseLU` para operaciones del taller
- Prefiere vistas `vw_*` sobre joins complejos
- Funciones RPC para operaciones complejas
- Log con `log('✅ Datos cargados')` para debugging

### PlutoGrid Configuration
```dart
configuration: PlutoGridConfiguration(
  localeText: const PlutoGridLocaleText.spanish(),
  style: PlutoGridStyleConfig(
    gridBackgroundColor: Colors.white,
    rowHeight: 100, // Para contenido multi-línea
  ),
)
```

## Convenciones del Proyecto

### Estructura de Archivos
- `lib/pages/talleralex/`: Páginas principales
- `lib/pages/talleralex/infraestructura_sucursales/`: Módulos específicos de sucursal
- `lib/providers/talleralex/`: Estado global del dominio
- `lib/models/talleralex/`: Modelos de datos específicos

### Naming Conventions
- Providers: `*Provider` (ej: `AgendaBahiasProvider`)
- Models: Snake_case en BD, CamelCase en Dart
- Vistas de BD: `vw_` prefix
- Widgets compartidos: `*_widgets.dart`

### Responsive Design
```dart
final isSmallScreen = screenWidth < 1200;
// Adaptar layout basado en breakpoint
```

### Gestión de Errores
```dart
try {
  // operación
  log('✅ Operación exitosa');
} catch (e) {
  _error = 'Error descriptivo: $e';
  log('❌ Error en operación: $e');
} finally {
  _isLoading = false;
  notifyListeners();
}
```

## Patrones Críticos del Proyecto

### 1. Registro de Providers (OBLIGATORIO)
```dart
// lib/main.dart - SIEMPRE agregar nuevos providers aquí
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => NuevoProvider()),
    // ... otros providers
  ],
  child: const MyApp(),
)
```

### 2. Conexión a Supabase
```dart
// SIEMPRE importar y usar la variable global
import 'package:nethive_neo/helpers/globals.dart';

// En providers, usar supabaseLU (NO supabase)
final response = await supabaseLU.from('tabla').select();
```

### 3. Responsive Design Obligatorio
```dart
// Patrón estándar para responsive
final screenWidth = MediaQuery.of(context).size.width;
final isSmallScreen = screenWidth < 1200;

// Desktop: PlutoGrid, Mobile: Cards
Widget _buildContent() {
  return isSmallScreen 
    ? SucursalesCardsView(provider: provider)  // Móvil/Tablet
    : SucursalesTable(provider: provider);     // Desktop
}
```

### 4. Estructura de Archivos Responsive
```
lib/pages/talleralex/widgets/
├── sucursales_table.dart      // Desktop (PlutoGrid)
├── sucursales_cards_view.dart // Mobile/Tablet (Cards)
└── shared_widgets.dart        // Componentes comunes
```

### 5. Patrón PlutoGrid + Provider
```dart
// En el Provider - SIEMPRE incluir modelo + PlutoRows
class ClientesProvider extends ChangeNotifier {
  List<ClienteGrid> _clientes = [];           // Modelo de datos
  List<PlutoRow> clientesRows = [];           // Filas para PlutoGrid
  
  List<ClienteGrid> get clientes => _clientes;

  // Método para construir filas (llamar después de cargar datos)
  void _buildClientesRows() {
    clientesRows.clear();
    
    for (int i = 0; i < clientesFiltrados.length; i++) {
      final cliente = clientesFiltrados[i];
      clientesRows.add(PlutoRow(cells: {
        'numero': PlutoCell(value: (i + 1).toString()),
        'nombre': PlutoCell(value: cliente.clienteNombre),
        'telefono': PlutoCell(value: cliente.telefono ?? ''),
        'acciones': PlutoCell(value: cliente.clienteId), // ID para acciones
      }));
    }
  }
}
```

### 6. Gráficas Estadísticas
```dart
import 'package:fl_chart/fl_chart.dart';

// Usar para métricas y dashboards
PieChart(data: chartData)
BarChart(data: barData)
LineChart(data: lineData)
```

### 7. Diseño Neumórfico Estándar
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      // Sombra superior izquierda (luz)
      BoxShadow(
        color: Colors.white,
        offset: Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      // Sombra inferior derecha (sombra)
      BoxShadow(
        color: Colors.grey.shade400.withOpacity(0.4),
        offset: Offset(4, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  ),
  child: content,
)
```

### 8. Referencias de Base de Datos
- **Tablas**: Ver `assets/referencia/taller_alex_tablas.txt`
- **Vistas**: Ver `assets/referencia/taller_alex_vistas.txt`
- **Funciones**: Ver `assets/referencia/taller_alex_funciones.txt`

### 9. Rutas de Navegación
```dart
// lib/router/router.dart - Agregar nuevas rutas aquí
GoRoute(
  path: '/nueva-ruta',
  name: 'nueva-ruta',
  pageBuilder: (context, state) => NoTransitionPage(
    child: const NuevaPagina(),
  ),
)
```

### 10. Configuración de Temas
```dart
// lib/theme/theme.dart - Configuración centralizada
final theme = AppTheme.of(context);

// Uso estándar
Text(
  'Título',
  style: theme.title3.override(
    fontFamily: 'Poppins',
    color: theme.primaryColor,
  ),
)
```

## Sistema Visual y UX

### Tema Corporativo Actual
```dart
// Colores principales
Color blanco = Color(0xFFFFFFFF);
Color grisFondo = Color(0xFFF5F5F7);
Color textoNegro = Color(0xFF0A0A0A);

// Colores de acento
Color azulCorporativo = Color(0xFF0066CC);    // Principal
Color verdeConfirmacion = Color(0xFF2ECC71);  // Éxito
Color naranjaAlerta = Color(0xFFFF6B00);      // Advertencias
Color rosaBrillante = Color(0xFFFF2D95);      // Promociones
```

### Gradientes Recomendados
- **Headers/Buttons**: `linear-gradient(90deg, #0066CC, #2ECC71)`
- **Backgrounds**: `linear-gradient(180deg, #FFFFFF, #F5F5F7)`
- **Promociones**: `linear-gradient(90deg, #FF6B00, #FF2D95)`

### Layout Responsivo
- **Desktop**: Sidebar fijo + vistas completas
- **Tablet**: Sidebar colapsable + tablas compactas  
- **Móvil**: Drawer navigation + cards resumidas

## Flujo de Trabajo de Usuario

### Roles y Permisos
1. **Administrador Global**: Acceso completo a capa global + todas las sucursales
2. **Gerente Sucursal**: Gestión completa de sucursal específica
3. **Empleado**: Módulos operativos según permisos asignados

### Flujo Típico
```
Login → Dashboard Global → [Selector Sucursales] → Dashboard Sucursal → Módulo Específico
```

## Integraciones Clave

### Supabase Schema
- Organización ID: 11 (filtro obligatorio en consultas)
- Tablas core: `sucursales`, `citas`, `ordenes_servicio`, `empleados`, `clientes`, `inventario_refacciones`
- Auth con `user_profile` + roles dinámicos
- Sistema de notificaciones: `notificaciones`, `bitacora_eventos`

### Dependencias Críticas
- `pluto_grid`: Tablas interactivas con acciones personalizadas
- `go_router`: Navegación declarativa multicapa
- `google_fonts`: Poppins como fuente corporativa
- `flex_color_scheme`: Material Design 3 + temas personalizados
- `flutter_map`: Mapas interactivos para sucursales

## Funcionalidades Core del Sistema

### Gestión Multicapa
- **Global**: KPIs consolidados, gestión de usuarios, reportes ejecutivos, catálogos
- **Sucursal**: Operaciones diarias, agenda de bahías, inventario local, clientes
- **Detalle**: Vistas específicas de entidades (cliente, vehículo, orden de servicio)

### Módulos Principales por Capa

**Capa Global (HQ)**:
- Dashboard ejecutivo con métricas consolidadas
- Usuarios pendientes de aprobación
- Empleados globales (mover entre sucursales)
- Inventario global (alertas y top refacciones)
- Promociones y cupones corporativos
- Administración de catálogos y reglas de negocio

**Capa Sucursal**:
- Agenda/Bahías con ocupación en tiempo real
- Citas y órdenes con flujo completo (diagnóstico → servicios → entrega)
- Inventario local con alertas automáticas
- Empleados y asignaciones de técnicos
- Reportes locales y métricas

### Flujos Críticos de Negocio
1. **Creación de Orden**: Cita → Diagnóstico → Servicios → Refacciones → Facturación
2. **Gestión de Inventario**: Alertas automáticas → Reabastecimiento → Consumo por orden
3. **Aprobación de Usuarios**: Registro → Validación → Asignación de rol → Activación

## Debugging & Testing

### Console Logs con Emojis
- `✅` Operaciones exitosas
- `❌` Errores críticos  
- `🔄` Operaciones en progreso
- `🏢` Operaciones de sucursales
- `📊` Consultas a base de datos
- `👤` Operaciones de usuarios

### Estado Actual del Proyecto
- ✅ Schema de base de datos completo
- ✅ Diseño de navegación multicapa
- 🔄 **En desarrollo**: Login, capa global, selector sucursales
- 📋 **Próximo**: Aprobación usuarios, reportes globales, OCR placas

### Patrones de Desarrollo
- Módulos con placeholder: mostrar "En desarrollo" con iconos apropiados
- Usar `ScaffoldMessenger` para feedback inmediato de acciones
- Validar permisos y organización (ID: 11) antes de operaciones críticas
- Mantener consistencia visual con gradientes y colores corporativos

**Principio clave**: Priorizar la arquitectura jerárquica y la separación clara entre capas Global → Sucursal → Detalle.