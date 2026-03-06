import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;
  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  final List<int> _colors = [
    0xFF0293ED, 0xFF61E561, 0xFFEF4444, 0xFFF59E0B,
    0xFF8B5CF6, 0xFFEC4899, 0xFF14B8A6, 0xFFf97316,
  ];
  int _selectedColor = 0xFF0293ED;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.project!.name;
      _descController.text = widget.project!.description ?? '';
      _selectedColor = widget.project!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = context.read<AuthProvider>().currentUser!;
    final projectProvider = context.read<ProjectProvider>();

    if (_isEditing) {
      final updated = widget.project!.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        color: _selectedColor,
        updatedAt: DateTime.now(),
      );
      await projectProvider.updateProject(updated);
    } else {
      final project = Project(
        id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        color: _selectedColor,
        ownerId: user.id,
      );
      await projectProvider.createProject(project);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le projet' : 'Nouveau projet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom
              CustomTextField(
                label: 'Nom du projet',
                controller: _nameController,
                hint: 'Ex: Application mobile',
                prefixIcon: Icons.folder_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  if (v.trim().length < 3) return 'Minimum 3 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                label: 'Description (optionnel)',
                controller: _descController,
                hint: 'Décrivez votre projet...',
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 24),

              // Sélecteur couleur
              const Text(
                'Couleur du projet',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Color(color).withOpacity(0.5),
                            blurRadius: 8,
                          )
                        ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                          color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: _isEditing ? 'Modifier' : 'Créer le projet',
                isLoading: _isLoading,
                icon: _isEditing ? Icons.save : Icons.add,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}