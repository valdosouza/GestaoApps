import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// Modelo de usuário para serialização/desserialização de JSON
@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required String id,
    required String name,
    required String email,
    String? phone,
    String? avatarUrl,
    bool isActive = true,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
    id: id,
    name: name,
    email: email,
    phone: phone,
    avatarUrl: avatarUrl,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Cria um UserModel a partir do JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converte o UserModel para JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Converte uma User entity para UserModel
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
