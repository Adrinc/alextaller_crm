# TALLER ALEX CRM - Contexto del Proyecto

## 📋 Resumen General

**Taller Alex CRM** es una aplicación Flutter Web para la gestión integral de sucursales de un taller automotriz. Permite administrar citas, órdenes de servicio, clientes, vehículos, empleados e inventario de refacciones con una interfaz moderna, responsiva y adaptada a escritorio y dispositivos móviles.

## 🎯 Objetivo Principal

Crear un sistema centralizado de gestión de operaciones del taller que permita:  
- Administrar múltiples sucursales en un solo entorno.  
- Gestionar clientes, vehículos, citas y órdenes de servicio.  
- Controlar inventario de refacciones y alertas de stock.  
- Monitorear métricas clave mediante dashboards globales y locales.  
- Optimizar la coordinación entre empleados y bahías de trabajo.  
- Ofrecer una experiencia ágil y accesible para distintos roles del personal.  

## 🏗️ Arquitectura del Proyecto

### **Backend & Base de Datos**
- **Supabase** como backend principal.  
- Schema `public` con tablas específicas del dominio (`citas`, `ordenes_servicio`, `empleados`, `inventario_refacciones`, etc.).  
- Autenticación y autorización integrada.  
- Realtime para notificaciones y actualizaciones en vivo.  

### **Frontend - Flutter**
- **Material Design** con tema personalizado.  
- **Provider** para gestión de estado.  
- **Go Router** para navegación.  
- **PlutoGrid** para tablas interactivas.  
- **Responsive Design** adaptativo (desktop, tablet y móvil).  

---

## 🧭 Estructura de Navegación

```
Login → Capa Global → Selector de Sucursales → Gestión de Sucursal
```

### **Capa Global (Home tras login)**
- Dashboard global con KPIs: citas totales hoy, ingresos globales, alertas de inventario, órdenes recientes.  
- Acceso a reportes generales y configuraciones globales.  
- Botón destacado para entrar a “Sucursales” (vista mapa + tabla).  

### **Selector de Sucursales**
- Vista **mapa interactivo** con pines y hover-info de cada sucursal.  
- Vista **tabla (PlutoGrid)** con listado y acciones (entrar, editar, añadir).  
- Botón “+” para dar de alta nuevas sucursales.  

### **Gestión de Sucursal**
Al entrar a una sucursal, se abre un layout encapsulado:  
- **Header:** nombre de sucursal activo + breadcrumbs.  
- **Sidebar:**  
  - Volver al selector de sucursales  
  - Dashboard de la sucursal  
  - Agenda / Bahías de trabajo  
  - Empleados  
  - Clientes  
  - Citas y Órdenes de servicio  
  - Inventario de refacciones  
  - Pagos y Facturación  
  - Promociones y Cupones  
  - Reportes locales  
  - Configuración de sucursal  

---

## 📱 Funcionalidades Clave

1. **Clientes y Vehículos**  
   - Registro de clientes y múltiples vehículos asociados.  
   - Historial de citas, servicios y pagos.  

2. **Citas y Órdenes de Servicio**  
   - Agenda de bahías de trabajo (`agenda_bahias`).  
   - Gestión de técnicos asignados (`asignaciones_tecnico`).  
   - Flujo completo de orden: diagnóstico, servicios, refacciones, tiempos técnico.  

3. **Inventario de Refacciones**  
   - CRUD completo de refacciones (`inventario_refacciones`).  
   - Alertas automáticas (`vw_inventario_alerta`).  
   - Control de consumos por orden de servicio.  

4. **Reportes y Dashboards**  
   - Global: métricas de todas las sucursales.  
   - Local: métricas de cada sucursal (`vw_historial_sucursal`, `vw_totales_orden`).  

5. **Notificaciones y Bitácora**  
   - Sistema de notificaciones internas (`notificaciones`).  
   - Registro de eventos (`bitacora_eventos`).  

---

## 🎨 Diseño y UX

### **Tema Visual**

Basado en la identidad de Taller Alex (ver referencia de promociones):  
- **Colores principales:**  
  - Negro de fondo: `#0A0A0A`  
  - Rosa fucsia: `#FF007F`  
  - Blanco: `#FFFFFF`  
- **Colores secundarios:**  
  - Rosa brillante: `#FF2D95`  
  - Naranja de acento (para ofertas o alertas): `#FF6B00`  
  - Gris oscuro: `#1A1A1A`  

### **Degradados sugeridos**  
- Degradado 1 (Header/Buttons): `linear-gradient(90deg, #FF007F, #FF2D95)`  
- Degradado 2 (Background secciones): `linear-gradient(180deg, #0A0A0A, #1A1A1A)`  
- Degradado 3 (Alertas/Promociones): `linear-gradient(90deg, #FF6B00, #FF2D95)`  

### **Layout responsivo**  
- Escritorio: vistas completas con sidebar fijo y PlutoGrid.  
- Tablet: sidebar colapsable + tablas compactas.  
- Móvil: navegación tipo drawer + cards resumidas.  

### **Experiencia fluida**  
- Transiciones animadas entre módulos.  
- Hover effects en tarjetas y botones.  
- Breadcrumbs dinámicos para contexto.  

---

## 📊 Providers (Gestión de Estado)

- **NavigationProvider:** controla módulo y sucursal seleccionada.  
- **ClientesProvider:** gestión de clientes y vehículos.  
- **CitasOrdenesProvider:** agenda, asignaciones y flujo de órdenes.  
- **InventarioProvider:** refacciones, stock y alertas.  
- **ReportesProvider:** métricas globales y locales.  

---

## 🔄 Flujo de Usuario

1. **Login** → Autenticación.  
2. **Capa Global** → Dashboard global + accesos a reportes/configuración.  
3. **Selector de Sucursales** → Mapa o tabla con sucursales.  
4. **Gestión de Sucursal** → Sidebar con módulos (Dashboard, Agenda, Inventario, etc.).  
5. **Detalle de Entidades** → Vistas individuales de cliente, vehículo, cita u orden.  

---

## 🎯 Estado del Proyecto

- ✅ Esquema de base de datos definido (tablas y vistas).  
- ✅ Diseño conceptual de navegación (capa global, sucursales, sucursal interna).  
- 🔄 En desarrollo: implementación de frontend Flutter con login, capa global y selector de sucursales.  
- 📋 Próximas funciones: reportes avanzados, integración OCR de placas, notificaciones en tiempo real.  

---

**Fecha de creación**: 4 de septiembre de 2025  
**Versión**: 1.0  
**Proyecto**: Taller Alex CRM - Sistema de Gestión de Talleres Automotrices  
