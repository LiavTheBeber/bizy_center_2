import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;


class GoogleCalendarRepository {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      calendar.CalendarApi.calendarScope,
    ],
  );
  static const _calendarId = "liavbohadana5@gmail.com";
  String? _usersCalenderId;

  late calendar.CalendarApi _calendarApi;
  late auth.AuthClient _client;
  // Replace with your actual client ID and secret
  static const String  _clientId = '62222524195-i8n3jal0pmfp24f13dst9djigoihcm19.apps.googleusercontent.com';
  static const String _clientSecret = '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';

  // Authenticate client
  Future<AutoRefreshingAuthClient> _getClient() async {
    print('Attempting to authenticate client...');
    try {
      // Load Google credentials
      final credentials = ServiceAccountCredentials.fromJson({
        "private_key_id": "c6a3cbc75c273939f8fdf65005034c5799173ca6",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDma//6ZgVenk82\nHHmNdC5jzTWuO0NUcD9jzEEVsIHKcJRk8nZE6Ff5Iyn9ym1pEsKCLzbxemL8+d54\n4XF+hScUlTBje37uM/+3Mc5ie+5RZVQ/4FUfAvFpAu/27GG51LxMS1STvILQc2Dm\nTw0zSu8wYKQTh4kmF+NkJknH1Vu/jxRyhPQnkgl/FhnOQZV0CWZ4Jxclzx8A10Tn\nj/l3oqfr4tuuQV0EzbEiblRuVRigKN4R1GP56yFkI01z7qB9tcjGUWkfCGoCehTn\nM25n/cPyYe9LYssOnD9ZLp7p9EBSgh8StWZmaoudIUS2AS4EEFYnFt8cHm1c4zbO\nsAvUWz9JAgMBAAECggEAAUmmuVFDI+t6EVkY4827qaKes23Q20KyU/4y+epN22IE\nLkk9mHZ88V89L5YnROBONniJk9FlhrjlwaKu5fBcDs0jo1awF6gyPGWam+nJ4+oP\nTbkU+LKlQzs5OJXLGQUDlWCRZS73Qy914eucrQX07r4HhLVr8orNIkTlgiii1d/1\n3Ar0Znka+Gkyaw7aKdVTRC11BH4QI/05jgZdv/LYmxFEanuwSaOTCGIp2KH71ayx\nvtmN0IWBUcEeUUUaWe+Nnl7+x5uHwXkGaewBhquaSzt16qw4g9OuspEQ6upM2CRt\npUUmS34ff7J+2UBt9Q9ozDd0qQs+2Riz1vVieky6oQKBgQD1/m3l1TDuvmGnIikJ\nDn4PTKRn0SyDjtinqn3PVaJ0BSoCPoYQiwEOJteOL6PRY4Uq8PCFeVaBwR7LeZzH\nhLYjq9VWCTg3HptmzbiXHGUem6p/YSEYw64KQRAFk8kbZXG1kQU89g7egjPqha2M\n0d4qzxom6Srx7k4HKzTAEKencQKBgQDvy2rMUa0oXxStNUF1YCKZZV6NHbWPs3Fj\n7Dg91WVXb0kzFHExVhLDg8CNa7h3LkpJYKMZVpfhVXmJOGjUOj6wg8aVuM64ve3J\nkki50KlFhQVE1bcrAeyeHbOqpjlKtgECGBx1LanK7/GwVuzorG9t1Ua45fRub8VJ\nCeZIqjgZWQKBgQDHOKsgO6xJbf4AMXYyU35cPaHYQlteoE1uXHFPfPb4J0aCUsiY\nlTrhjyt7h7GQXpz2zfK85ivdId4iw/bozt4DvaIk74qLeUo509nu55wtUbyfNLZt\nK+zDeTXUjn+MpHeWqEApwsz//0q0YFbReRYIbXmskaGqFWkz/RXXhqWAwQKBgEVj\nQ2AkMksAWGdWhb6FNv3US2viMOuILUOQ0yVxXoXSeggB3k88bOmOcmV5ykMSbgSV\nphxq5kAaD7UZUZw3znQdbZVdiNQEgY5WehzquFCZkVC91ubnA6UtSxQSTXnE+L22\nZGWz9PH4RKOWQ6+AVi4eDPzr7bMXPKtJ5g0Y1GrhAoGAaBtIqm7qkA3SatkiJ23q\nPfr2hvbHSlRPV62fpypBPEQvKjN31vlqsXNOnZrVZinXAJKNZYpyB/5F0/W63Acu\n0A9bUBBXIAwNXOVGkKfTauruZboYwqXw/hXjp2pDkE+cKXXvd0KuSpMayHXfSnik\n+h8YlRwqKsV36hI3OMBMn04=\n-----END PRIVATE KEY-----\n",
        "client_email": "bizycenter@bizycenter2.iam.gserviceaccount.com",
        "client_id": "112900047300978143335",
        "type": "service_account",
      });

      // Authenticate using service account credentials
      final client = await clientViaServiceAccount(credentials, [calendar.CalendarApi.calendarReadonlyScope, calendar.CalendarApi.calendarScope]);
      print('Client authenticated successfully');
      return client;
    } catch (e) {
      print('Error authenticating client: $e');
      rethrow;
    }
  }

  Future<auth.AuthClient> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    String? usersEmail = prefs.getString('usersEmail');
    DateTime? expiryDate = DateTime.tryParse(prefs.getString('expiryDate') ?? '')?.toUtc();

    if (accessToken != null && expiryDate != null && DateTime.now().isBefore(expiryDate)) {
      // Use stored access token
      final auth.AccessCredentials credentials = auth.AccessCredentials(
        auth.AccessToken('Bearer', accessToken, expiryDate),
        null,
        [calendar.CalendarApi.calendarScope],
      );

      _client = auth.authenticatedClient(http.Client(), credentials);
      _calendarApi = calendar.CalendarApi(_client);
      _usersCalenderId = usersEmail ?? "primary";
      print('reached here 1,usersEmail is: $_usersCalenderId or from pref: ${prefs.getString('usersEmail')}');
    } else {
      // Authenticate via Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        throw Exception('User canceled sign-in');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final auth.AccessCredentials credentials = auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          googleAuth.accessToken!,
          DateTime.now().add(Duration(seconds: 3600)).toUtc(), // Assuming access token is valid for 1 hour
        ),
        null,
        [calendar.CalendarApi.calendarScope],
      );

      // Save tokens
      prefs.setString('accessToken', googleAuth.accessToken!);
      prefs.setString('expiryDate', DateTime.now().add(Duration(seconds: 3600)).toIso8601String());

      // Save user's email
      prefs.setString('usersEmail', googleUser.email);

      _client = auth.authenticatedClient(http.Client(), credentials);
      _calendarApi = calendar.CalendarApi(_client);
      _usersCalenderId = googleUser.email;
      print('reached here 2,usersEmail is: $_usersCalenderId or from pref: ${prefs.getString('usersEmail')}');
    }

    return _client;
  }

  // Get user's display Name
  Future<String> getUserDisplayName() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('BarberCollection')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String displayName = userDoc.get('displayName');
        String surname = userDoc.get('surname');
        return '$displayName $surname';
      } else {
        print('User document does not exist.');
        return 'No display name found';
      }
    } catch (e) {
      print('Error getting user display name: $e');
      return 'Error retrieving display name';
    }
  }

  // Add appointment field to firebase
  Future<void> addAppointmentsField(Map<DateTime, String> appointments) async {
    String userid = _firebaseAuth.currentUser!.uid;

    // Convert Map<DateTime, String> to Map<String, String>
    Map<String, String> formattedAppointments = appointments.map((key, value) {
      String formattedDate = key.toIso8601String(); // Convert DateTime to ISO 8601 string
      return MapEntry(formattedDate, value);
    });

    // Reference to the user document
    DocumentReference userDocRef = _firebaseFirestore.collection('BarberCollection').doc(userid);

    try {
      // Set the 'appointments' field with the formatted map
      await userDocRef.set({'appointments': formattedAppointments}, SetOptions(merge: true));
      print('Appointments field added successfully.');
    } catch (e) {
      print('Error adding appointments field: $e');
    }
  }

  // Get appointment field from firebase
  Future<Map<DateTime, String>?> getAppointmentsField() async {
    String userid = _firebaseAuth.currentUser!.uid;

    // Reference to the user document
    DocumentReference userDocRef = _firebaseFirestore.collection('BarberCollection').doc(userid);

    try {
      // Get the document snapshot
      DocumentSnapshot docSnapshot = await userDocRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('appointments')) {
          Map<String, String> formattedAppointments = Map<String, String>.from(data['appointments']);

          // Convert Map<String, String> to Map<DateTime, String>
          Map<DateTime, String> appointments = formattedAppointments.map((key, value) {
            DateTime parsedDate = DateTime.parse(key); // Convert ISO 8601 string to DateTime
            return MapEntry(parsedDate, value);
          });

          print('Appointments field retrieved successfully.');
          return appointments;
        } else {
          print('No appointments field found.');
          return null;
        }
      } else {
        print('User document does not exist.');
        return null;
      }
    } catch (e) {
      print('Error retrieving appointments field: $e');
      return null;
    }
  }

  // Remove an appointment by date
  Future<void> removeAppointmentByDate(DateTime dateToRemove) async {
    String userid = _firebaseAuth.currentUser!.uid;

    // Reference to the user document
    DocumentReference userDocRef = _firebaseFirestore.collection('BarberCollection').doc(userid);

    try {
      // Fetch the current appointments
      Map<DateTime, String>? appointments = await getAppointmentsField();

      if (appointments != null && appointments.containsKey(dateToRemove)) {
        // Remove the appointment for the specified date
        appointments.remove(dateToRemove);

        // Convert Map<DateTime, String> back to Map<String, String>
        Map<String, String> updatedAppointments = appointments.map((key, value) {
          return MapEntry(key.toIso8601String(), value); // Convert DateTime to ISO 8601 string
        });

        // Update the user document with the new appointments map
        await userDocRef.update({'appointments': updatedAppointments});
        print('Appointment removed successfully.');
      } else {
        print('Appointment not found for the specified date.');
      }
    } catch (e) {
      print('Error removing appointment: $e');
    }
  }


  // Get all available hours from the appointment schedule event of the selected date
  Future<List<String>> getAllAvailableHours(DateTime selectedDate) async {
    print('Fetching available hours for date: $selectedDate');
    try {
      // Authenticate client
      final client = await _getClient();

      // Initialize Calendar API
      final calendarApi = calendar.CalendarApi(client);

      print('calendarApi : $calendarApi');

      // Define start and end time for the selected day
      DateTime startTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
      DateTime endTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

      print('Start Time Is: $startTime');
      print('endTime Is: $endTime');

      // Fetch events from Google Calendar
      final events = await calendarApi.events.list(
        _calendarId,
        timeMin: startTime.toUtc(),
        timeMax: endTime.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      // Filter events by title "able to work"
      String eventName = "able to work".toLowerCase();
      List<calendar.Event> filteredEvents = events.items?.where((event) => event.summary?.toLowerCase() == eventName).toList() ?? [];

      // Collect available hours from the filtered events
      List<String>? availableHours = [];
      for (var event in filteredEvents) {
        if (event.start?.dateTime != null && event.end?.dateTime != null) {
          DateTime start = event.start!.dateTime!.toLocal();
          availableHours.add('${start.hour}:${start.minute.toString().padLeft(2, '0')}');
        }
      }

      print('Available hours: $availableHours');
      return availableHours;
    } catch (e) {
      print('Error fetching available hours: $e');
      rethrow;
    }
  }

  // Fetch event ID by summary, date, and hour
  Future<String?> getEventIdBySummaryAndDateAndHour(String summary, DateTime date, String hour) async {
    print('Fetching event ID for summary: $summary, date: $date, hour: $hour');

    try {
      // Authenticate client
      final client = await _getClient();

      // Initialize Calendar API
      final calendarApi = calendar.CalendarApi(client);

      // Define start and end time for the selected day
      DateTime startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endTime = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Fetch events from Google Calendar
      final events = await calendarApi.events.list(
        _calendarId,
        timeMin: startTime.toUtc(),
        timeMax: endTime.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );
      print('Business Events fetched: ${events.items?.length ?? 0}');

      // Convert hour to a DateTime object
      final hourParts = hour.split(':');
      final int eventHour = int.parse(hourParts[0]);
      final int eventMinute = int.parse(hourParts[1]);

      // Find the event with the specified summary and hour
      for (var event in events.items ?? []) {
        final eventStart = event.start?.dateTime?.toLocal();
        if (event.summary?.toLowerCase() == summary.toLowerCase() &&
            eventStart != null &&
            eventStart.hour == eventHour &&
            eventStart.minute == eventMinute) {
          print('Event found: ${event.id}');
          return event.id;
        }
      }

      return null; // Event not found
    } catch (e) {
      print('Error fetching Business event ID: $e');
      rethrow;
    }
  }

  Future<String?> getEventIdBySummaryAndDateAndHourForUser(String summary, DateTime date, String hour) async {
    print('Fetching event ID for summary: $summary, date: $date, hour: $hour');

    try {
      // Authenticate client
      print('Authenticating client...');
      final client = await initialize();
      print('Client authenticated.');

      // Initialize Calendar API
      print('Initializing Calendar API...');
      final calendarApi = calendar.CalendarApi(client);

      // Define start and end time for the selected day
      DateTime startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endTime = DateTime(date.year, date.month, date.day, 23, 59, 59);
      print('Start time: $startTime, End time: $endTime');

      // Fetch events from Google Calendar
      print('Fetching events from Google Calendar...');
      final events = await calendarApi.events.list(
        _usersCalenderId!,
        timeMin: startTime.toUtc(),
        timeMax: endTime.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );
      print('Normal Events fetched: ${events.items?.length ?? 0}');

      // Convert hour to a DateTime object
      final hourParts = hour.split(':');
      final int eventHour = int.parse(hourParts[0]);
      final int eventMinute = int.parse(hourParts[1]);
      print('Event hour: $eventHour, Event minute: $eventMinute');

      // Find the event with the specified summary and hour
      for (var event in events.items ?? []) {
        final eventStart = event.start?.dateTime?.toLocal();
        print('Checking event: ${event.summary}, start: $eventStart');
        if (event.summary?.toLowerCase() == summary.toLowerCase() &&
            eventStart != null &&
            eventStart.hour == eventHour &&
            eventStart.minute == eventMinute) {
          print('Event found: ${event.id}');
          return event.id;
        }
      }

      print('Event not found.');
      return null; // Event not found
    } catch (e) {
      print('Error fetching event ID: $e');
      rethrow;
    }
  }

  // Modify an existing event's name and color
  Future<void> modifyEvent(String eventId,String eventName,String newColor) async {
    try {
      // Authenticate client
      final client = await _getClient();

      // Initialize Calendar API
      final calendarApi = calendar.CalendarApi(client);

      // Fetch the event to modify
      calendar.Event event = await calendarApi.events.get(_calendarId, eventId);

      // Modify event details
      event.summary = eventName;
      event.colorId = newColor;

      // Add a notification 30 minutes before the event
      event.reminders = calendar.EventReminders(
        useDefault: false,
        overrides: [
          calendar.EventReminder(
            method: 'popup',
            minutes: 30,
          ),
        ],
      );
      print('Added 30-minute reminder to event');

      // Update the event in the calendar
      await calendarApi.events.update(event, _calendarId, eventId);

      print('Event modified successfully');
    } catch (e) {
      print('Error modifying event: $e');
      rethrow;
    }
  }

  // Create a new event with specified details for a specific calendar
  Future<void> createEvent(String summary, DateTime date, String hour, String colorId) async {
    try {
      final client = await initialize();
      print('Creating event for calendar $_usersCalenderId with summary: $summary, date: $date, hour: $hour, color ID: $colorId');

      // Initialize Calendar API
      final calendarApi = calendar.CalendarApi(client);

      // Convert hour to a DateTime object
      final hourParts = hour.split(':');
      final int eventHour = int.parse(hourParts[0]);
      final int eventMinute = int.parse(hourParts[1]);
      final eventStart = DateTime(date.year, date.month, date.day, eventHour, eventMinute);
      final eventEnd = eventStart.add(Duration(hours: 1)); // Assuming 1-hour duration

      // Create event object
      final event = calendar.Event(
        summary: summary,
        start: calendar.EventDateTime(
          dateTime: eventStart.toUtc(),
          timeZone: 'UTC',
        ),
        end: calendar.EventDateTime(
          dateTime: eventEnd.toUtc(),
          timeZone: 'UTC',
        ),
        colorId: colorId,
        reminders: calendar.EventReminders(
          useDefault: false,
          overrides: [
            calendar.EventReminder(
              method: 'popup',
              minutes: 30,
            ),
          ],
        ),
      );

      // Insert the event into the specified calendar
      await calendarApi.events.insert(event, _usersCalenderId!);

      print('E-Event created successfully for calendar $_usersCalenderId');
    } catch (e) {
      print('E-Error creating event for calendar $_usersCalenderId: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      print('Deleting event with ID: $eventId from calendar $_usersCalenderId');

      final client = await initialize();

      // Initialize Calendar API
      final calendarApi = calendar.CalendarApi(client);

      // Delete the event from the specified calendar
      await calendarApi.events.delete(_usersCalenderId!, eventId);

      print('Event with ID: $eventId deleted successfully from calendar $_usersCalenderId');
    } catch (e) {
      print('Error deleting event with ID: $eventId from calendar $_usersCalenderId: $e');
      rethrow;
    }
  }

  Future<void> cancelAppointment(String summary, DateTime date, String hour, String newColor) async {

    String usersName = await getUserDisplayName();
    String appointmentName = 'Appointment with $usersName';

    String eventName = 'able to work';

    // Get the eventId from normal User
    String? eventId = await getEventIdBySummaryAndDateAndHourForUser(summary, date, hour);

    // Get the business eventId
    String? eventIdBusiness = await getEventIdBySummaryAndDateAndHour(appointmentName, date, hour);

    // Modify BusinessAccount event
    await modifyEvent(eventIdBusiness!,eventName, newColor);

    // Remove appointment from firebase
    removeAppointmentByDate(date);

    // Delete User's Event
    await deleteEvent(eventId!);
  }

  Future<void> confirmAppointment(String summary, DateTime date, String hour,Map<DateTime, String> appointments,String newSummary, String newColor) async {
    String usersName = await getUserDisplayName();
    String eventName = 'Appointment with $usersName';

    // Get the eventId
    String? eventId = await getEventIdBySummaryAndDateAndHour(summary, date, hour);
    // Add event to Firebase
    addAppointmentsField(appointments);
    // Modify Existing Event in primary Calendar
    await modifyEvent(eventId!, eventName, newColor);
    // Create event for secondary Calendar
    await createEvent(newSummary,date,hour,newColor);
  }


}
