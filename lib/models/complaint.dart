class Complaint {
  final int? id;
  final String residentName;
  final String apartmentNumber;
  final String category;
  final String description;
  final String date;
  final String status;

  Complaint({
    this.id,
    required this.residentName,
    required this.apartmentNumber,
    required this.category,
    required this.description,
    required this.date,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'residentName': residentName,
      'apartmentNumber': apartmentNumber,
      'category': category,
      'description': description,
      'date': date,
      'status': status,
    };
  }

  factory Complaint.fromMap(
    Map<String, dynamic> map,
  ) {
    return Complaint(
      id: map['id'],
      residentName:
          map['residentName'] ?? '',
      apartmentNumber:
          map['apartmentNumber'] ?? '',
      category: map['category'] ?? '',
      description:
          map['description'] ?? '',
      date: map['date'] ?? '',
      status:
          map['status'] ?? 'Pending',
    );
  }
}