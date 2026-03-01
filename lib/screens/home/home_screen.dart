import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';

import 'package:sunu_task/screens/auth/login_screen.dart';
import 'package:sunu_task/screens/home/tabs/dashboard_tab.dart';

import 'package:sunu_task/screens/home/tabs/projects_tab.dart';

import 'package:sunu_task/screens/projects/project_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // IndexedStack préserve l'état de chaque onglet
  final List<Widget> _tabs = const [
    DashboardTab(),
    ProjectsTab(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle()),
        actions: [
          if (_currentIndex == 0 || _currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {}, // Bonus : recherche
            ),
        ],
      ),

      // Drawer latéral
      drawer: _buildDrawer(context),

      // IndexedStack pour préserver l'état des onglets
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),

      // Navigation par onglets
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: AppStrings.projects,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist),
            label: AppStrings.tasks,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),

      // FAB visible sur Dashboard et Projets
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProjectFormScreen(),
            ),
          ).then((_) {
            // Recharger après création
            final user =
                context.read<AuthProvider>().currentUser;
            if (user != null) {
              context.read<ProjectProvider>().loadProjects(user.id);

            }
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  String _appBarTitle() {
    switch (_currentIndex) {
      case 0: return AppStrings.appName;
      case 1: return AppStrings.projects;
      case 2: return AppStrings.tasks;
      case 3: return AppStrings.profile;
      default: return AppStrings.appName;
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Drawer(
      child: Column(
        children: [
          // En-tête avec avatar
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(
              user?.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user != null && user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // Items de navigation
          _drawerItem(Icons.dashboard, 'Tableau de bord', 0),
          _drawerItem(Icons.folder, AppStrings.projects, 1),
          _drawerItem(Icons.checklist, AppStrings.tasks, 2),
          _drawerItem(Icons.person, AppStrings.profile, 3),

          const Divider(),

          // Déconnexion
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context); // Fermer le drawer
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.pop(context); // Fermer le drawer
    await context.read<AuthProvider>().logout();
    context.read<ProjectProvider>().clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }
}