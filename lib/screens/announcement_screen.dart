import 'package:flutter/material.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),

      appBar: AppBar(
        title: const Text(
          'Announcements',
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
            maxWidth: 850,
          ),

          child: ListView(
            padding: const EdgeInsets.all(20),

            children: [
              announcementCard(
                icon: Icons.groups_outlined,
                title: 'Monthly Residents Meeting',
                description:
                    'The monthly apartment residents meeting will be held in the community hall. All residents are requested to attend the meeting.',
                date: '8 October 2026',
              ),

              announcementCard(
                icon: Icons.cleaning_services_outlined,
                title: 'Apartment Cleaning',
                description:
                    'Common areas of the apartment will be cleaned this weekend. Residents are requested to cooperate with the cleaning staff.',
                date: '10 October 2026',
              ),

              announcementCard(
                icon: Icons.water_drop_outlined,
                title: 'Water Tank Cleaning',
                description:
                    'The overhead water tanks will be cleaned. Water supply may be temporarily interrupted during the cleaning process.',
                date: '15 October 2026',
              ),

              announcementCard(
                icon: Icons.security_outlined,
                title: 'Security Reminder',
                description:
                    'Residents are requested to ensure that the main apartment gates are properly closed after entering or leaving the premises.',
                date: '18 October 2026',
              ),

              announcementCard(
                icon: Icons.local_parking_outlined,
                title: 'Parking Update',
                description:
                    'Residents are requested to park their vehicles only in their allotted parking spaces.',
                date: '20 October 2026',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget announcementCard({
    required IconData icon,
    required String title,
    required String description,
    required String date,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF1976D2),
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}