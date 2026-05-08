import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// Modelo de usuário para serialização/desserialização de JSON
@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.createdAt,
    super.phone,
    super.avatarUrl,
    super.isActive = true,
    super.updatedAt,
  });

  /// Converte uma User entity para UserModel
  factory UserModel.fromEntity(User user) => UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        createdAt: user.createdAt,
        phone: user.phone,
        avatarUrl: user.avatarUrl,
        isActive: user.isActive,
        updatedAt: user.updatedAt,
      );

  /// Cria um UserModel a partir do JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converte o UserModel para JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
