import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RemindersManagementScreen extends StatefulWidget {
  const RemindersManagementScreen({super.key});

  @override
  State<RemindersManagementScreen> createState() =>
      _RemindersManagementScreenState();
}

class _RemindersManagementScreenState
    extends State<RemindersManagementScreen> {
  static const String baseUrl = 'http://localhost:3000/api';

  List<Map<String, dynamic>> reminders = [];

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchReminders();
  }

  Future<void> fetchReminders() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/admin/reminders'),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Server returned status ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map || decoded['reminders'] is! List) {
        throw Exception('Invalid reminders response.');
      }

      final List<dynamic> items = decoded['reminders'];

      if (!mounted) return;

      setState(() {
        reminders = items
            .map(
              (item) => Map<String, dynamic>.from(item as Map),
            )
            .toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load reminders: $e'),
        ),
      );
    }
  }

  Future<DateTime?> selectDate() async {
    final now = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
    );
  }

  Future<TimeOfDay?> selectTime() async {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  Future<void> showAddReminderDialog() async {
    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Reminder'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Reminder Title',
                            prefixIcon: Icon(Icons.title),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: dateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Reminder Date',
                            prefixIcon:
                                Icon(Icons.calendar_month),
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            final date = await selectDate();

                            if (date != null) {
                              dateController.text =
                                  '${date.year}-'
                                  '${date.month.toString().padLeft(2, '0')}-'
                                  '${date.day.toString().padLeft(2, '0')}';
                            }
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: timeController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Reminder Time',
                            prefixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            final time = await selectTime();

                            if (time != null) {
                              timeController.text =
                                  '${time.hour.toString().padLeft(2, '0')}:'
                                  '${time.minute.toString().padLeft(2, '0')}';
                            }
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Please select a time';
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
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.pop(dialogContext, false);
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          final success = await createReminder(
                            title: titleController.text.trim(),
                            description:
                                descriptionController.text.trim(),
                            date: dateController.text,
                            time: timeController.text,
                          );

                          if (!dialogContext.mounted) return;

                          if (success) {
                            Navigator.pop(dialogContext, true);
                          } else {
                            setDialogState(() {
                              saving = false;
                            });
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Reminder'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();

    if (result == true && mounted) {
      await fetchReminders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<bool> createReminder({
    required String title,
    required String description,
    required String date,
    required String time,
  }) async {
    if (mounted) {
      setState(() {
        isSaving = true;
      });
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/reminders'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'date': date,
          'time': time,
        }),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }

      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to create reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> deleteReminder(
    Map<String, dynamic> reminder,
  ) async {
    final id = reminder['id'];

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder ID is missing.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text(
          'Are you sure you want to delete this reminder?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/reminders/$id'),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 204) {
        throw Exception(
          'Server returned ${response.statusCode}',
        );
      }

      await fetchReminders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to delete reminder: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Manage Reminders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isLoading ? null : fetchReminders,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddReminderDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : reminders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          size: 70,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No reminders available',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create a reminder for apartment residents.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: showAddReminderDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Reminder'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchReminders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];

                      final title =
                          reminder['title']?.toString() ??
                              'Reminder';

                      final description =
                          reminder['description']?.toString() ??
                              '';

                      final date =
                          reminder['date']?.toString() ?? '';

                      final time =
                          reminder['time']?.toString() ?? '';

                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: 14),
                        elevation: 2,
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.all(14),
                          leading: const CircleAvatar(
                            backgroundColor:
                                Color(0xFFE8EAF6),
                            child: Icon(
                              Icons.notifications_active,
                              color: Colors.indigo,
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding:
                                const EdgeInsets.only(top: 8),
                            child: Text(
                              '$description\nDate: $date\nTime: $time',
                            ),
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            onPressed: () =>
                                deleteReminder(reminder),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            tooltip: 'Delete reminder',
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}