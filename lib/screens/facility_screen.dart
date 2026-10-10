import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'facilitydetails_screen.dart';

class FacilityScreen extends StatefulWidget {
  const FacilityScreen({super.key});

  @override
  State<FacilityScreen> createState() => _FacilityScreenState();
}

class _FacilityScreenState extends State<FacilityScreen> {
  final String apiUrl = 'http://localhost:3000/api/facilities';

  List<Map<String, dynamic>> facilities = [];

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchFacilities();
  }

  // Convert icon names received from MySQL into Flutter icons.
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

  // Fetch facilities from the Node.js REST API.
  Future<void> fetchFacilities() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['success'] == true) {
          final List<dynamic> data =
              responseData['facilities'] as List<dynamic>;

          final List<Map<String, dynamic>> loadedFacilities =
              data.map((item) {
            final Map<String, dynamic> facility =
                Map<String, dynamic>.from(item as Map);

            return {
              'id': facility['id'],
              'name': facility['name']?.toString() ?? 'Facility',
              'description':
                  facility['description']?.toString() ?? '',
              'opening_time':
                  facility['opening_time']?.toString() ?? '',
              'closing_time':
                  facility['closing_time']?.toString() ?? '',
              'icon': facility['icon']?.toString() ?? '',
            };
          }).toList();

          if (!mounted) return;

          setState(() {
            facilities = loadedFacilities;
            isLoading = false;
          });
        } else {
          throw Exception(
            responseData['message'] ?? 'Unable to load facilities.',
          );
        }
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load facilities. Please check your backend connection.';
      });

      debugPrint('Facilities API error: $e');
    }
  }

  // Open facility details.
  void openFacility(Map<String, dynamic> facility) {
    final String openingTime =
        facility['opening_time']?.toString() ?? '';

    final String closingTime =
        facility['closing_time']?.toString() ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacilityDetailsScreen(
          facilityName: facility['name']?.toString() ?? 'Facility',
          icon: getFacilityIcon(facility['icon']?.toString()),
          timing: '$openingTime - $closingTime',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text(
          'Facilities',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1976D2),
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 55,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: fetchFacilities,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : facilities.isEmpty
                  ? const Center(
                      child: Text('No facilities found.'),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 850,
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 190,
                          ),
                          itemCount: facilities.length,
                          itemBuilder: (context, index) {
                            final facility = facilities[index];

                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => openFacility(facility),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F1FF),
                                          borderRadius:
                                              BorderRadius.circular(17),
                                        ),
                                        child: Icon(
                                          getFacilityIcon(
                                            facility['icon']?.toString(),
                                          ),
                                          size: 32,
                                          color: const Color(0xFF1976D2),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        facility['name']?.toString() ??
                                            'Facility',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${facility['opening_time']} - '
                                        '${facility['closing_time']}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'View Details →',
                                        style: TextStyle(
                                          color: Color(0xFF1976D2),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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