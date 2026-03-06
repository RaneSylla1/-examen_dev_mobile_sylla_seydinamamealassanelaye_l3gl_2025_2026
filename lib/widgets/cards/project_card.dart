import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/project.dart';

/// Carte affichant un projet avec menu contextuel
class ProjectCard extends StatelessWidget {
  final Project project;
  final int taskCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    this.taskCount = 0,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color projectColor = Color(project.color);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Pastille de couleur du projet
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: projectColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.folder, color: projectColor, size: 26),
              ),
              const SizedBox(width: 12),

              // Nom + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.description != null &&
                        project.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        project.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Nombre de tâches
                    Row(
                      children: [
                        Icon(Icons.task_alt, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '$taskCount tâche${taskCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu contextuel
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Supprimer',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}