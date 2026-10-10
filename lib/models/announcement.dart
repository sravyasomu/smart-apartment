class Announcement {
  final int? id;
  final String title;
  final String description;
  final String date;

  Announcement({
    this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
    };
  }

  factory Announcement.fromMap(
    Map<String, dynamic> map,
  ) {
    return Announcement(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
    );
  }
}