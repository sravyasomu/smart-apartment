import 'package:flutter/material.dart';

class Complaint {
  final String category;
  final String description;
  final String date;
  String status;

  Complaint({
    required this.category,
    required this.description,
    required this.date,
    this.status = 'Pending',
  });
}

// Temporary complaint storage.
// Later this will be replaced with MySQL.
class ComplaintStorage {
  static final List<Complaint> complaints = [];
}

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() =>
      _MyComplaintsScreenState();
}

class _MyComplaintsScreenState
    extends State<MyComplaintsScreen> {

  Color statusColor(String status) {
    if (status == 'Resolved') {
      return Colors.green;
    }

    if (status == 'In Progress') {
      return Colors.orange;
    }

    return Colors.red;
  }

  String formatDate(String date) {
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final complaints = ComplaintStorage.complaints;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text(
          'My Complaints',
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

          child: complaints.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: complaints.length,

                  itemBuilder: (context, index) {
                    final complaint = complaints[index];

                    final color =
                        statusColor(complaint.status);

                    return GestureDetector(
                      onTap: () {
                        _showComplaintDetails(
                          context,
                          complaint,
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: 15,
                        ),

                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(18),
                        ),

                        child: Row(
                          children: [
                            // Complaint icon
                            Container(
                              width: 50,
                              height: 50,

                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFE8F1FF),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),

                              child: const Icon(
                                Icons
                                    .report_problem_outlined,
                                color:
                                    Color(0xFF1976D2),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Complaint details
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    complaint.category,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    complaint.description,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              color.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            20,
                                          ),
                                        ),

                                        child: Text(
                                          complaint.status,
                                          style: TextStyle(
                                            color: color,
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      Text(
                                        formatDate(
                                          complaint.date,
                                        ),
                                        style:
                                            const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
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
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FF),
                borderRadius:
                    BorderRadius.circular(25),
              ),

              child: const Icon(
                Icons.inbox_outlined,
                size: 50,
                color: Color(0xFF1976D2),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Complaints Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your submitted complaints will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComplaintDetails(
    BuildContext context,
    Complaint complaint,
  ) {
    final color = statusColor(complaint.status);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            complaint.category,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                complaint.description,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Submitted On',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(complaint.date),

              const SizedBox(height: 18),

              const Text(
                'Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Text(
                  complaint.status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }
}