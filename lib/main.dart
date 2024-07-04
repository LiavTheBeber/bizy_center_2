import 'package:bizy_center2/Repositorys/GoogleCalendarRepository.dart';
import 'package:bizy_center2/ViewModels/MainViewModel.dart';
import 'package:bizy_center2/adminPages/adminSettingsPage.dart';
import 'package:bizy_center2/adminPages/adminClientsPage.dart';
import 'package:bizy_center2/adminPages/adminHomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Classes/CustomBottomNavigationBar.dart';
import 'CustomerPages/CustomerHomePage.dart';
import 'ViewModels/Auth_View_Model.dart';
import 'CustomerPages/orderPage.dart';
import 'splash_screen.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyABd6mdkj0atIIqvg5IyKWLZMKi5FHylxA',
        appId: 'id',
        messagingSenderId: 'sendid',
        projectId: 'bizycenter2',
        storageBucket: 'myapp-b9yt18.appspot.com',
      )
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  //final serviceAccountManager = ServiceAccountManager();
  //await serviceAccountManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(),
        ),
        ChangeNotifierProvider<MainViewModel>(
          create: (context) => MainViewModel(googleCalendarRepository: GoogleCalendarRepository()),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CustomerHomePage(),
    const OrderPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class adminAppPages extends StatefulWidget{
  const adminAppPages({super.key});

  @override
  _adminAppPagesState createState() => _adminAppPagesState();
}

class _adminAppPagesState extends State<adminAppPages>{
  int _currentIndex = 0;

  final List<Widget> _pages = [
  const AdminHomePage(),
  const AdminClientsPage(),
  const AdminSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: adminBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}