import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Classes/CancelAppointmentDialog.dart';
import '../Classes/NotificationService.dart';
import '../Repositorys/GoogleCalendarRepository.dart';

DateTime currentDate = DateTime.now();
DateTime lastDay = currentDate.add(Duration(days: 14));

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _isDropdownDisabled = false;
  bool _isLoading = false; // add a loading state

  Map<DateTime, String> _appointments = {};
  List<String> _availableHours = [];
  String? _selectedHour;

  late NotificationService _notificationService;

  GoogleCalendarRepository? _calendarRepository;

  String? dropDownHint = '';

  @override
  void initState() {
    super.initState();
    _calendarRepository = GoogleCalendarRepository();
    _notificationService = NotificationService();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final appointments = await _calendarRepository?.getAppointmentsField();
      setState(() {
        _appointments = appointments!;
      });
      final availableHours = await _calendarRepository?.getAllAvailableHours(_selectedDay);
      setState(() {
        _availableHours = availableHours!;
      });
      setDropDownHintAccordingly(availableHours);
    } catch (e) {
      print('Failed to fetch appointments : $e');
    }
  }

  void _appointmentSetNotification(DateTime date, String hour) {
    _notificationService.showNotification(
      'Appointment Reminder',
      'You have an appointment scheduled at $hour on ${DateFormat('yyyy-MM-dd').format(date)}',
    );
  }

  void _appointmentCanceledNotification(DateTime date, String hour) {
    _notificationService.showNotification(
      'Appointment Reminder',
      'Your appointment scheduled at $hour on ${DateFormat('yyyy-MM-dd').format(date)} is canceled',
    );
  }

  Future<void> _onConfirmAppointment() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    addAppointmentFormat(); // Disable dropdown and add appointment at date
    await _calendarRepository?.confirmAppointment('able to work', _selectedDay, _selectedHour!,_appointments, 'Appointment Set with barber', '2');
    _appointmentSetNotification(_selectedDay, _selectedHour!); // show notification

    setState(() {
      dropDownHint = _selectedHour;
      _isLoading = false; // Stop loading
    });
  }

  Future<void> _onCancelAppointment(DateTime date, String hour) async {
    setState(() {
      _isLoading = true; // Start loading
    });
    await _calendarRepository?.cancelAppointment('appointment set with barber', date, hour, '7');
    removeAppointmentFormat(date); // update ui
    _appointmentCanceledNotification(date, hour); // show notification

    setState(() {
      _isLoading = false; // Start loading
    });
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      // Set calendar format
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      dropDownHint = '';
      _selectedHour = null;
    });
    if(_appointments.containsKey(selectedDay)){
      setState(() {
        _isDropdownDisabled = true;
      });
    }
    final availableHours = await _calendarRepository?.getAllAvailableHours(selectedDay);
    setDropDownHintAccordingly(availableHours);

  }

  void setDropDownHintAccordingly(List<String>? availableHours){
    // Check if there is an appointment for the selected day
    bool hasAppointment = _appointments.containsKey(_selectedDay);

    // Check if there are available hours
    bool hasAvailable = availableHours != null && availableHours.isNotEmpty;

    // Update state based on conditions
    if (hasAppointment) {
      setState(() {
        _isDropdownDisabled = true;
        dropDownHint = _appointments[_selectedDay] ?? '';
      });
    } else {
      setState(() {
        _isDropdownDisabled = false;
      });

      if (hasAvailable) {
        setState(() {
          dropDownHint = 'בחר שעה';
          _availableHours = availableHours;
        });
      } else {
        setState(() {
          dropDownHint = 'אין שעות פנויות היום';
          _availableHours = [];
        });
      }
    }
  }

  void addAppointmentFormat() {
    setState(() {
      _isDropdownDisabled = true;
      _appointments[_selectedDay] = _selectedHour!;
    });
  }

  void removeAppointmentFormat(DateTime date) {
    setState(() {
      _isDropdownDisabled = false;
      _appointments.remove(date);
    });
  }

  bool _isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.monday;
  }

  void _showCancelAppointmentDialog(DateTime date, String hour) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CancelAppointmentDialog(
          date: date,
          hour: hour,
          onConfirm: () {
            _onCancelAppointment(date, hour);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text(
          'התאמת פגישה',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            firstDay: currentDate,
            lastDay: lastDay,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) {
              // Handle page change if necessary
            },
            calendarStyle: CalendarStyle(
              todayTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              defaultTextStyle: TextStyle(fontSize: 18.0), // Increase font size for day numbers
              outsideTextStyle: TextStyle(color: Colors.grey), // Style for days outside the current month
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                final isAppointmentSet = _appointments.containsKey(date);
                final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.monday;
                return Container(
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isAppointmentSet
                            ? Colors.green
                            : isWeekend
                            ? Colors.red // Red for weekends
                            : Colors.black, // Default color
                        fontSize: isAppointmentSet || isWeekend ? 18.0 : 16.0, // Adjust fontSize
                      ),
                    ),
                  ),
                );
              },
            ),
            availableCalendarFormats: {
              CalendarFormat.month: 'Month',
              CalendarFormat.week: 'Week',
            },
          ),
          if (!_isWeekend(_selectedDay)) ...[
            SizedBox(height: 16.0),
            Text(
              '${DateFormat('dd-MM-yyyy').format(_selectedDay)} :שעות פנויות בתאריך',
              style: TextStyle(fontSize: 18.0), // Increase font size
            ),
            SizedBox(height: 16.0),
            Container(
              width: screenWidth * 0.8, // 80% of screen width
              height: MediaQuery.of(context).size.height * 0.07, // 15% of screen height
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  '$dropDownHint',
                  style: TextStyle(fontSize: 18.0), // Increase font size
                ),
                value: _selectedHour,
                onChanged: _isDropdownDisabled
                    ? null
                    : (newValue) {
                  setState(() {
                    _selectedHour = newValue;
                  });
                },
                items: _availableHours.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 18.0), // Increase font size
                    ),
                  );
                }).toList() ?? [],
              ),
            ),
            SizedBox(height: 16.0),
            if (!(_appointments.containsKey(_selectedDay) && !_isLoading)) ...[
              MaterialButton(
                onPressed: _selectedHour != null && !_isDropdownDisabled
                    ? () async {
                  await _onConfirmAppointment();
                }
                    : null,
                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text(
                  'אשר/י פגישה',
                  style: TextStyle(fontSize: 18.0), // Increase font size
                ),
              ),
            ],
            if (_appointments.containsKey(_selectedDay) && !_isLoading) ...[
              MaterialButton(
                onPressed: () {
                  _selectedHour = dropDownHint;
                  _showCancelAppointmentDialog(_selectedDay, _selectedHour!);
                },
                color: Colors.red,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text(
                  'מחק/י פגישה',
                  style: TextStyle(fontSize: 18.0), // Increase font size
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
