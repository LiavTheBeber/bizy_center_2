import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../Classes/PhoneNumberInputField.dart';
import '../ViewModels/Auth_View_Model.dart';
import '../main.dart';
import 'package:http/http.dart' as http;


class adminRegisterPage extends StatefulWidget {
  const adminRegisterPage({super.key});

  @override
  _adminRegisterPage createState() => _adminRegisterPage();
}

class _adminRegisterPage extends State<adminRegisterPage> {
   final TextEditingController _usernameController = TextEditingController();
   final TextEditingController _collectionNameController = TextEditingController();
   final TextEditingController _igController = TextEditingController();
   final TextEditingController _businessNameController = TextEditingController();
   final TextEditingController _GMapsController = TextEditingController();

   final String _kGoogleApiKey = 'AIzaSyDVwf6MiWdAl9UbwNdkyTngu3L30tO85H4';
   List<dynamic> _placeList = [];
   String? _sessionToken;
   late FocusNode _focusNode;
   bool isAlreadySelected = false;
   String? _oldText;


   AuthViewModel? _authViewModel;

   String? _availableCollectionId;

   void _updateUsername(){
     _authViewModel?.updateUsernameReg(_usernameController.text);
   }
   void _updateCollectionName(){
     _authViewModel?.updateCollectionName(_collectionNameController.text);
   }
   void _updateIGReg(){
     _authViewModel?.updateIGReg(_igController.text);
   }
   void _updateBusinessNameReg(){
     _authViewModel?.updateBusinessNameReg(_businessNameController.text);
   }

   Future<void> setAvailableCollectionId() async{
     _availableCollectionId = await _authViewModel?.getCollectionIDField();
   }

   void fetchTextFields(){
     // Retrieve the last information from the AuthViewModel and set it as the initial value for the EditText
     _usernameController.text = _authViewModel?.usernameReg ?? '';
     _collectionNameController.text = _authViewModel?.collectionName ?? '';
     _igController.text = _authViewModel?.igReg ?? '';
     _businessNameController.text = _authViewModel?.businessNameReg ?? '';
     _GMapsController.text = _authViewModel?.locationReg ?? '';
   }

   bool? isFieldsValid() {
     PhoneNumber? _phoneNumber = _authViewModel?.phoneNumber;
     final isValidNumber = _phoneNumber!.phoneNumber != null && _phoneNumber.phoneNumber!.isNotEmpty && _phoneNumber.phoneNumber!.length > 9;
     if (!isValidNumber) {
       Fluttertoast.showToast(
         msg: "הזן בבקשה מספר טלפון תקין",
         toastLength: Toast.LENGTH_SHORT,
         gravity: ToastGravity.BOTTOM,
         timeInSecForIosWeb: 1,
         backgroundColor: Colors.black,
         textColor: Colors.white,
         fontSize: 16.0,
       );
       return false;
     }

     if (_usernameController.text.isEmpty ||
         _igController.text.isEmpty ||
         _businessNameController.text.isEmpty ||
         _authViewModel!.locationReg!.isEmpty) {
       Fluttertoast.showToast(
         msg: "בבקשה מלא/י את כל השדות",
         toastLength: Toast.LENGTH_SHORT,
         gravity: ToastGravity.BOTTOM,
         timeInSecForIosWeb: 1,
         backgroundColor: Colors.black,
         textColor: Colors.white,
         fontSize: 16.0,
       );
       return false;
     }

     if(_collectionNameController.text.isEmpty || _collectionNameController.text != _availableCollectionId){
       Fluttertoast.showToast(
         msg: "הזן בבקשה קוד תקין",
         toastLength: Toast.LENGTH_SHORT,
         gravity: ToastGravity.BOTTOM,
         timeInSecForIosWeb: 1,
         backgroundColor: Colors.black,
         textColor: Colors.white,
         fontSize: 16.0,
       );
       return false;
     }

     // If all fields are valid, return true
     return true;
   }

