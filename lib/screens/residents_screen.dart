import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResidentsScreen extends StatefulWidget {
  const ResidentsScreen({super.key});

  @override
  State<ResidentsScreen> createState() => _ResidentsScreenState();
}

class _ResidentsScreenState extends State<ResidentsScreen> {
  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> residents = [];
  List<Map<String, dynamic>> filteredResidents = [];

  final TextEditingController searchController =
      TextEditingController();

  static const String apiUrl =
      'http://localhost:3000/api/admin/residents';

  @override
  void initState() {
    super.initState();
    fetchResidents();

    searchController.addListener(filterResidents);
  }

  Future<void> fetchResidents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Server returned status ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data['success'] != true || data['residents'] is! List) {
        throw Exception('Invalid response received from server.');
      }

      final List<Map<String, dynamic>> fetchedResidents =
          (data['residents'] as List)
              .map(
                (resident) => Map<String, dynamic>.from(resident),
              )
              .toList();

      if (!mounted) return;

      setState(() {
        residents = fetchedResidents;
        isLoading = false;
      });

      filterResidents();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void filterResidents() {
    final query = searchController.text.trim().toLowerCase();

    final results = residents.where((resident) {
      final name = (resident['name'] ?? '').toString().toLowerCase();
      final email = (resident['email'] ?? '').toString().toLowerCase();
      final phone = (resident['phone'] ?? '').toString().toLowerCase();
      final apartment =
          (resident['apartment_number'] ?? '').toString().toLowerCase();
      final block = (resident['block'] ?? '').toString().toLowerCase();

      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query) ||
          apartment.contains(query) ||
          block.contains(query);
    }).toList();

    if (!mounted) return;

    setState(() {
      filteredResidents = results;
    });
  }

  @override
  void dispose() {
    searchController.removeListener(filterResidents);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Residents Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh residents',
            onPressed: isLoading ? null : fetchResidents,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Residents',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'View and search registered apartment residents.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Resident count
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(
                          Icons.people_alt_outlined,
                          color: Color(0xFF1976D2),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Residents',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${residents.length}',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Search field
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search name, email, flat or block...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'Clear search',
                      onPressed: () => searchController.clear(),
                      icon: const Icon(Icons.close),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 45,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Unable to load residents.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    errorMessage!,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: fetchResidents,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            )
                          : filteredResidents.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No residents found.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: fetchResidents,
                                  child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: filteredResidents.length,
                                    itemBuilder: (context, index) {
                                      final resident =
                                          filteredResidents[index];

                                      final name =
                                          (resident['name'] ?? 'Resident')
                                              .toString();

                                      final apartment =
                                          (resident['apartment_number'] ??
                                                  'Not assigned')
                                              .toString();

                                      final block =
                                          (resident['block'] ??
                                                  'Not assigned')
                                              .toString();

                                      final email =
                                          (resident['email'] ?? '')
                                              .toString();

                                      final phone =
                                          (resident['phone'] ?? '')
                                              .toString();

                                      return Card(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        color: Colors.white,
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor:
                                                    const Color(0xFFE3F2FD),
                                                child: Text(
                                                  name.isNotEmpty
                                                      ? name[0].toUpperCase()
                                                      : '?',
                                                  style: const TextStyle(
                                                    color: Color(0xFF1976D2),
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      name,
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _detailRow(
                                                      Icons.email_outlined,
                                                      email.isEmpty
                                                          ? 'No email'
                                                          : email,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    _detailRow(
                                                      Icons.phone_outlined,
                                                      phone.isEmpty
                                                          ? 'No phone number'
                                                          : phone,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    _detailRow(
                                                      Icons.apartment_outlined,
                                                      'Flat $apartment · Block $block',
                                                    ),
                                                  ],
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
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}