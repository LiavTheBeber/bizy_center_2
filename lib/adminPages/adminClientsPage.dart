import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Classes/ContactList.dart';
import '../ViewModels/Auth_View_Model.dart';



class AdminClientsPage extends StatefulWidget {
  const AdminClientsPage({super.key});

  @override
  _AdminClientsPage createState() => _AdminClientsPage();
}

class _AdminClientsPage extends State<AdminClientsPage> {
  ContactList? contactList;
  AuthViewModel? _authViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    });
  }



  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff6f6f6),
      appBar: AppBar(
        backgroundColor: Color(0xFF3C3B3B),
        automaticallyImplyLeading: false,
        title: Text(
          "הלקוחות שלי",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 18,
            color: Color(0xffe4e4e4),
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              child: TextField(
                controller: TextEditingController(),
                obscureText: false,
                textAlign: TextAlign.right,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  color: Color(0xff000000),
                ),
                decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(color: Color(0xff000000), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(color: Color(0xff000000), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(color: Color(0xff000000), width: 1),
                  ),
                  hintText: "...חפש/י כאן",
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    color: Color(0xff000000),
                  ),
                  filled: true,
                  fillColor: Color(0xffa4a4a4),
                  isDense: false,
                  contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                  prefixIcon: Icon(Icons.search, color: Color(0xff212435), size: 24),
                ),
              ),
            ),
            Divider(
              color: Color(0xff808080),
              height: 16,
              thickness: 0,
              indent: 0,
              endIndent: 0,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 12),
              child: Consumer<AuthViewModel>(
                builder: (context, authViewModel, child) {
                  int? _userCount = authViewModel.contacts?.length;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "$_userCount",
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          ":סך הלקוחות",
                          textAlign: TextAlign.right,
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
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: ContactList(), // Replace ListView with ContactList widget
            ),
          ],
        ),
      ),
    );
  }
}

