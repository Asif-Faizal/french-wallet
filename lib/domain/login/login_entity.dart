import '../../data/login/login_model.dart';

class LoginEntity {
  final String status;
  final String message;

  LoginEntity({
    required this.status,
    required this.message,
  });

  factory LoginEntity.fromResponse(LoginResponse response) {
    return LoginEntity(
      status: response.status,
      message: response.message,
    );
  }
}
