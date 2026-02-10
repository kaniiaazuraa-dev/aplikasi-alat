import 'package:flutter/material.dart';
import '../../../../../models/user_models.dart';
import '../../../../../services/user_service.dart';

class UserController extends ChangeNotifier {
  final UserService service;

  UserController(this.service);

  bool loading = true;
  List<UserModel> users = [];

  Future<void> loadUsers() async {
    loading = true;
    notifyListeners();

    users = await service.fetchUsers();

    loading = false;
    notifyListeners();
  }

  Future<bool> delete(String id) async {
    try {
      await service.deleteUser(id);
      await loadUsers();
      return true;
    } catch (e) {
      return false;
    }
  }
}
