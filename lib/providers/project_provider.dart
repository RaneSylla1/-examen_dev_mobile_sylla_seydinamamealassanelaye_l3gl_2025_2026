import 'package:flutter/material.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/services/storage_service.dart';

/// Gère la collection de projets de l'utilisateur
class ProjectProvider extends ChangeNotifier {
  // ===== Propriétés privées =====
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  // ===== Getters =====
  List<Project> get projects => List.unmodifiable(_projects);
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;

  /// Charge les projets d'un utilisateur
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    _projects = await StorageService.instance.getProjectsByUserId(userId);

    _isLoading = false;
    notifyListeners();
  }

  /// Crée un nouveau projet
  Future<void> createProject(Project project) async {
    await StorageService.instance.saveProject(project);
    _projects.add(project);
    notifyListeners();
  }

  /// Met à jour un projet existant
  Future<void> updateProject(Project project) async {
    await StorageService.instance.saveProject(project);
    final int index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
      // Mettre à jour le projet sélectionné si c'est le même
      if (_selectedProject?.id == project.id) {
        _selectedProject = project;
      }
    }
    notifyListeners();
  }

  /// Supprime un projet et toutes ses tâches
  Future<void> deleteProject(String projectId) async {
    await StorageService.instance.deleteProject(projectId);
    await StorageService.instance.deleteTasksByProjectId(projectId);
    _projects.removeWhere((p) => p.id == projectId);
    if (_selectedProject?.id == projectId) {
      _selectedProject = null;
    }
    notifyListeners();
  }

  /// Sélectionne un projet (pour afficher ses détails)
  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }

  /// Vide la liste (à la déconnexion)
  void clear() {
    _projects = [];
    _selectedProject = null;
    notifyListeners();
  }
}