   Future<void> signInWithGoogleUser(BuildContext context) async {
     try {
       User? user = await _authViewModel?.signInWithGoogle();
       if (user != null) {
         await _authViewModel?.addAdminUserToFirestore();
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (context) => const adminAppPages()),
         );
         _authViewModel?.resetAdminRegisterVars();
       } else {
         print('Sign-in failed');
         // Optionally, show an error message to the user
         Fluttertoast.showToast(msg: "כניסה עם משתמש הינה חובה",toastLength: Toast.LENGTH_SHORT);
       }
     } catch (error) {
       print('Error signing in: $error');
       // Optionally, show an error message to the user
     }
   }

   @override
   void initState() {
     super.initState();
     // Access the AuthViewModel instance
     WidgetsBinding.instance.addPostFrameCallback((_) {
       _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
       setAvailableCollectionId();
       // Listener in order to update The AuthViewModel
       _usernameController.addListener(_updateUsername);
       _collectionNameController.addListener(_updateCollectionName);
       _igController.addListener(_updateIGReg);
       _businessNameController.addListener(_updateBusinessNameReg);
       _GMapsController.addListener(onChange);

       fetchTextFields();
     });
     _focusNode = FocusNode();
   }

   @override
   void dispose(){
     _usernameController.dispose();
     _collectionNameController.dispose();
     _igController.dispose();
     _businessNameController.dispose();
     _GMapsController.dispose();
     _focusNode.dispose();
     super.dispose();
   }

   void onChange() {
     _authViewModel?.updateLocationReg(_GMapsController.text);
     if(_oldText != _GMapsController.text){
       setState(() {
         isAlreadySelected = false;
       });
     } else{
       setState(() {
         isAlreadySelected = true;
       });
     }
     if (_sessionToken == null) {
       setState(() {
         _sessionToken = const Uuid().v4();
       });
     }
     if(!isAlreadySelected){
       getSuggestion(_GMapsController.text);
     }
   }
   void getSuggestion(String input) async {
     if (input.isEmpty) {
       setState(() {
         _placeList = [];
       });
       return;
     }

     String baseURL =
         'https://maps.googleapis.com/maps/api/place/autocomplete/json';
     String request =
         '$baseURL?input=$input&key=$_kGoogleApiKey&sessiontoken=$_sessionToken&components=country:il&language=he';

     var response = await http.get(Uri.parse(request));
     if (response.statusCode == 200) {
       setState(() {
         _placeList = json.decode(response.body)['predictions'];
       });
     } else {
       throw Exception('Failed to load predictions');
     }
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff3a57e8),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 30, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xffffffff),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 80, 0, 0),
                padding: const EdgeInsets.all(0),
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32.0),
                      topRight: Radius.circular(32.0)),
                  border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Align(
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _usernameController,
                              obscureText: false,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                              decoration: InputDecoration(
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                labelText: "שם מלא",
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16,
                                  color: Color(0xff000000),
                                ),
                                filled: true,
                                fillColor: const Color(0xffffffff),
                                isDense: false,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                suffixIcon: const Icon(Icons.person,
                                    color: Color(0xff212435), size: 24),
                              ),
                            ),
                          ),
                        ),
                        const PhoneNumberInputField(
                          fromWhichPage: "adminRegisterPage",
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: TextField(
                            focusNode: _focusNode,
                            controller: _GMapsController,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff000000),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff000000),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                  color: Color(0xff000000),
                                  width: 1,
                                ),
                              ),
                              labelText: 'כתובת עסק',
                              hintStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff9e9e9e),
                              ),
                              filled: true,
                              fillColor: const Color(0xffffffff),
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              suffixIcon: const Icon(
                                Icons.map,
                                color: Color(0xff212435),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        if (_placeList.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _placeList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(_placeList[index]['description']),
                                  onTap: () {
                                    setState(() {
                                      _oldText = _placeList[index]['description'];
                                      _GMapsController.text = _placeList[index]['description'];
                                      _placeList = [];
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Align(
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _igController,
                              obscureText: false,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                              decoration: InputDecoration(
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                labelText: "קישור לאינסטגרם",
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16,
                                  color: Color(0xff000000),
                                ),
                                filled: true,
                                fillColor: const Color(0xffffffff),
                                isDense: false,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                suffixIcon: const Icon(Icons.link,
                                    color: Color(0xff212435), size: 24),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Align(
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _businessNameController,
                              obscureText: false,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                              decoration: InputDecoration(
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                labelText: "שם עסק",
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16,
                                  color: Color(0xff000000),
                                ),
                                filled: true,
                                fillColor: const Color(0xffffffff),
                                isDense: false,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                suffixIcon: const Icon(Icons.business,
                                    color: Color(0xff212435), size: 24),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Align(
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _collectionNameController,
                              obscureText: false,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                              decoration: InputDecoration(
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xff000000), width: 1),
                                ),
                                labelText: "קוד בעל עסק",
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16,
                                  color: Color(0xff000000),
                                ),
                                filled: true,
                                fillColor: const Color(0xffffffff),
                                isDense: false,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                suffixIcon: const Icon(Icons.code,
                                    color: Color(0xff212435), size: 24),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: MaterialButton(
                            onPressed: () async {
                              bool? isValid = isFieldsValid();
                              if(isValid!){
                                await signInWithGoogleUser(context);
                              }
                            },
                            color: const Color(0xff3a57e8),
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(
                                  color: Color(0xffffffff), width: 1),
                            ),
                            padding: const EdgeInsets.all(16),
                            textColor: const Color(0xffffffff),
                            height: 45,
                            minWidth: MediaQuery.of(context).size.width,
                            child: const Text(
                              " Google היכנס באמצעות",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


