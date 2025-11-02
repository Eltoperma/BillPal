/// Datenmodell für eine Person/Freund
class Person {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;

  const Person({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
  });

  Person copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Person(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}