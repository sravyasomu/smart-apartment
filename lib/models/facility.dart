class Facility {
  final int? id;
  final String name;
  final String description;
  final String openingTime;
  final String closingTime;
  final String icon;

  Facility({
    this.id,
    required this.name,
    required this.description,
    required this.openingTime,
    required this.closingTime,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'icon': icon,
    };
  }

  factory Facility.fromMap(Map<String, dynamic> map) {
    return Facility(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      openingTime: map['openingTime'] ?? '',
      closingTime: map['closingTime'] ?? '',
      icon: map['icon'] ?? 'home',
    );
  }
}