/// Modèle de données pour un Projet
class Project {
  final String id;
  final String name;
  final String? description;

  /// Couleur du projet en valeur hexadécimale (ex: 0xFF0293ED)
  final int color;

  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Project copyWith({
    String? id,
    String? name,
    String? description,
    int? color,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as int,
      ownerId: map['ownerId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  String toString() => 'Project(id: $id, name: $name)';
}