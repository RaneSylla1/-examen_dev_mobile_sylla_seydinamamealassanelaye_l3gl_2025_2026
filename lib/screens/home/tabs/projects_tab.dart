import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';

import 'package:sunu_task/screens/projects/project_detail_screen.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';
import 'package:sunu_task/widgets/common/loading_indicator.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.watch<ProjectProvider>(),
      builder: (context, _) {
        final projectProvider = context.watch<ProjectProvider>();
        //final taskProvider = context.watch<TaskProvider>();

        if (projectProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (projectProvider.projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_open, size: 80, color: AppColors.border),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.noProjects,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.noProjectsDesc,
                  style: TextStyle(color: AppColors.textDisable),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _openCreateProject(context),
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.newProject),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final user = context.read<AuthProvider>().currentUser;
            if (user != null) {
              await projectProvider.loadProjects(user.id);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: projectProvider.projects.length,
            itemBuilder: (context, index) {
              final project = projectProvider.projects[index];


              return ProjectCard(
                project: project,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailScreen(project: project),
                    ),
                  );
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectFormScreen(project: project),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(context, project.id),
              );
            },
          ),
        );
      },
    );
  }

  void _openCreateProject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProjectFormScreen()),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: const Text(
          'Cette action supprimera aussi toutes les tâches associées. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ProjectProvider>().deleteProject(projectId);
      final user = context.read<AuthProvider>().currentUser;
      if (user != null && context.mounted) {

      }
    }
  }
}