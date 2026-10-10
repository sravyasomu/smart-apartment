import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnnouncementsManagementScreen extends StatefulWidget {
  const AnnouncementsManagementScreen({super.key});

  @override
  State<AnnouncementsManagementScreen> createState() =>
      _AnnouncementsManagementScreenState();
}

class _AnnouncementsManagementScreenState
    extends State<AnnouncementsManagementScreen> {
  static const String baseUrl = 'http://localhost:3000/api';

  List<Map<String, dynamic>> announcements = [];

  bool isLoading = true;
  bool isPublishing = false;

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  // ==========================================
  // FETCH ANNOUNCEMENTS
  // ==========================================

  Future<void> fetchAnnouncements() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/announcements'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> items = data['announcements'] ?? [];

        if (!mounted) return;

        setState(() {
          announcements = items
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load announcements');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load announcements.'),
        ),
      );
    }
  }

  // ==========================================
  // PUBLISH ANNOUNCEMENT
  // ==========================================

  Future<void> publishAnnouncement({
    required String title,
    required String description,
  }) async {
    setState(() {
      isPublishing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/announcements'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'date': DateTime.now().toIso8601String().substring(0, 10),
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement published successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await fetchAnnouncements();
      } else {
        final data = jsonDecode(response.body);

        throw Exception(
          data['message'] ?? 'Unable to publish announcement.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to publish announcement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPublishing = false;
        });
      }
    }
  }

  // ==========================================
  // SHOW ADD ANNOUNCEMENT DIALOG
  // ==========================================

  void showAddAnnouncementDialog() {
    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: !isPublishing,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Publish Announcement'),
              content: SizedBox(
                width: 450,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Announcement Title',
                            hintText: 'Enter announcement title',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.campaign),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter announcement details',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a description';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isPublishing
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: isPublishing
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {});

                          await publishAnnouncement(
                            title: titleController.text.trim(),
                            description:
                                descriptionController.text.trim(),
                          );
                        },
                  icon: const Icon(Icons.publish),
                  label: const Text('Publish'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      titleController.dispose();
      descriptionController.dispose();
    });
  }

  // ==========================================
  // DELETE ANNOUNCEMENT
  // ==========================================

  Future<void> deleteAnnouncement(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Announcement?'),
          content: const Text(
            'Are you sure you want to delete this announcement?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/announcements/$id'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await fetchAnnouncements();
      } else {
        throw Exception('Failed to delete announcement');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete announcement.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================
  // FORMAT DATE
  // ==========================================

  String formatDate(dynamic date) {
    if (date == null) return 'Date unavailable';

    try {
      final parsedDate = DateTime.parse(date.toString());

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (_) {
      return date.toString();
    }
  }

  // ==========================================
  // BUILD SCREEN
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Announcements Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2446A6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh announcements',
            onPressed: isLoading ? null : fetchAnnouncements,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddAnnouncementDialog,
        backgroundColor: const Color(0xFF2446A6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Community Announcements',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${announcements.length} announcement(s)',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : announcements.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.campaign_outlined,
                                size: 70,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No announcements available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Click "Add Announcement" to publish one.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: fetchAnnouncements,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: announcements.length,
                            itemBuilder: (context, index) {
                              final announcement =
                                  announcements[index];

                              final id = int.tryParse(
                                    announcement['id'].toString(),
                                  ) ??
                                  0;

                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: 14,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE5EBFF),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.campaign,
                                          color: Color(0xFF2446A6),
                                          size: 27,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              announcement['title']
                                                      ?.toString() ??
                                                  'Untitled announcement',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              announcement['description']
                                                      ?.toString() ??
                                                  '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 15,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  formatDate(
                                                    announcement['date'],
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete announcement',
                                        onPressed: id > 0
                                            ? () => deleteAnnouncement(id)
                                            : null,
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}