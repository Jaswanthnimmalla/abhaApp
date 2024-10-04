import 'package:abha/models/userModel.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserInfo extends GetxService {
  final _userData = GetStorage('user_data');
  var userName = ''.obs;
  var userModel = Rxn<ApiResponse>();
  @override
  void onInit() {
    super.onInit();
    // Load the stored value into the observable when the service initializes

    userName.value = _userData.read('name') ?? 'Hi User';
  }

  set addUserLogin(bool isLogin) {
    _userData.write('isLogin', isLogin);
  }

  set storeUserResponse(Map<String, dynamic> response) {
    // Convert the response to UserModel and store it
    userModel.value = ApiResponse.fromJson(response);
    _userData.write('user', userModel.value!.toJson()); // Store as JSON
  }

  get getUserLogin {
    bool isLogin = _userData.read('isLogin') ?? false;

    print(isLogin);
    return isLogin;
  }

  set addUserToken(String token) {
    _userData.write('token', token);
    print('User data saved');
  }

  get getUserToken {
    String token = _userData.read('token') ?? '';

    return token;
  }

  set addUserName(String name) {
    _userData.write('name', name);
    print('User name saved');
    userName.value = name;
  }

  removeData() {
    _userData.remove("isLogin");
    _userData.remove('user');
  }
}
