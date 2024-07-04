import 'package:bizy_center2/ViewModels/Auth_View_Model.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AuthPages/welcome_page.dart';
import '../Classes/urls.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  _CustomerHomePage createState() => _CustomerHomePage();
}


class _CustomerHomePage extends State<CustomerHomePage> {

  AuthViewModel? _authViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    });
  }

  void _openLink(Uri uri) async {
    final url = uri.toString();
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openWaze() {
    _openLink(AppUris.waze);
  }

  void _openIG() {
    _openLink(AppUris.instagram);
  }

   void _openWhatsApp() {
    _openLink(AppUris.whatsapp);
  }

  _navigateToWelcome() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomePage()));
  }

  Future<void> _signOut() async {
    User? user = await _authViewModel?.signOut();
    if(user == null){
      _navigateToWelcome();
    }
  }

  @override
  Widget build(BuildContext buildContext){
    return Scaffold(
      backgroundColor: const Color(0xffe2e5e7),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.all(0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: const Color(0xff272727),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Container(
                            height: 130,
                            width: 130,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset("assets/BarberLogoExample.png",
                                fit: BoxFit.cover),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      "מספרת עמית פלג",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 20,
                                        color: Color(0xffe2e2e2),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    GestureDetector(
                                      onTap: _openWaze,
                                      child: const Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "הנרקיס, אשקלון",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 18,
                                            color: Color(0xff226dff),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _openWaze,
                                      child: const Align(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.location_on,
                                          color: Color(0xff2888ff),
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                      child: GestureDetector(
                                        onTap: ()  {
                                          // Handle tap for Instagram
                                          _openIG();
                                          print("Instagram tapped");
                                        },
                                        child: const Text(
                                          "Instagram",
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 16,
                                            color: Color(0xffff00c7),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _openWhatsApp,
                                      child: const Text(
                                        "WhatsApp",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 16,
                                          color: Color(0xff2ff553),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 15, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _signOut();
                          } ,
                        child: const Icon(
                          Icons.settings,
                          color: Color(0xffd7d7d7),
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "ראה עוד",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                      color: Color(0xff3a57e8),
                    ),
                  ),
                  Text(
                    "תספורות פופולריות",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                      color: Color(0xff000000),
                    ),
                  ),
                ],
              ),
            ),
            GridView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.7,
              ),
              children: [
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.all(0),
                  width: 200,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0x00000000),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xffffffff),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child:

                        ///***If you have exported images you must have to copy those images in assets/images directory.
                        const Image(
                          image: NetworkImage(
                              "https://cdn.pixabay.com/photo/2016/03/05/19/02/hamburger-1238246_960_720.jpg"),
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Text(
                          "Fast Food",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.all(0),
                  width: 200,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0x00ffffff),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xffffffff),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child:

                        ///***If you have exported images you must have to copy those images in assets/images directory.
                        const Image(
                          image: NetworkImage(
                              "https://cdn.pixabay.com/photo/2016/03/05/23/02/barbecue-1239434_960_720.jpg"),
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Text(
                          "Meat",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.all(0),
                  width: 200,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0x00000000),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xffffffff),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child:

                        ///***If you have exported images you must have to copy those images in assets/images directory.
                        const Image(
                          image: NetworkImage(
                              "https://cdn.pixabay.com/photo/2016/03/05/22/31/prawns-1239307_960_720.jpg"),
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Text(
                          "Sea Food",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
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


