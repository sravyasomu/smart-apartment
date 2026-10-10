
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'login_screen.dart';
import 'admin_dashboard.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String apartmentNumber;
  final String block;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.apartmentNumber,
    required this.block,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String currentName;
  late String currentApartment;
  late String currentBlock;

  bool announcementsEnabled = true;
  bool remindersEnabled = true;
  bool complaintUpdatesEnabled = true;

  @override
  void initState() {
    super.initState();
    currentName = widget.userName;
    currentApartment = widget.apartmentNumber;
    currentBlock = widget.block;
  }

  // =========================================================
  // PROFILE QR CODE
  // =========================================================

  void showProfileQr() {
    final profileData = jsonEncode({
      'type': 'resident_profile',
      'name': currentName,
      'apartmentNumber': currentApartment,
      'block': currentBlock,
    });

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 360,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_2,
                    color: Color(0xFF1976D2),
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'My Profile QR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: QrImageView(
                      data: profileData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel:
                          QrErrorCorrectLevel.M,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    currentName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Flat $currentApartment • Block $currentBlock',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Scan this code to read the profile details '
                    'encoded in it. Opening another resident’s '
                    'profile automatically will be added in the '
                    'next step.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                      child: const Text('CLOSE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // EDIT PROFILE
  // =========================================================

  void editProfile() {
    final nameController =
        TextEditingController(text: currentName);
    final apartmentController =
        TextEditingController(text: currentApartment);
    final blockController =
        TextEditingController(text: currentBlock);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon:
                        const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: apartmentController,
                  decoration: InputDecoration(
                    labelText: 'Apartment Number',
                    prefixIcon:
                        const Icon(Icons.home_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: blockController,
                  decoration: InputDecoration(
                    labelText: 'Block',
                    prefixIcon:
                        const Icon(Icons.business_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName =
                    nameController.text.trim();
                final newApartment =
                    apartmentController.text.trim();
                final newBlock =
                    blockController.text.trim();

                if (newName.isEmpty ||
                    newApartment.isEmpty ||
                    newBlock.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please fill all fields.',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  currentName = newName;
                  currentApartment = newApartment;
                  currentBlock = newBlock;
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Profile updated successfully!',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      apartmentController.dispose();
      blockController.dispose();
    });
  }

  // =========================================================
  // NOTIFICATION SETTINGS
  // =========================================================

  void notificationSettings() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Notification Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Announcements'),
                      subtitle: const Text(
                        'Receive apartment announcements',
                      ),
                      value: announcementsEnabled,
                      activeThumbColor:
                          const Color(0xFF1976D2),
                      onChanged: (value) {
                        setDialogState(() {
                          announcementsEnabled = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Reminders'),
                      subtitle: const Text(
                        'Receive payment and event reminders',
                      ),
                      value: remindersEnabled,
                      activeThumbColor:
                          const Color(0xFF1976D2),
                      onChanged: (value) {
                        setDialogState(() {
                          remindersEnabled = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Complaint Updates'),
                      subtitle: const Text(
                        'Receive complaint updates',
                      ),
                      value: complaintUpdatesEnabled,
                      activeThumbColor:
                          const Color(0xFF1976D2),
                      onChanged: (value) {
                        setDialogState(() {
                          complaintUpdatesEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('DONE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================
  // CHANGE PASSWORD
  // =========================================================

  void changePassword() {
    final currentPasswordController =
        TextEditingController();
    final newPasswordController =
        TextEditingController();
    final confirmPasswordController =
        TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Change Password',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon:
                        const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon:
                        const Icon(Icons.lock_reset),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon:
                        const Icon(Icons.lock_reset),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final currentPassword =
                    currentPasswordController.text;
                final newPassword =
                    newPasswordController.text;
                final confirmPassword =
                    confirmPasswordController.text;

                if (currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please fill all password fields.',
                      ),
                    ),
                  );
                  return;
                }

                if (newPassword.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'New password must contain at least '
                        '6 characters.',
                      ),
                    ),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'New passwords do not match.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password form validated. Connect this '
                      'action to the backend to change the '
                      'actual account password.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: const Text('CHANGE'),
            ),
          ],
        );
      },
    ).then((_) {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    });
  }

  // =========================================================
  // HELP AND SUPPORT
  // =========================================================

  void helpAndSupport() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Help & Support',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need help with the Smart Apartment application?',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),
                supportRow(
                  Icons.phone_outlined,
                  'Contact Management',
                  '98765 43210',
                ),
                const SizedBox(height: 15),
                supportRow(
                  Icons.email_outlined,
                  'Email Support',
                  'support@smartapartment.com',
                ),
                const SizedBox(height: 15),
                supportRow(
                  Icons.location_on_outlined,
                  'Management Office',
                  'Apartment Community Office',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  Widget supportRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1976D2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  void logout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // INFORMATION ROW
  // =========================================================

  Widget informationRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1976D2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PROFILE OPTION
  // =========================================================

  Widget profileOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 5,
            ),
            leading: CircleAvatar(
              backgroundColor: isLogout
                  ? Colors.red.withValues(alpha: 0.1)
                  : const Color(0xFFE8F1FF),
              child: Icon(
                icon,
                color: isLogout
                    ? Colors.red
                    : const Color(0xFF1976D2),
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLogout ? Colors.red : Colors.black,
              ),
            ),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double horizontalPadding =
              constraints.maxWidth < 400 ? 12 : 20;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 700,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFFE8F1FF),
                        child: Icon(
                          Icons.person,
                          size: 55,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      currentName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Flat $currentApartment • Block $currentBlock',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // APARTMENT INFORMATION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Apartment Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 18),
                          informationRow(
                            Icons.person_outline,
                            'Name',
                            currentName,
                          ),
                          const SizedBox(height: 15),
                          informationRow(
                            Icons.home_outlined,
                            'Apartment',
                            currentApartment,
                          ),
                          const SizedBox(height: 15),
                          informationRow(
                            Icons.business_outlined,
                            'Block',
                            currentBlock,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    profileOption(
                      context,
                      Icons.qr_code_2,
                      'My Profile QR',
                      'Show your resident QR code',
                      showProfileQr,
                    ),

                    profileOption(
                      context,
                      Icons.edit_outlined,
                      'Edit Profile',
                      'Update your personal information',
                      editProfile,
                    ),

                    profileOption(
                      context,
                      Icons.notifications_outlined,
                      'Notification Settings',
                      'Manage apartment notifications',
                      notificationSettings,
                    ),

                    profileOption(
                      context,
                      Icons.lock_outline,
                      'Change Password',
                      'Update your account password',
                      changePassword,
                    ),

                    profileOption(
                      context,
                      Icons.help_outline,
                      'Help & Support',
                      'Get help with the application',
                      helpAndSupport,
                    ),

                    profileOption(
                      context,
                      Icons.admin_panel_settings_outlined,
                      'Admin Dashboard',
                      'Open administration panel',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                const AdminDashboard(),
                          ),
                        );
                      },
                    ),

                    profileOption(
                      context,
                      Icons.logout,
                      'Logout',
                      'Sign out of your account',
                      logout,
                      isLogout: true,
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
}
