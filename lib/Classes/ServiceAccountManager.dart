import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class ServiceAccountManager {
  static final ServiceAccountManager _instance = ServiceAccountManager._internal();
  late String _accessToken;

  ServiceAccountManager._internal();

  factory ServiceAccountManager() {
    return _instance;
  }

  Future<void> initialize() async {
    print('Started initialization...');
    try {
      final jsonString = await rootBundle.loadString('assets/bizycenter2-c6a3cbc75c27.json');
      final accountCredentials = ServiceAccountCredentials.fromJson(
        json.decode(jsonString),
      );

      final scopes = [
        CalendarApi.calendarScope,
        CalendarApi.calendarEventsScope,
      ];

      final client = await clientViaServiceAccount(accountCredentials, scopes);

      _accessToken = client.credentials.accessToken.data;
      print('Access token obtained: $_accessToken');

      client.close();
    } catch (error) {
      print('Error initializing ServiceAccountManager: $error');
    }
  }

  String get accessToken => _accessToken;
}
