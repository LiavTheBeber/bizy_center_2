import 'dart:convert';

import 'package:bizy_center2/ViewModels/Auth_View_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class MyGoogleMapsField extends StatefulWidget {
  @override
  _MyGoogleMapsFieldState createState() => _MyGoogleMapsFieldState();
}

class _MyGoogleMapsFieldState extends State<MyGoogleMapsField> {
  final TextEditingController _GMapsController = TextEditingController();
  final String _kGoogleApiKey = 'AIzaSyDVwf6MiWdAl9UbwNdkyTngu3L30tO85H4';
  List<dynamic> _placeList = [];
  String? _sessionToken;
  late FocusNode _focusNode;
  bool isAlreadySelected = false;
  String? _oldText;
  AuthViewModel? _authViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      // Listener in order to update The AuthViewModel
      _GMapsController.addListener(onChange);
      _focusNode = FocusNode();
      fetchTextField();
    });
  }

  void fetchTextField(){
    // Retrieve the last information from the AuthViewModel and set it as the initial value for the EditText
    _GMapsController.text = _authViewModel?.locationReg ?? '';
  }

  @override
  void dispose() {
    _GMapsController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void onChange()  {
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: TextField(
            focusNode: _focusNode,
            controller: _GMapsController,
            textAlign: TextAlign.right,
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
              hintText: "כתובת",
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
      ],
    );
  }
}
