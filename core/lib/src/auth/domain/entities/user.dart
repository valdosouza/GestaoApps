import 'package:equatable/equatable.dart';

/// Entidade que representa um usuário no sistema
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.phone,
    this.avatarUrl,
    this.isActive = true,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatarUrl,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// Cria uma cópia da entidade com campos opcionais alterados
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        createdAt: createdAt ?? this.createdAt,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isActive: isActive ?? this.isActive,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
