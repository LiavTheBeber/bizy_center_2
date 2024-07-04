import 'package:bizy_center2/ViewModels/Auth_View_Model.dart';
import 'package:bizy_center2/ViewModels/MainViewModel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class PhoneNumberInputField extends StatefulWidget {
  final String fromWhichPage;
  final void Function(PhoneNumber)? onInputChanged;
  final bool autoValidate;
  final String initialCountry;

  const PhoneNumberInputField({
    Key? key,
    required this.fromWhichPage,
    this.onInputChanged,
    this.autoValidate = false,
    this.initialCountry = 'IL',
  }) : super(key: key);

  @override
  _PhoneNumberInputFieldState createState() => _PhoneNumberInputFieldState();
}

class _PhoneNumberInputFieldState extends State<PhoneNumberInputField> {
  late TextEditingController _controller;
  late PhoneNumber _phoneNumber;
  late bool mobileValid;

  AuthViewModel? _authViewModel;
  MainViewModel? _mainViewModel;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _mainViewModel = Provider.of<MainViewModel>(context, listen: false);
      _controller.addListener(_updateMobile);
      fetchTextFields();
    });
    _phoneNumber = PhoneNumber(isoCode: widget.initialCountry);
  }

  void fetchTextFields(){
    if(widget.fromWhichPage == "adminRegisterPage"){
      _controller.text = _authViewModel?.mobileReg ?? '';
    } else if(widget.fromWhichPage == "מספר טלפון"){
      _controller.text = _mainViewModel!.adminAccountSettings![1];
    }

  }

  void _updateMobile() {
    _authViewModel?.updateMobileReg(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateMobile);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber number) {
          setState(() {
            _phoneNumber = number;
          });
          _authViewModel?.updatePhoneNumber(number);
          print('authViewModel phoneNumberValue is: ${_authViewModel?.phoneNumber}');
          if (widget.onInputChanged != null) {
            widget.onInputChanged!(number);
          }
        },
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.DROPDOWN,
        ),
        ignoreBlank: false,
        autoValidateMode: widget.autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
        initialValue: _phoneNumber,
        textFieldController: _controller,
        inputDecoration: InputDecoration(
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: Color(0xff000000), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: Color(0xff000000), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: Color(0xff000000), width: 1),
          ),
          labelText: "מספר טלפון",
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 14,
            color: Color(0xff000000),
          ),
          filled: true,
          fillColor: const Color(0xffffffff),
          isDense: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          suffixIcon: const Icon(Icons.call, color: Color(0xff212435), size: 24),
        ),
        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
        formatInput: true,
        maxLength: 12,
        validator: (value) {
          if (value == null || value.isEmpty || value.length < 9) {
            Fluttertoast.showToast(
              msg: "בבקשה הכנס מספר בעל 9 ספרות",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            return 'Please enter a valid phone number';
          } else {
            mobileValid = true;
          }
          return null;
        },
      ),
    );
  }
}
