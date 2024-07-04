import 'package:bizy_center2/CustomerPages/orderPage.dart';
import 'package:bizy_center2/Repositorys/GoogleCalendarRepository.dart';
import 'package:flutter/cupertino.dart';

class MainViewModel extends ChangeNotifier{
  final GoogleCalendarRepository? googleCalendarRepository;
  List<String>? _adminAccountSettings;

  MainViewModel({required this.googleCalendarRepository}) {
    notifyListeners();
  }

  // Getter for adminAccountSettings
  List<String>? get adminAccountSettings => _adminAccountSettings;

  // Setter for adminAccountSettings
  void updateAdminAccountSettings(List<String>? value) {
    _adminAccountSettings = value;
    notifyListeners();
  }


}
