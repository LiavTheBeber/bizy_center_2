import 'package:bizy_center2/Classes/ServiceAccountManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AuthPages/welcome_page.dart';
import 'ViewModels/Auth_View_Model.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthViewModel? _authViewModel;
  ServiceAccountManager? serviceAccountManager;

  Future<void> checkUserConnection() async {
    bool? isConnected = await _authViewModel?.isUserConnected();
    print('isConnectedValue: $isConnected');
    if (isConnected!) {
      print('userValueIs : ${_authViewModel?.user}');
      bool? isAdmin = await _authViewModel?.checkIfAdminLogged(_authViewModel?.user);
      print('isAdminValue: $isAdmin');
      if(isAdmin!){
        _navigateToAdminHome();
      }else{
        String _accessToken = await _initServiceManager();
        _authViewModel?.updateAdminAccessToken(_accessToken);
        print('Connected User accessToken is: ${_authViewModel?.userAccessToken}');
        print('BusinessToken from splash Is: $_accessToken');
        _navigateToCustomerHome();
      }
    } else {
      _navigateToWelcome();
    }
  }

  Future<String> _initServiceManager() async {
    try {
      await ServiceAccountManager().initialize();
      return ServiceAccountManager().accessToken;
    } catch (error) {
      print('Error initializing ServiceAccountManager: $error');
      return 'Error: $error';
    }
  }

  @override
  void initState() {
    super.initState();
    // Access the AuthViewModel instance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      checkUserConnection();
    });
  }

  _navigateToCustomerHome() async {
    await Future.delayed(const Duration(milliseconds: 200), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const MyHomePage()));
  }
  _navigateToAdminHome() async {
    await Future.delayed(const Duration(milliseconds: 200), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const adminAppPages()));
  }

  _navigateToWelcome() async {
    await Future.delayed(const Duration(milliseconds: 2000), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const WelcomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ///***If you have exported images you must have to copy those images in assets/images directory.
            Image(
              image: AssetImage("assets/splashLogo.png"),
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Text(
                "BizyCenter",
                textAlign: TextAlign.start,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  fontSize: 32,
                  color: Color(0xff000000),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

