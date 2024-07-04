import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../Classes/ContactList.dart';
import '../Repositorys/auth_repository.dart';
import 'package:flutter/material.dart';



class AuthViewModel extends ChangeNotifier{
  // General Variables
  String? _usernameReg,_mobileReg,_collectionName,_igReg, _locationReg,_businessNameReg;
  User? _user;
  final AuthRepository? _authRepository;
  String? _userAccessToken;
  String? _businessAccessToken;
  late String _accessToken;
  List<Contact>? _contacts;

  Map<String, dynamic>? _selectedPlaceDetails;

  final String _kGoogleApiKey = 'AIzaSyDVwf6MiWdAl9UbwNdkyTngu3L30tO85H4';
  PhoneNumber? _phoneNumber;

  // Settings Page vars
  String? _businessName,_mobile,_igLink;
  List<String> _setTimes = [], _minimalTime = [];


  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _user = _authRepository?.currentUser;
    _authRepository?.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Getters
  String? get usernameReg => _usernameReg;
  String? get mobileReg => _mobileReg;
  String? get collectionName => _collectionName;
  String? get userAccessToken => _userAccessToken;
  String? get businessAccessToken => _businessAccessToken;
  User? get user => _user;
  List<Contact>? get contacts => _contacts;
  String? get igReg => _igReg;
  String? get locationReg => _locationReg;
  String? get businessNameReg => _businessNameReg;
  Map<String, dynamic>? get selectedPlaceDetails => _selectedPlaceDetails;
  PhoneNumber? get phoneNumber => _phoneNumber;

  // Getters for Settings Page
  String? get businessName => _businessName;
  String? get mobile => _mobile;
  String? get igLink => _igLink;
  List<String> get setTimes => _setTimes;
  List<String> get minimalTime => _minimalTime;

  // Setters
  void updatePhoneNumber(PhoneNumber number) {
    _phoneNumber = number;
    notifyListeners();
  }
  void updateUsernameReg(String newUsernameReg){
    _usernameReg = newUsernameReg;
    notifyListeners();
  }
  void updateMobileReg(String newMobileReg){
    _mobileReg = newMobileReg;
    notifyListeners();
  }
  void updateCollectionName(String newCollectionName){
    _collectionName = newCollectionName;
    notifyListeners();
  }
  void updateUserAccessToken(String newAccessToken){
    _userAccessToken = newAccessToken;
    notifyListeners();
  }
  void updateAdminAccessToken(String newAccessToken){
    _businessAccessToken = newAccessToken;
    notifyListeners();
  }
  void updateContactList(List<Contact> newContactList){
    _contacts = newContactList;
    notifyListeners();
  }
  void updateIGReg(String newIGReg){
    _igReg = newIGReg;
    notifyListeners();
  }
  void updateLocationReg(String newLocationReg){
    _locationReg = newLocationReg;
    notifyListeners();
  }
  void updateSelectedPlaceDetails(Map<String, dynamic> newSelectedPlaceDetails){
    _selectedPlaceDetails = newSelectedPlaceDetails;
    notifyListeners();
  }
  void updateBusinessNameReg(String newBusinessNameReg){
    _businessNameReg = newBusinessNameReg;
    notifyListeners();
  }

  // Setters For Settings Page
  void updateBusinessName(String newBusinessName){
    _businessName = newBusinessName;
    notifyListeners();
  }
  void updateMobile(String newMobile){
    _mobile = newMobile;
    notifyListeners();
  }
  void updateIgLink(String newIgLink){
    _igLink = newIgLink;
    notifyListeners();
  }
  void updateSetTimes(List<String> newSetTimes){
    _setTimes = newSetTimes;
    notifyListeners();
  }
  void updateMinimalTime(List<String> newMinimalTime){
    _minimalTime = newMinimalTime;
    notifyListeners();
  }

  void resetAdminRegisterVars(){
    _usernameReg = '';
    _mobileReg = '';
    _collectionName = '';
    _igReg = '';
    _locationReg = '';
    _businessNameReg = '';
  }




  // General Functions
  Future<bool?> isUserConnected() async {
    try {
      bool? isConnected  = await _authRepository?.isUserConnected();
      _userAccessToken = _authRepository?.accessToken;
      print('UserAccessToken via ViewModel is: $_userAccessToken');
      return isConnected;
    } catch (e) {
      // Optionally handle errors here
      return false;
    }
  }

  Future<bool?> checkIfAdminLogged(User? user) async {
    return await _authRepository?.checkIfAdminLogged(user!);
  }


  Future<User?> signInWithGoogle() async {
    _user = await _authRepository?.signInWithGoogle();
    _userAccessToken = _authRepository?.accessToken;
    print('UserAccessToken via ViewModel is: $_userAccessToken');
    notifyListeners();
    return _user;
  }


  Future<void> addAdminUserToFirestore() async {
    await getPlaceId(locationReg!);
    await _authRepository?.addAdminUserToFirestore(_user!, 'BarberCollection', 'admin', usernameReg!, mobileReg!, locationReg!, igReg!,selectedPlaceDetails!,businessNameReg!);
  }

  Future<void> addUserToFirestore() async {
    await _authRepository?.addUserToFirestore(_user!, 'BarberCollection');
  }

  Future<User?> signOut() async {
    await _authRepository?.signOut();
    _user = null;
    notifyListeners();
    return _user;
  }

  Future<bool?> isUserExist(String? email) async {
    return await _authRepository?.isUserExist(email!);
  }

  Future<void> deleteUser(String documentId) async {
    await _authRepository?.deleteUser(documentId);
  }

  Future<int> getUserAmount(String documentId) async {
    return await _authRepository!.getUsersAmount(documentId);
  }

  Future<void> getPlaceDetails(String placeId) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$baseURL?placeid=$placeId&key=$_kGoogleApiKey';

    print('Requesting place details from URL: $request');

    var response = await http.get(Uri.parse(request));

    print('Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      _selectedPlaceDetails = json.decode(response.body)['result'];
      print('Selected place details: $_selectedPlaceDetails');
    } else {
      print('Failed to load place details. Response body: ${response.body}');
      throw Exception('Failed to load place details');
    }
  }
  Future<void> getPlaceId(String input) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=${Uri.encodeComponent(input)}&key=$_kGoogleApiKey&language=he&components=country:il';

    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      var predictions = json.decode(response.body)['predictions'];
      if (predictions.isNotEmpty) {
        String placeId = predictions[0]['place_id'];
        print('Place ID: $placeId');
        await getPlaceDetails(placeId);
      } else {
        print('No place predictions found.');
      }
    } else {
      print('Failed to load place predictions. Response body: ${response.body}');
    }
  }

  Future<String?> getCollectionIDField() async {
    return await _authRepository?.getCollectionIDField();
  }
  Future<List<String>?> getAdminAccountSettings() async {
    return await _authRepository?.getAdminAccountSettings();
  }
  Future<void> updateAdminAccountSettings(List<String> newList) async {
    await _authRepository?.updateAdminAccountSettings(newList);
  }
}
