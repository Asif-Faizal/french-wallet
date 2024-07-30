import 'login_model.dart';

abstract class LoginRepository {
  Future<LoginResponse> login(String mobile, String password);
}
