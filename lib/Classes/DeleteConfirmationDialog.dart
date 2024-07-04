import 'package:flutter/material.dart';

import 'ContactList.dart';

class DeleteConfirmationDialog {
  static Future<bool?> show(BuildContext context, Contact contact) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Are you sure you want to delete this contact?"),
              SizedBox(height: 10),
              Text("Name: ${contact.displayName} ${contact.surname}"),
              Text("Email: ${contact.email}"),
              Text("Mobile Phone: ${contact.mobilePhone}"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false to indicate cancel
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true to indicate delete
              },
            ),
          ],
        );
      },
    );
  }
}
