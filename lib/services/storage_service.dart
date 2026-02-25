import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';

import '../models/project.dart';


/**
 * Pattern Singleton:
 * Pour avoir une seule instance
 */
class StorageService {
  //===== Singleton ==========
  /// Instance Unique (privee)
  static StorageService? _instance;

  /// Getter pour acceder a l'instance
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Constructeur prive
  StorageService._();

  //===== SharedPreferences ==========
  /**
   * SharedPreferences utilise des opérations asynchrones
   * car il lit/ecrtit sur le disque
   *
   * Le mot-cle await attend que l'operation se termine
   * La fonction doit etre marque async et retourner un Future
   * Les variables doivent être marqué par late
   */
  late SharedPreferences _prefs;

  /// Indicateur d'initialisation
  bool _initialized = false;

  Future<void> init() async {
    if(_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Cles de Stockage =========
  static const String _keyOnboardingConmplete = 'onboarding_complete';
  static const String _keyCurrentUserId = 'current_user_id';
  static const String _keyUsers = 'users';
  static const String _keyProjects = 'projects';
  static const String _keyTasks = 'tasks';
  static const String _keyComments = 'comments';


  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingConmplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingConmplete, value);
  }




  // ======== Utilisateurs =========

  Future<List<User>> getUsers() async {
    final String? data = _prefs.getString(_keyUsers);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data) as List<dynamic>;
    return list
        .map((e) => User.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveUser(User user) async {
    final List<User> users = await getUsers();
    final int index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _prefs.setString(
      _keyUsers,
      jsonEncode(users.map((u) => u.toMap()).toList()),
    );
  }

  Future<User?> getUserById(String id) async {
    final List<User> users = await getUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  // ======== Session utilisateur =========

  String? get currentUserId => _prefs.getString(_keyCurrentUserId);

  Future<void> setCurrentUserId(String? id) async {
    if (id == null) {
      await _prefs.remove(_keyCurrentUserId);
    } else {
      await _prefs.setString(_keyCurrentUserId, id);
    }
  }

  // ======== Projets =========

  Future<List<Project>> getProjects() async {
    final String? data = _prefs.getString(_keyProjects);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data) as List<dynamic>;
    return list
        .map((e) => Project.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Project>> getProjectsByUserId(String userId) async {
    final List<Project> projects = await getProjects();
    return projects.where((p) => p.ownerId == userId).toList();
  }

  Future<void> saveProject(Project project) async {
    final List<Project> projects = await getProjects();
    final int index = projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await _prefs.setString(
      _keyProjects,
      jsonEncode(projects.map((p) => p.toMap()).toList()),
    );
  }

  Future<void> deleteProject(String projectId) async {
    final List<Project> projects = await getProjects();
    projects.removeWhere((p) => p.id == projectId);
    await _prefs.setString(
      _keyProjects,
      jsonEncode(projects.map((p) => p.toMap()).toList()),
    );
  }





}