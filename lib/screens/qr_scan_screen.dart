import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController scannerController =
      MobileScannerController();

  bool isProcessing = false;
  String message = 'Point your camera at a resident QR code.';

  Map<String, dynamic>? resident;

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  Future<void> handleQrCode(String rawValue) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
      message = 'Reading QR code...';
    });

    await scannerController.stop();

    try {
      final decoded = jsonDecode(rawValue);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid QR format.');
      }

      if (decoded['type'] != 'resident_profile') {
        setState(() {
          message = 'This is not a resident profile QR code.';
        });

        return;
      }

      final dynamic residentId = decoded['id'];

      // QR codes containing an ID can retrieve the latest
      // resident details from the backend.
      if (residentId != null) {
        final response = await http
            .get(
              Uri.parse(
                'http://127.0.0.1:3000/api/residents/$residentId',
              ),
            )
            .timeout(const Duration(seconds: 10));

        final data = jsonDecode(response.body);

        if (response.statusCode != 200 ||
            data['success'] != true) {
          throw Exception(
            data['message'] ?? 'Resident not found.',
          );
        }

        if (!mounted) return;

        setState(() {
          resident = Map<String, dynamic>.from(
            data['resident'],
          );
          message = 'Resident profile found.';
        });

        return;
      }

      // Supports your existing QR, which stores name,
      // apartment number and block but no database ID.
      if (decoded['name'] != null) {
        if (!mounted) return;

        setState(() {
          resident = {
            'name': decoded['name'],
            'apartment_number':
                decoded['apartmentNumber'] ?? '',
            'block': decoded['block'] ?? '',
          };

          message =
              'QR read successfully. These are the details encoded in the QR.';
        });

        return;
      }

      throw const FormatException(
        'Resident details were not found in this QR code.',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        message = 'Unable to read QR: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });

        await scannerController.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Scan Resident QR'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Switch camera',
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              scannerController.switchCamera();
            },
          ),
          IconButton(
            tooltip: 'Toggle torch',
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              scannerController.toggleTorch();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 320,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: MobileScanner(
                controller: scannerController,
                onDetect: (capture) {
                  if (capture.barcodes.isEmpty) return;

                  final value =
                      capture.barcodes.first.rawValue;

                  if (value != null && value.isNotEmpty) {
                    handleQrCode(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            if (resident != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Color(0xFF1976D2),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Resident Details',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _detailRow(
                        'Name',
                        resident!['name']?.toString() ?? '',
                      ),
                      _detailRow(
                        'Apartment',
                        resident!['apartment_number']
                                ?.toString() ??
                            resident!['apartmentNumber']
                                ?.toString() ??
                            '',
                      ),
                      _detailRow(
                        'Block',
                        resident!['block']?.toString() ?? '',
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    resident = null;
                    message =
                        'Point your camera at a resident QR code.';
                    isProcessing = false;
                  });

                  scannerController.start();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Another QR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}