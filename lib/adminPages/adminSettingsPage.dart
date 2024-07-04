import 'package:bizy_center2/AuthPages/welcome_page.dart';
import 'package:bizy_center2/ViewModels/Auth_View_Model.dart';
import 'package:bizy_center2/ViewModels/MainViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Classes/EditSettingsDetailsDialog.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  _AdminSettingsPage createState() => _AdminSettingsPage();
}

class _AdminSettingsPage extends State<AdminSettingsPage> {
  AuthViewModel? _authViewModel;
  MainViewModel? _mainViewModel;

  // State to manage expanded items
  bool isAccountSettingsExpanded = false;
  bool isCalendarSettingsExpanded = false;

  List<String> accountSettingsTitles = ['הגדרות חשבון','שם העסק','מספר טלפון','כתובת אינסטגרם'];
  List<String> diarySettingsTitles = ['הגדרות יומן','זמני קביעות','מינימום זמן לקביעת תור','ימי חופש קבועים'];

  List<String> accountSettingsSubTitles = ['','',''];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _mainViewModel = Provider.of<MainViewModel>(context, listen: false);
      fetchAccountSettingsSubTitles();
    });
  }

  Future<void> fetchAccountSettingsSubTitles() async {
    print('started fetching account settings items');
    List<String>? subTitleValues = await _authViewModel?.getAdminAccountSettings();
    print('subTitleValues: ${subTitleValues}');
    _mainViewModel?.updateAdminAccountSettings(subTitleValues);
    updateAccountInfoSubTitles();
  }

  void updateAccountInfoSubTitles(){
    setState(() {
      accountSettingsSubTitles = ['${_mainViewModel?.adminAccountSettings![0]}','${_mainViewModel?.adminAccountSettings![1]}','${_mainViewModel?.adminAccountSettings![2]}'];
    });
  }



  Future<void> updateAdminSettingsSubTitles(String title,String newValue) async {
    // Check businessName
    if(title == accountSettingsTitles[1]){
      setState(() {
        accountSettingsSubTitles[0] = newValue;
        _mainViewModel?.updateAdminAccountSettings(accountSettingsSubTitles);
      });
      updateAccountInfoSubTitles();
      await _authViewModel?.updateAdminAccountSettings(_mainViewModel!.adminAccountSettings!);
    }
    // Check mobile
    else if(title == accountSettingsTitles[2]){
      setState(() {
        accountSettingsSubTitles[1] = newValue;
        _mainViewModel?.updateAdminAccountSettings(accountSettingsSubTitles);
      });
      updateAccountInfoSubTitles();
      await _authViewModel?.updateAdminAccountSettings(_mainViewModel!.adminAccountSettings!);
    }
    // Check IgLink
    else if(title == accountSettingsTitles[3]){
      setState(() {
        accountSettingsSubTitles[2] = newValue;
        _mainViewModel?.updateAdminAccountSettings(accountSettingsSubTitles);
      });
      updateAccountInfoSubTitles();
      await _authViewModel?.updateAdminAccountSettings(_mainViewModel!.adminAccountSettings!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> signOut() async {
    await _authViewModel?.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  void showEditSettingsDetailsDialog(String title, String subTitleValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditSettingsDetailsDialog(
          title: title,
          subTitleValue: subTitleValue,
          onConfirm: (newValue) {
            updateAdminSettingsSubTitles(title,newValue);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void toggleAccountSettings() {
    setState(() {
      isAccountSettingsExpanded = !isAccountSettingsExpanded;
    });
  }

  void toggleCalendarSettings() {
    setState(() {
      isCalendarSettingsExpanded = !isCalendarSettingsExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF3C3B3B),
        automaticallyImplyLeading: false,
        title: Text(
          "הגדרות",
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                buildMainItem(
                  title: accountSettingsTitles[0],
                  isExpanded: isAccountSettingsExpanded,
                  onTap: toggleAccountSettings,
                  subItems: [
                    buildListTile(
                      context,
                      icon: Icons.edit,
                      title: accountSettingsTitles[1],
                      subtitle: accountSettingsSubTitles[0],
                      onIconTap: () => showEditSettingsDetailsDialog(accountSettingsTitles[1], accountSettingsSubTitles[0]),
                    ),
                    buildListTile(
                      context,
                      icon: Icons.edit,
                      title: accountSettingsTitles[2],
                      subtitle: '0${accountSettingsSubTitles[1]}',
                      onIconTap: () => showEditSettingsDetailsDialog(accountSettingsTitles[2], accountSettingsSubTitles[1]),
                    ),
                    buildListTile(
                      context,
                      icon: Icons.edit,
                      title: accountSettingsTitles[3],
                      subtitle: accountSettingsSubTitles[2],
                      onIconTap: () => showEditSettingsDetailsDialog(accountSettingsTitles[3], accountSettingsSubTitles[2]),
                    ),
                  ],
                ),
                Divider(
                  thickness: 2,
                  color: Color(0xCC545454),
                ),
                buildMainItem(
                  title: diarySettingsTitles[0],
                  isExpanded: isCalendarSettingsExpanded,
                  onTap: toggleCalendarSettings,
                  subItems: [
                    buildListTile(
                      context,
                      icon: Icons.edit,
                      title: diarySettingsTitles[1],
                      subtitle: 'ניתן לקבוע עד כשבועיים מראש',
                      onIconTap: () => showEditSettingsDetailsDialog(diarySettingsTitles[1], 'ניתן לקבוע עד כשבועיים מראש'),
                    ),
                    buildListTile(
                      context,
                      icon: Icons.edit,
                      title: diarySettingsTitles[2],
                      subtitle: 'לא ניתן לקבוע מתחת ל12 שעות מראש',
                      onIconTap: () => showEditSettingsDetailsDialog(diarySettingsTitles[2], 'לא ניתן לקבוע מתחת ל12 שעות מראש'),
                    ),
                    buildListTile(
                      context,
                      icon: Icons.edit,
                      title: diarySettingsTitles[3],
                      subtitle: 'ימי החופש הקבועים הם שני ושבת',
                      onIconTap: () => showEditSettingsDetailsDialog(diarySettingsTitles[3], 'ימי החופש הקבועים הם שני ושבת'),
                    ),
                  ],
                ),
                Divider(
                  thickness: 2,
                  color: Color(0xCC545454),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: ElevatedButton(
                    onPressed: () {
                      signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEF393C),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'צא/י מהמשתמש',
                      style: TextStyle(
                        fontFamily: 'Readex Pro',
                        color: Colors.white,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMainItem({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> subItems,
  }) {
    String subTitles = '';
    if (title == accountSettingsTitles[0]) {
      subTitles = '${accountSettingsTitles[1]}, ${accountSettingsTitles[2]}, ${accountSettingsTitles[3]}';
    } else if (title == diarySettingsTitles[0]){
      subTitles = '${diarySettingsTitles[1]}, ${diarySettingsTitles[2]}, ${diarySettingsTitles[3]}';
    }
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
            ),
          ),
          subtitle: Text(
            subTitles,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontFamily: 'Readex Pro',
              letterSpacing: 0,
            ),
          ),
           leading: Icon(
            isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
        if (isExpanded)
          ...subItems.map((child) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: child,
          ))
      ],
    );
  }

  ListTile buildListTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onIconTap}) {
    return ListTile(
      leading: GestureDetector(
        onTap: onIconTap,
        child: Icon(icon),
      ),
      title: Text(
        title,
        textAlign: TextAlign.end,
        style: TextStyle(
          fontFamily: 'Outfit',
          letterSpacing: 0,
        ),
      ),
      subtitle: Text(
        subtitle,
        textAlign: TextAlign.end,
        style: TextStyle(
          fontFamily: 'Readex Pro',
          letterSpacing: 0,
        ),
      ),
      tileColor: Color(0xFFCCCCCC),
      dense: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}



