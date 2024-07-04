import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleAuth;
  final FirebaseFirestore _firebaseFirestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firebaseFirestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleAuth = googleSignIn ?? GoogleSignIn(
          scopes: [
            'email',
            'https://www.googleapis.com/auth/calendar',
            'https://www.googleapis.com/auth/contacts.readonly'
          ],
        ),
        _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance {
    // Listen to authentication state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      _currentUser = user;
      // Optionally, you can notify listeners or handle other updates here
    });
  }

  User? _currentUser;
  String? _accessToken;

  // Getters
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;

  FirebaseFirestore firebaseDB = FirebaseFirestore.instance;




  Future<List<String>> getTopLevelCollections() async {
    List<String> topLevelCollections = [];
    try {
      // Fetch document snapshot
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('adminSettings')
          .doc('topLevelCollections')
          .get();

      if (snapshot.exists) {
        // Get the array field 'collectionNames'
        List<dynamic> collectionNames = snapshot.get('collectionNames');

        // Convert dynamic list to List<String>
        topLevelCollections = List<String>.from(collectionNames);
        print('found collectionNames: $topLevelCollections');
      }
    } catch (e) {
      print('Error fetching collection names: $e');
    }

    return topLevelCollections;
  }

  Future<String?> getCollectionIDField() async {
    try {
      // Fetch document snapshot
      DocumentSnapshot snapshot = await _firebaseFirestore
          .collection('adminSettings')
          .doc('collectionID')
          .get();

      if (snapshot.exists) {
        // Get the array field 'collectionNames'
        print('found collectionId: ${snapshot.get('collectionIDField')}');
        return snapshot.get('collectionIDField');

      }
    } catch (e) {
      print('Error fetching collection names: $e');
    }
    return null;
  }



  Future<bool> checkIfAdminLogged(User user) async {
    try {
      final email = user.email;
      if (email == null) {
        print('User email is null');
        return false; // Return false if user email is null
      }

      // Define a list of top-level collections you want to check
      List<String> topLevelCollections = await getTopLevelCollections();// Add your collection names here

      for (var collectionName in topLevelCollections) {
        final collectionRef = FirebaseFirestore.instance.collection(collectionName);
        final adminDocSnapshot = await collectionRef.doc('admin').get();

        if (adminDocSnapshot.exists) {
          final adminData = adminDocSnapshot.data();
          print('Admin data found in $collectionName: $adminData');
          if (adminData != null && adminData['email'] == email) {
            print('User is an admin in $collectionName');
            return true;
          }
        }
      }
    } catch (e) {
      print('Error checking admin status: $e');
    }
    print('User is not an admin');
    return false;
  }


  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleAuth.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      _currentUser = userCredential.user;
      _accessToken = googleAuth.accessToken; // Store the access token as a string
      print('accessToken is: $_accessToken');
      return _currentUser;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<void> addAdminUserToFirestore(User user,String collectionName,String docID,String username,String mobile,String location,String igReg,Map<String, dynamic> selectedPlaceDetails,String businessName) async {
    String whatsappLink = 'https://wa.me/0$mobile';
    try {
      await firebaseDB.collection(collectionName).doc(docID).set({
        'email': user.email,
        'displayName': username,
        'mobile number' : mobile,
        'location' : location,
        'igLink' : igReg,
        'whatsappLink' : whatsappLink,
        'businessName' : businessName,
        'selectedPlaceDetails' : selectedPlaceDetails,
      });
      // set array variable inside collection: 'adminSettings' -> doc: 'topLevelCollections' -> field: 'collectionNames'
      await updateCollectionNamesInAdminSettings(collectionName);
      print("Document successfully written!");
    } catch (e) {
      print("Error adding document to Firestore: $e");
    }
  }
  Future<void> addUserToFirestore(User user, String collectionName) async {
    try {
      await FirebaseFirestore.instance.collection(collectionName).doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName' : user.displayName?.split(' ').first ?? '',
        'surname' : user.displayName?.split(' ').last ?? '',
        'mobile' : user.phoneNumber,
      }, SetOptions(merge: true));
      print("Document successfully written or updated!");
    } catch (e) {
      print("Error adding document to Firestore: $e");
    }
  }
  Future<void> updateCollectionNamesInAdminSettings(String collectionName) async {
    try {
      // Get reference to 'adminSettings' document
      DocumentReference adminSettingsDoc = _firebaseFirestore.collection('adminSettings').doc('topLevelCollections');

      // Fetch the existing collection names array
      DocumentSnapshot adminSettingsSnapshot = await adminSettingsDoc.get();
      List<String> collectionNames = List<String>.from(adminSettingsSnapshot.get('collectionNames'));

      // Add the new collection name if not already exists
      if (!collectionNames.contains(collectionName)) {
        collectionNames.add(collectionName);

        // Update the array field
        await adminSettingsDoc.update({'collectionNames': collectionNames});
      }
    } catch (e) {
      print("Error updating collection names in adminSettings: $e");
    }
  }


  Future<bool> isUserConnected() async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        print('No user is currently logged in.');
        return false;
      } else {
        // User is logged in, now get the access token
        GoogleSignInAccount? googleUser = _googleAuth.currentUser;

        if (googleUser == null) {
          // Try to sign in silently if the user is not already signed in
          googleUser = await _googleAuth.signInSilently();
        }

        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final String? accessToken = googleAuth.accessToken;

          if (accessToken != null) {
            _accessToken = accessToken;
            print('User is connected. Access token: $accessToken');
            return true;
          } else {
            print('Failed to retrieve access token.');
            return false;
          }
        } else {
          print('Google sign-in account is null.');
          return false;
        }
      }
    } catch (e) {
      print('Error checking user connection: $e');
      return false;
    }
  }

  Future<User?> signOut() async {
    await _googleAuth.signOut();
    await _firebaseAuth.signOut();
    currentUser == null;
    return currentUser;
  }


  Future<bool> isUserExist(String email) async {
    try {
      List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  Future<void> deleteUser(String documentId) async {
    try {
      // Delete user from Authentication
      // Delete user document from Firestore
      await FirebaseFirestore.instance.collection('BarberCollection').doc(documentId).delete();
      print('Document $documentId successfully deleted from Firestore');
    } catch (e) {
      print('Error deleting user: $e');
      // Handle error as needed
    }
  }

  Future<int> getUsersAmount(String excludeId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('BarberCollection')
          .where(FieldPath.documentId, isNotEqualTo: excludeId)
          .get();

      int count = querySnapshot.size;
      return count;
    } catch (e) {
      print('Error fetching users amount: $e');
      // Handle error as needed
      return 0;
    }
  }

  Future<List<String>?> getAdminAccountSettings() async {
    List<String> adminSettingsList = [];
    try {
      // Fetch document snapshot
      DocumentSnapshot snapshot = await _firebaseFirestore
          .collection('BarberCollection')
          .doc('admin')
          .get();

      if (snapshot.exists) {
        // Extract fields
        String businessName = snapshot.get('businessName');
        String mobile = snapshot.get('mobile number');
        String igLink = snapshot.get('igLink');

        // Add fields to the list
        adminSettingsList.add(businessName);
        adminSettingsList.add(mobile);
        adminSettingsList.add(igLink);
      }
      print('adminSettingsList Value is: $adminSettingsList');
    } catch (e) {
      print('Error fetching Account Settings For Admin: $e');
    }
    return adminSettingsList;
  }

  Future<void> updateAdminAccountSettings(List<String> newList) async {
    try {
      await _firebaseFirestore.collection('BarberCollection').doc('admin').update({
        'businessName': newList[0],
        'mobile number': newList[1],
        'igLink': newList[2],
      });
      print('Admin account settings updated successfully');
    } catch (e) {
      print('Error updating Account Settings For Admin: $e');
    }
  }




}
