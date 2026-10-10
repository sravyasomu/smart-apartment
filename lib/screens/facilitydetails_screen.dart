import 'package:flutter/material.dart';

class FacilityDetailsScreen extends StatefulWidget {
  final String facilityName;
  final IconData icon;
  final String timing;

  const FacilityDetailsScreen({
    super.key,
    required this.facilityName,
    required this.icon,
    required this.timing,
  });

  @override
  State<FacilityDetailsScreen> createState() =>
      _FacilityDetailsScreenState();
}

class _FacilityDetailsScreenState
    extends State<FacilityDetailsScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int numberOfPeople = 1;

  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 90),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  void confirmBooking() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a booking date.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a booking time.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Text('Booking Confirmed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                widget.facilityName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Date: ${formatDate(selectedDate!)}',
              ),
              const SizedBox(height: 8),
              Text(
                'Time: ${selectedTime!.format(context)}',
              ),
              const SizedBox(height: 8),
              Text(
                'People: $numberOfPeople',
              ),
              const SizedBox(height: 15),
              const Text(
                'Your facility has been booked successfully.',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('DONE'),
            ),
          ],
        );
      },
    );
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: Text(
          widget.facilityName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // Facility image/icon section
            Container(
              width: double.infinity,
              height: 220,

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF64B5F6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.circular(25),
              ),

              child: Icon(
                widget.icon,
                size: 100,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 25),

            // Facility name
            Text(
              widget.facilityName,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Opening hours
            _sectionCard(
              title: 'Opening Hours',
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE8F1FF),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Time',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        widget.timing,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // About
            _sectionCard(
              title: 'About this Facility',
              child: const Text(
                'This facility is available for apartment '
                'residents. Residents can use the facility '
                'according to the apartment rules and timings.',
                style: TextStyle(
                  color: Colors.grey,
                  height: 1.5,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Rules
            _sectionCard(
              title: 'Rules',
              child: Column(
                children: [
                  rule('Maintain cleanliness'),
                  rule('Follow facility timings'),
                  rule('Respect other residents'),
                  rule(
                    'Report any damage to management',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Booking section
            _sectionCard(
              title: 'Book this Facility',
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // Date
                  const Text(
                    'Select Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: selectDate,
                      icon: const Icon(
                        Icons.calendar_month,
                      ),
                      label: Text(
                        selectedDate == null
                            ? 'Choose Date'
                            : formatDate(
                                selectedDate!,
                              ),
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF1976D2),
                        side: const BorderSide(
                          color: Color(0xFF1976D2),
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Time
                  const Text(
                    'Select Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: selectTime,
                      icon: const Icon(
                        Icons.access_time,
                      ),
                      label: Text(
                        selectedTime == null
                            ? 'Choose Time'
                            : selectedTime!
                                .format(context),
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF1976D2),
                        side: const BorderSide(
                          color: Color(0xFF1976D2),
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Number of people
                  const Text(
                    'Number of People',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [

                        IconButton(
                          onPressed:
                              numberOfPeople > 1
                                  ? () {
                                      setState(() {
                                        numberOfPeople--;
                                      });
                                    }
                                  : null,
                          icon: const Icon(
                            Icons.remove_circle_outline,
                          ),
                        ),

                        Text(
                          '$numberOfPeople',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed:
                              numberOfPeople < 20
                                  ? () {
                                      setState(() {
                                        numberOfPeople++;
                                      });
                                    }
                                  : null,
                          icon: const Icon(
                            Icons.add_circle_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Confirm booking button
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: confirmBooking,

                icon: const Icon(
                  Icons.check_circle_outline,
                ),

                label: const Text(
                  'CONFIRM BOOKING',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF1976D2),
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Section card
  static Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }

  // Rule item
  static Widget rule(String text) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: Colors.green,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}