class AuthChangePasswordEntity {
  AuthChangePasswordEntity({
    required this.tbUserId,
    required this.salt,
    required this.newPassword,
  });

  int tbUserId;
  String salt;
  String newPassword;
}
