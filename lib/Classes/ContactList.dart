import 'package:bizy_center2/ViewModels/Auth_View_Model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DeleteConfirmationDialog.dart';

class Contact {
  final String uid;
  final String displayName;
  final String surname;
  final String email;
  final String mobilePhone;

  Contact({
    required this.uid,
    required this.displayName,
    required this.surname,
    required this.email,
    required this.mobilePhone,
  });
}

class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  late List<Contact> contacts;
  bool _isInitialized = false;
  AuthViewModel? _authViewModel;


  @override
  void initState() {
    super.initState();
    initializeContacts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    });

  }

  void initializeContacts() async {
    try {
      List<Contact> fetchedContacts =
      await fetchContactsFromFirestore(excludeId: 'admin'); // Replace '' with any ID to exclude if needed
      setState(() {
        contacts = fetchedContacts;
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing contacts: $e');
      // Handle error as needed
    }
  }

  void deleteContact(String uid) {
    setState(() {
      contacts.removeWhere((contact) => contact.uid == uid);
    });
    _authViewModel?.updateContactList(contacts);
  }

  Future<List<Contact>> getContacts() async {
    return contacts;
  }

  Future<List<Contact>> fetchContactsFromFirestore({required String excludeId}) async {
    List<Contact> contacts = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('BarberCollection')
          .where(FieldPath.documentId, isNotEqualTo: excludeId)
          .get();

      for (var doc in querySnapshot.docs) {
        // Use null-aware operators (??) to provide default values if fields are null
        String uid = doc['uid'] ?? '';
        String displayName = doc['displayName'] ?? '';
        String surname = doc['surname'] ?? '';
        String email = doc['email'] ?? '';
        String mobilePhone = doc['mobile'] ?? '';

        Contact contact = Contact(
          uid: uid,
          displayName: displayName,
          surname: surname,
          email: email,
          mobilePhone: mobilePhone,
        );

        contacts.add(contact);
      }

      _authViewModel?.updateContactList(contacts);

    } catch (e) {
      print('Error fetching contacts: $e');
      // Handle error as needed
    }

    return contacts;
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return ContactListItem(
          contact: contacts[index],
          onDelete: deleteContact,
        );
      },
    )
        : Center(
      child: CircularProgressIndicator(), // Show a loading spinner while contacts are being fetched
    );
  }
}

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final void Function(String) onDelete;

  ContactListItem({required this.contact, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0),
        title: Text('${contact.displayName} ${contact.surname}', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(contact.email),
            SizedBox(height: 5),
            Text(contact.mobilePhone),
          ],
        ),
        trailing: GestureDetector(
          onTap: () async {
            bool? deleteConfirmed = await DeleteConfirmationDialog.show(context, contact);
            if (deleteConfirmed == true) {
              // Handle delete logic here, such as calling a delete function
              // For demonstration, let's print a message
              AuthViewModel? _authViewModel;
              _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
              _authViewModel.deleteUser(contact.uid);
              onDelete(contact.uid);
              print("Deleting contact: ${contact.displayName} ${contact.surname}");
            }
          },
          child: Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }
}
