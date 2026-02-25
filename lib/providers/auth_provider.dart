import 'package:flutter/material.dart';
import 'package:sunu_task/models/User.dart';
import 'package:sunu_task/services/storage_service.dart';

/// Gère l'authentification et la session utilisateur
class AuthProvider extends ChangeNotifier {
  // ===== Propriétés privées =====
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // ===== Getters publics =====
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge l'utilisateur depuis le stockage au démarrage
  Future<void> init() async {
    final String? userId = StorageService.instance.currentUserId;
    if (userId != null) {
      _currentUser = await StorageService.instance.getUserById(userId);
      notifyListeners();
    }
  }

  /// Connexion : cherche un utilisateur par email + mot de passe
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<User> users = await StorageService.instance.getUsers();
      final User? found = users.cast<User?>().firstWhere(
            (u) => u!.email == email.trim() && u.password == password,
        orElse: () => null,
      );

      if (found != null) {
        _currentUser = found;
        await StorageService.instance.setCurrentUserId(found.id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Email ou mot de passe incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Une erreur est survenue';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription : crée un nouvel utilisateur
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Vérifier si l'email est déjà utilisé
      final List<User> users = await StorageService.instance.getUsers();
      final bool emailExists = users.any(
            (u) => u.email == email.trim(),
      );

      if (emailExists) {
        _error = 'Cet email est déjà utilisé';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Générer un ID unique simple (timestamp + random)
      final String newId =
          'user_${DateTime.now().millisecondsSinceEpoch}';

      final User newUser = User(
        id: newId,
        name: name.trim(),
        email: email.trim(),
        password: password,
        createdAt: DateTime.now(),
      );

      await StorageService.instance.saveUser(newUser);
      await StorageService.instance.setCurrentUserId(newId);
      _currentUser = newUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Une erreur est survenue';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await StorageService.instance.setCurrentUserId(null);
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Mise à jour du profil
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    final User updated = _currentUser!.copyWith(
      name: name,
      email: email,
    );
    await StorageService.instance.saveUser(updated);
    _currentUser = updated;

    _isLoading = false;
    notifyListeners();
  }

  /// Efface le message d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}