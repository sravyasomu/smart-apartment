import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String apartmentNumber;
  final String block;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.apartmentNumber,
    required this.block,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String apiBaseUrl = 'http://127.0.0.1:3000/api';

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
  // LANGUAGE PREFERENCE
  // =========================================================

  // =========================================================
// LANGUAGE PREFERENCE
// =========================================================

  void languagePreference() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('choose_language'.tr()),
          content: RadioGroup<Locale>(
            groupValue: context.locale,
            onChanged: (Locale? locale) {
              if (locale == null) return;

              context.setLocale(locale);
              Navigator.pop(dialogContext);
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<Locale>(
                  title: Text('English'),
                  value: Locale('en'),
                ),
                RadioListTile<Locale>(
                  title: Text('తెలుగు'),
                  value: Locale('te'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('close'.tr()),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // PROFILE QR CODE
  // =========================================================

  void showProfileQr() {
    final profileData = jsonEncode({
      'type': 'resident_profile',
      'id': widget.userId,
      'name': currentName,
      'apartmentNumber': currentApartment,
      'block': currentBlock,
    });

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
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
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: QrImageView(
                      data: profileData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
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
    final nameController = TextEditingController(text: currentName);
    final apartmentController =
        TextEditingController(text: currentApartment);
    final blockController = TextEditingController(text: currentBlock);

    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool dialogSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      enabled: !dialogSaving,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: apartmentController,
                      enabled: !dialogSaving,
                      decoration: const InputDecoration(
                        labelText: 'Apartment Number',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: blockController,
                      enabled: !dialogSaving,
                      decoration: const InputDecoration(
                        labelText: 'Block',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dialogSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: dialogSaving
                      ? null
                      : () async {
                          final newName = nameController.text.trim();
                          final newApartment =
                              apartmentController.text.trim();
                          final newBlock = blockController.text.trim();

                          if (newName.isEmpty ||
                              newApartment.isEmpty ||
                              newBlock.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields.'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            dialogSaving = true;
                          });

                          try {
                            final response = await http
                                .put(
                                  Uri.parse(
                                    '$apiBaseUrl/residents/${widget.userId}',
                                  ),
                                  headers: {
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode({
                                    'name': newName,
                                    'apartment_number': newApartment,
                                    'block': newBlock,
                                  }),
                                )
                                .timeout(const Duration(seconds: 15));

                            final data =
                                jsonDecode(response.body)
                                    as Map<String, dynamic>;

                            if (response.statusCode == 200 &&
                                data['success'] == true) {
                              if (!mounted || !dialogContext.mounted) {
                                return;
                              }

                              setState(() {
                                currentName = newName;
                                currentApartment = newApartment;
                                currentBlock = newBlock;
                              });

                              Navigator.pop(dialogContext);

                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Profile saved to MySQL successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              throw Exception(
                                data['message'] ??
                                    'Unable to update profile.',
                              );
                            }
                          } catch (error) {
                            if (!mounted || !dialogContext.mounted) {
                              return;
                            }

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Profile update failed: $error',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );

                            setDialogState(() {
                              dialogSaving = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                  ),
                  child: dialogSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('SAVE'),
                ),
              ],
            );
          },
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
                style: TextStyle(fontWeight: FontWeight.bold),
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
                      activeThumbColor: const Color(0xFF1976D2),
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
                      activeThumbColor: const Color(0xFF1976D2),
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
                      activeThumbColor: const Color(0xFF1976D2),
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
                  onPressed: () => Navigator.pop(dialogContext),
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
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final messenger = ScaffoldMessenger.of(context);

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
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final currentPassword =
                    currentPasswordController.text;
                final newPassword = newPasswordController.text;
                final confirmPassword =
                    confirmPasswordController.text;

                if (currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all password fields.'),
                    ),
                  );
                  return;
                }

                if (newPassword.length < 6) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'New password must contain at least 6 characters.',
                      ),
                    ),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('New passwords do not match.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password form validated. Backend integration '
                      'is required to change the actual password.',
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
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help with the Smart Apartment application?',
                ),
                SizedBox(height: 20),
                Text('Contact Management: 98765 43210'),
                SizedBox(height: 15),
                Text('Email Support: support@smartapartment.com'),
                SizedBox(height: 15),
                Text('Management Office: Apartment Community Office'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
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
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  dialogContext,
                  MaterialPageRoute<void>(
                    builder: (context) => const LoginScreen(),
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
  // BUILD PROFILE SCREEN
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: Text(
          'profile'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 400 ? 12.0 : 20.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'apartment_information'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 18),
                          informationRow(
                            Icons.person_outline,
                            'name'.tr(),
                            currentName,
                          ),
                          const SizedBox(height: 15),
                          informationRow(
                            Icons.home_outlined,
                            'apartment'.tr(),
                            currentApartment,
                          ),
                          const SizedBox(height: 15),
                          informationRow(
                            Icons.business_outlined,
                            'block'.tr(),
                            currentBlock,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    profileOption(
                      Icons.language,
                      'language_preference'.tr(),
                      'change_app_language'.tr(),
                      languagePreference,
                    ),
                    profileOption(
                      Icons.qr_code_2,
                      'my_profile_qr'.tr(),
                      'show_resident_qr'.tr(),
                      showProfileQr,
                    ),
                    profileOption(
                      Icons.edit_outlined,
                      'edit_profile'.tr(),
                      'update_personal_information'.tr(),
                      editProfile,
                    ),
                    profileOption(
                      Icons.notifications_outlined,
                      'notification_settings'.tr(),
                      'manage_notifications'.tr(),
                      notificationSettings,
                    ),
                    profileOption(
                      Icons.lock_outline,
                      'change_password'.tr(),
                      'update_account_password'.tr(),
                      changePassword,
                    ),
                    profileOption(
                      Icons.help_outline,
                      'help_support'.tr(),
                      'get_application_help'.tr(),
                      helpAndSupport,
                    ),
                    profileOption(
                      Icons.logout,
                      'logout'.tr(),
                      'sign_out_account'.tr(),
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