//Struktur Kelas
class Contact {
  int? id;
  String name;
  String phone;
  String? imagePath;

  // Konstruktor / membuat objek baru dari kelas Contact
  Contact({this.id, required this.name, required this.phone, this.imagePath});

  // Konversi dari Map (Database) ke Objek Contact
  factory Contact.fromMap(Map<String, dynamic> json) => Contact(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    imagePath: json['imagePath'],
  );

  // Konversi dari Objek Contact ke Map (untuk Disimpan ke Database)
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone, 'imagePath': imagePath};
  }
}
