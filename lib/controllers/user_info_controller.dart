import 'package:get/get.dart';
import 'package:abha/models/userModel.dart';
import 'package:get_storage/get_storage.dart'; // Assuming your ApiResponse model is defined here

class UserInfoController extends GetxController {
  final _userData = GetStorage('user_data');
  var userName = ''.obs;
  var userModel = Rxn<ApiResponse>();

  @override
  void onInit() {
    super.onInit();
    // Load the stored values into observables
    userName.value = _userData.read('name') ?? 'Hi User';

    // Load stored user response
    var storedUser = _userData.read('user');
    if (storedUser != null) {
      userModel.value = ApiResponse.fromJson(storedUser);
      print(userModel.value);
    }
  }

  set storeUserResponse(Map<String, dynamic> response) {
    // Convert the response to UserModel and store it
    userModel.value = ApiResponse.fromJson(response);

    _userData.write('user', userModel.value!.toJson()); // Store as JSON
  }
}
