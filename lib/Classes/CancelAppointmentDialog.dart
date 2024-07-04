import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CancelAppointmentDialog extends StatelessWidget {
  final DateTime date;
  final String hour;
  final TextEditingController noteController = TextEditingController();
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  CancelAppointmentDialog({
    required this.date,
    required this.hour,
    required this.onConfirm,
    required this.onCancel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cancel Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you wish to cancel the meeting at $hour on ${DateFormat('yyyy-MM-dd').format(date)}?'),
          SizedBox(height: 20),
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: 'Leave a note...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
