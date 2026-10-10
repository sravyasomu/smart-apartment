class Reminder {
  final int? id;
  final String title;
  final String description;
  final String date;
  final String time;
  final bool completed;

  Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'completed': completed,
    };
  }

  factory Reminder.fromMap(
    Map<String, dynamic> map,
  ) {
    return Reminder(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      completed: map['completed'] ?? false,
    );
  }
}