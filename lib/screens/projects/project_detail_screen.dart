import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final projectColor = Color(project.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProjectFormScreen(project: project)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête coloré
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: projectColor.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                      color: projectColor.withOpacity(0.3), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône colorée
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: projectColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.folder, color: projectColor, size: 30),
                  ),
                  const SizedBox(height: 16),
                  // Nom
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // Description
                  if (project.description != null &&
                      project.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      project.description!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Date de création
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: AppColors.textDisable),
                      const SizedBox(width: 6),
                      Text(
                        'Créé le ${_formatDate(project.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDisable,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions rapides
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.edit,
                          label: 'Modifier',
                          color: AppColors.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProjectFormScreen(project: project)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.delete,
                          label: 'Supprimer',
                          color: AppColors.error,
                          onTap: () => _confirmDelete(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
      'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: const Text('Voulez-vous vraiment supprimer ce projet ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(AppStrings.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(AppStrings.delete,
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ProjectProvider>().deleteProject(project.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}