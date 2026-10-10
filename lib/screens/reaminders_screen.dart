import 'package:flutter/material.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  final List<Map<String, dynamic>> reminders = const [
    {
      'title': 'Maintenance Payment',
      'date': 'Due on 10 October',
      'icon': Icons.payment,
    },
    {
      'title': 'Water Tank Cleaning',
      'date': 'Scheduled on 15 October',
      'icon': Icons.water_drop_outlined,
    },
    {
      'title': 'Apartment Meeting',
      'date': 'Scheduled on 20 October',
      'icon': Icons.groups_outlined,
    },
    {
      'title': 'Lift Maintenance',
      'date': 'Scheduled on 25 October',
      'icon': Icons.elevator_outlined,
    },
    {
      'title': 'Society Fee',
      'date': 'Due on 30 October',
      'icon': Icons.receipt_long_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ),

          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reminders.length,

            itemBuilder: (context, index) {
              final reminder = reminders[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),

                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),

                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${reminder['title']} selected',
                          ),
                        ),
                      );
                    },

                    child: Padding(
                      padding: const EdgeInsets.all(18),

                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,

                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F1FF),
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),

                            child: Icon(
                              reminder['icon'],
                              color: const Color(0xFF1976D2),
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Text(
                                  reminder['title'],

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  reminder['date'],

                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}