import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/pages/talleralex/widgets/global_sidebar.dart';

class ResponsiveDrawer extends StatelessWidget {
  final String currentRoute;

  const ResponsiveDrawer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.85;

    return Container(
      width: drawerWidth,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: GlobalSidebar(
          currentRoute: currentRoute,
          isDrawer: true,
          onNavigate: () {
            // Callback adicional si es necesario
          },
        ),
      ),
    );
  }
}
