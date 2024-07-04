import 'package:bizy_center2/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../ViewModels/Auth_View_Model.dart';
import 'adminRegisterPage.dart';


class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomePage> {

  AuthViewModel? _authViewModel;

  @override
  void initState() {
    super.initState();

    // Access the AuthViewModel instance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    });

  }

  _navigateToAdminRegister()  {
    Navigator.push(context, MaterialPageRoute(builder: (context) =>  const adminRegisterPage()));
  }

  Future<void> signInWithGoogleUser(BuildContext context) async {
    try {
      User? user = await _authViewModel?.signInWithGoogle();
      if (user != null) {
        bool? isAdmin = await _authViewModel?.checkIfAdminLogged(user);
        if(isAdmin!){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const adminAppPages()),
          );
          _authViewModel?.resetAdminRegisterVars();
        }else{
          await _authViewModel?.addUserToFirestore();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
          _authViewModel?.resetAdminRegisterVars();
        }
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
  Widget build(BuildContext buildContext){
    return Scaffold(
      backgroundColor: const Color(0xff3a57e8),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                ///***If you have exported images you must have to copy those images in assets/images directory.
                Image(
                  image: NetworkImage(
                      "https://cdn3.iconfinder.com/data/icons/spring-23/32/butterfly-spring-insect-monarch-serenity-moth-flutter-128.png"),
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Company",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Color(0xffffd261),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                        child: Text(
                          "Logo",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            color: Color(0xffffffff),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                MaterialButton(
                  onPressed: () async {
                    await signInWithGoogleUser(context);
                  },
                  color: const Color(0xffffffff),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                  padding: const EdgeInsets.all(16),
                  textColor: const Color(0xff000000),
                  height: 50,
                  minWidth: MediaQuery.of(context).size.width,
                  child: const Text(
                    "היכנס באמצעות Google",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: MaterialButton(
                    onPressed: () {
                      _navigateToAdminRegister();
                    },
                    color: const Color(0xffffd261),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.0),
                    ),
                    padding: const EdgeInsets.all(16),
                    textColor: const Color(0xff5e5c5c),
                    height: 50,
                    minWidth: MediaQuery.of(context).size.width,
                    child: const Text(
                      "צור חשבון עסקי",
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
          ],
        ),
      ),
    );
  }
}

