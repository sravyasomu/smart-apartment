import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FacilitiesManagementScreen extends StatefulWidget {
  const FacilitiesManagementScreen({super.key});

  @override
  State<FacilitiesManagementScreen> createState() =>
      _FacilitiesManagementScreenState();
}

class _FacilitiesManagementScreenState
    extends State<FacilitiesManagementScreen> {
  static const String apiUrl = 'http://localhost:3000/api/facilities';

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> facilities = [];

  @override
  void initState() {
    super.initState();
    fetchFacilities();
  }

  Future<void> fetchFacilities() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['success'] != true || data['facilities'] is! List) {
        throw Exception('Invalid facilities response.');
      }

      final items = (data['facilities'] as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        facilities = items;
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

  IconData getFacilityIcon(String? iconName) {
    switch (iconName) {
      case 'pool':
        return Icons.pool;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'park':
        return Icons.park;
      case 'sports_cricket':
        return Icons.sports_cricket;
      case 'groups':
        return Icons.groups;
      case 'local_parking':
        return Icons.local_parking;
      default:
        return Icons.apartment;
    }
  }

  Future<void> editFacility(Map<String, dynamic> facility) async {
    final nameController = TextEditingController(
      text: (facility['name'] ?? '').toString(),
    );

    final descriptionController = TextEditingController(
      text: (facility['description'] ?? '').toString(),
    );

    final openingController = TextEditingController(
      text: (facility['opening_time'] ?? '').toString(),
    );

    final closingController = TextEditingController(
      text: (facility['closing_time'] ?? '').toString(),
    );

    final iconController = TextEditingController(
      text: (facility['icon'] ?? '').toString(),
    );

    final formKey = GlobalKey<FormState>();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Facility'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInput(
                      nameController,
                      'Facility name',
                      required: true,
                    ),
                    _buildInput(
                      descriptionController,
                      'Description',
                      maxLines: 3,
                    ),
                    _buildInput(
                      openingController,
                      'Opening time',
                    ),
                    _buildInput(
                      closingController,
                      'Closing time',
                    ),
                    _buildInput(
                      iconController,
                      'Icon name',
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true || !mounted) {
      nameController.dispose();
      descriptionController.dispose();
      openingController.dispose();
      closingController.dispose();
      iconController.dispose();
      return;
    }

    final int facilityId = int.parse(facility['id'].toString());

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$facilityId'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text.trim(),
          'description': descriptionController.text.trim(),
          'opening_time': openingController.text.trim(),
          'closing_time': closingController.text.trim(),
          'icon': iconController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facility updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await fetchFacilities();
      } else {
        throw Exception(
          data['message'] ?? 'Unable to update facility.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      openingController.dispose();
      closingController.dispose();
      iconController.dispose();
    }
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Facilities Management'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isLoading ? null : fetchFacilities,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            const Text('Unable to load facilities'),
                            const SizedBox(height: 8),
                            Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: fetchFacilities,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : facilities.isEmpty
                      ? const Center(child: Text('No facilities found.'))
                      : RefreshIndicator(
                          onRefresh: fetchFacilities,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(20),
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 350,
                              mainAxisExtent: 265,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                            ),
                            itemCount: facilities.length,
                            itemBuilder: (context, index) {
                              final facility = facilities[index];

                              final name =
                                  (facility['name'] ?? 'Facility')
                                      .toString();

                              final description =
                                  (facility['description'] ?? '')
                                      .toString();

                              final opening =
                                  (facility['opening_time'] ?? 'Not set')
                                      .toString();

                              final closing =
                                  (facility['closing_time'] ?? 'Not set')
                                      .toString();

                              final iconName =
                                  (facility['icon'] ?? '').toString();

                              return Card(
                                color: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                const Color(0xFFE3F2FD),
                                            child: Icon(
                                              getFacilityIcon(iconName),
                                              color:
                                                  const Color(0xFF1976D2),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Expanded(
                                        child: Text(
                                          description.isEmpty
                                              ? 'No description available.'
                                              : description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Opening: $opening',
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Closing: $closing',
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              editFacility(facility),
                                          icon: const Icon(Icons.edit),
                                          label:
                                              const Text('Edit Facility'),
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
      ),
    );
  }
}