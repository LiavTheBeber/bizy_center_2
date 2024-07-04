import 'package:flutter/material.dart';
import '../Classes/PhoneNumberInputField.dart';

class EditSettingsDetailsDialog extends StatelessWidget {
  final String title;
  final String subTitleValue;
  final TextEditingController noteController;
  final ValueChanged<String> onConfirm;
  final VoidCallback onCancel;

  EditSettingsDetailsDialog({
    required this.title,
    required this.subTitleValue,
    required this.onConfirm,
    required this.onCancel,
    Key? key,
  })  : noteController = TextEditingController(text: subTitleValue),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the options within the class
    List<String> options = [];
    if (title == 'זמני קביעות') {
      options = ['שבוע מראש', 'שבועיים מראש', 'שלושה שבועות מראש'];
    }
    if (title == 'מינימום זמן לקביעת תור') {
      options = ['2 שעות', '4 שעות', '6 שעות', '8 שעות', '10 שעות', '12 שעות'];
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(' עריכת $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('בבקשה הזן/י את הערך החדש'),
            SizedBox(height: 20),
            if (title == 'מספר טלפון')
              Directionality(
                textDirection: TextDirection.ltr,
                child: PhoneNumberInputField(
                  fromWhichPage: "מספר טלפון",
                ),
              )
            else if (title == 'זמני קביעות' || title == 'מינימום זמן לקביעת תור')
              DropdownButtonFormField<String>(
                value: options.contains(subTitleValue) ? subTitleValue : options.first,
                items: options
                    .map((option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ))
                    .toList(),
                onChanged: (value) {
                  noteController.text = value!;
                },
                decoration: InputDecoration(
                  hintText: 'הערך החדש...',
                ),
              )
            else
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: 'הערך החדש...',
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: onCancel,
            child: Text('בטל/י'),
          ),
          TextButton(
            onPressed: () {
              onConfirm(noteController.text);
              Navigator.pop(context);
            },
            child: Text('אשר/י'),
          ),
        ],
      ),
    );
  }
}
