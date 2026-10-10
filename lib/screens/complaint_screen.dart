import 'package:flutter/material.dart';
import 'mycomplaints_screen.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() =>
      _ComplaintScreenState();
}

class _ComplaintScreenState
    extends State<ComplaintScreen> {

  String selectedCategory = 'Water';

  final TextEditingController descriptionController =
      TextEditingController();

  final List<String> categories = [
    'Water',
    'Electricity',
    'Lift',
    'Parking',
    'Security',
    'Cleaning',
    'Other',
  ];

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  void submitComplaint() {
    final description =
        descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your complaint description.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get current date
    final now = DateTime.now();

    final date =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';

    // Save complaint
    ComplaintStorage.complaints.insert(
      0,
      Complaint(
        category: selectedCategory,
        description: description,
        date: date,
        status: 'Pending',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Complaint submitted successfully.',
        ),
        backgroundColor: Colors.green,
      ),
    );

    descriptionController.clear();

    setState(() {
      selectedCategory = 'Water';
    });
  }

  void openMyComplaints() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const MyComplaintsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text(
          'Raise Complaint',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'My Complaints',
            onPressed: openMyComplaints,
          ),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // Category
                const Text(
                  'Complaint Category',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),

                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),

                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),

                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),

                const SizedBox(height: 25),

                // Description
                const Text(
                  'Complaint Description',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller:
                      descriptionController,

                  maxLines: 6,

                  decoration: InputDecoration(
                    hintText:
                        'Describe your complaint...',

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),

                    contentPadding:
                        const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 20),

                // Image attachment
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(15),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,

                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFE8F1FF),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: const Icon(
                          Icons.image_outlined,
                          color:
                              Color(0xFF1976D2),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'Attach an image (optional)',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Image attachment will be available soon.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    onPressed: submitComplaint,

                    icon: const Icon(
                      Icons.send_outlined,
                    ),

                    label: const Text(
                      'SUBMIT COMPLAINT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1976D2),

                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // View complaints
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: OutlinedButton.icon(
                    onPressed: openMyComplaints,

                    icon: const Icon(
                      Icons.history,
                    ),

                    label: const Text(
                      'VIEW MY COMPLAINTS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(0xFF1976D2),

                      side: const BorderSide(
                        color: Color(0xFF1976D2),
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}