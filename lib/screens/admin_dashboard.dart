
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'residents_screen.dart';
import 'facilities_management_screen.dart';
import 'bookings_management_screen.dart';
import 'complaints_management_screen.dart';
import 'announcements_management_screen.dart';
import 'reminders_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const String apiUrl =
      'http://localhost:3000/api/admin/dashboard';

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic> dashboardData = {
    'residents': 0,
    'facilities': 0,
    'reminders': 0,
    'complaints': 0,
    'announcements': 0,
    'bookings': 0,
    'pendingBookings': 0,
    'pendingComplaints': 0,
  };

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse(apiUrl),
            headers: const {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Server returned status ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map || decoded['dashboard'] is! Map) {
        throw Exception('Invalid dashboard response.');
      }

      final data = Map<String, dynamic>.from(
        decoded['dashboard'] as Map,
      );

      if (!mounted) return;

      setState(() {
        dashboardData = {
          ...dashboardData,
          ...data,
        };
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get dashboardItems => [
        {
          'title': 'Residents',
          'count': dashboardData['residents'],
          'icon': Icons.people_alt_outlined,
          'color': Colors.blue,
        },
        {
          'title': 'Facilities',
          'count': dashboardData['facilities'],
          'icon': Icons.apartment_outlined,
          'color': Colors.green,
        },
        {
          'title': 'Reminders',
          'count': dashboardData['reminders'],
          'icon': Icons.notifications_outlined,
          'color': Colors.orange,
        },
        {
          'title': 'Complaints',
          'count': dashboardData['complaints'],
          'icon': Icons.report_problem_outlined,
          'color': Colors.red,
        },
        {
          'title': 'Announcements',
          'count': dashboardData['announcements'],
          'icon': Icons.campaign_outlined,
          'color': Colors.purple,
        },
        {
          'title': 'Bookings',
          'count': dashboardData['bookings'],
          'icon': Icons.calendar_month_outlined,
          'color': Colors.teal,
        },
      ];

  Future<void> openManagement(String title) async {
    Widget? screen;

    switch (title) {
      case 'Residents':
        screen = const ResidentsScreen();
        break;

      case 'Facilities':
        screen = const FacilitiesManagementScreen();
        break;

      case 'Bookings':
        screen = const BookingsManagementScreen();
        break;

      case 'Complaints':
        screen = const ComplaintsManagementScreen();
        break;

      case 'Announcements':
        screen = const AnnouncementsManagementScreen();
        break;

      case 'Reminders':
        screen = const RemindersManagementScreen();
        break;
    }

    if (screen == null || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => screen!,
      ),
    );

    if (mounted) {
      fetchDashboardData();
    }
  }

  Widget buildDashboardCard(Map<String, dynamic> item) {
    final Color cardColor = item['color'] as Color;

    return Card(
      elevation: 2,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openManagement(item['title'] as String),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: cardColor,
                  size: 26,
                ),
              ),
              const Spacer(),
              Text(
                '${item['count'] ?? 0}',
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172B4D),
                ),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: Text(
                  item['title'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryCard({
    required IconData icon,
    required String title,
    required dynamic count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
          size: 30,
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${count ?? 0}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: fetchDashboardData,
      child: LayoutBuilder(
        builder: (context, pageConstraints) {
          final double horizontalPadding =
              pageConstraints.maxWidth < 400 ? 12 : 20;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(horizontalPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome, Admin!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage your apartment easily.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Responsive dashboard cards.
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;

                        final int columns;
                        if (width >= 700) {
                          columns = 3;
                        } else if (width >= 350) {
                          columns = 2;
                        } else {
                          columns = 1;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 165,
                          ),
                          itemCount: dashboardItems.length,
                          itemBuilder: (context, index) {
                            return buildDashboardCard(
                              dashboardItems[index],
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    buildSummaryCard(
                      icon: Icons.calendar_month,
                      title: 'Pending Bookings',
                      count: dashboardData['pendingBookings'],
                      color: Colors.orange,
                      onTap: () => openManagement('Bookings'),
                    ),

                    const SizedBox(height: 12),

                    buildSummaryCard(
                      icon: Icons.report_problem_outlined,
                      title: 'Pending Complaints',
                      count: dashboardData['pendingComplaints'],
                      color: Colors.red,
                      onTap: () => openManagement('Complaints'),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : fetchDashboardData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 50,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Unable to load dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: fetchDashboardData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : buildDashboardContent(),
    );
  }
}
