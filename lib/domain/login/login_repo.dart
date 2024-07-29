import '../../data/login/login_model.dart';

abstract class LoginRepository {
  Future<LoginResponse> login(String mobile, String password);
}
