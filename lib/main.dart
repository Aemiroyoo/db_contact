import 'dart:io';

import 'package:db_contact/db/contact_model.dart';
import 'package:db_contact/db/db_helper.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // MaterialApp sebagai root widget
      debugShowCheckedModeBanner: false,
      title: 'CRUD Contacts',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ContactPage(),
    );
  }
}

class ContactPage extends StatefulWidget {
  // Menggunakan StatefulWidget karena datanya berubah (CRUD)
  @override
  _ContactPageState createState() => _ContactPageState(); // Membuat state untuk menangani state
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> contacts = []; // List untuk menampung data kontak

  @override
  void initState() {
    // initState() akan dipanggil pertama kali saat widget diinisialisasi
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    // Mengambil data kontak dari database
    final data = await DBHelper.instance.getContacts();
    setState(() {
      // Setelah data didapat, update state
      contacts = data;
    });

    // Debugging: Cek apakah path gambar ada dalam database
    for (var contact in contacts) {
      print("Contact: ${contact.name}, Image Path: ${contact.imagePath}");
    }
  }

  Future<void> _addContact(String name, String phone, String? imagePath) async {
    await DBHelper.instance.addContact(
      Contact(name: name, phone: phone, imagePath: imagePath),
    );
    _loadContacts();
  }

  Future<void> _updateContact(Contact contact) async {
    await DBHelper.instance.updateContact(contact);
    _loadContacts();
  }

  Future<void> _deleteContact(int id) async {
    await DBHelper.instance.deleteContact(id); // Hapus kontak berdasarkan ID
    _loadContacts();
  }

  void _showForm({Contact? contact}) {
    // Menampilkan form untuk menambah atau mengedit kontak
    final TextEditingController nameController = TextEditingController(
      text: contact?.name ?? '',
    );
    final TextEditingController phoneController = TextEditingController(
      text: contact?.phone ?? '',
    );
    String? imagePath = contact?.imagePath;

    Future<void> _pickImage() async {
      // Fungsi untuk memilih gambar dari galeri
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          imagePath = pickedFile.path;
        });
      }
    }

    showDialog(
      // Menampilkan dialog untuk Form Input
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // StatefulBuilder agar bisa memperbarui state
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(contact == null ? 'Tambah Kontak' : 'Edit Kontak'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    // Input Nama
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: 'Nama'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z. ]')),
                    ],
                  ),
                  TextField(
                    // Input Nomor HP
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: 'Nomor HP'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[+0-9 ]')),
                    ],
                  ),
                  SizedBox(height: 10),
                  imagePath != null
                      ? Image.file(
                        File(imagePath!),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                      : Icon(Icons.image, size: 100, color: Colors.grey),
                  TextButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final XFile? pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (pickedFile != null) {
                        setStateDialog(() {
                          imagePath = pickedFile.path;
                          print("Path Gambar: $imagePath"); // Debugging
                        });
                      }
                    },
                    child: Text("Pilih Gambar"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Batal'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text(contact == null ? 'Tambah' : 'Update'),
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty) {
                      if (contact == null) {
                        _addContact(
                          nameController.text,
                          phoneController.text,
                          imagePath,
                        );
                      } else {
                        _updateContact(
                          Contact(
                            id: contact.id,
                            name: nameController.text,
                            phone: phoneController.text,
                            imagePath: imagePath,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold sebagai layout utama
      appBar: AppBar(
        title: Text('Daftar Kontak', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: GridView.builder(
        // Menampilkan data kontak dalam grid
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dua kolom dalam grid
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 2.5 / 3.5, // lebar dan tinggi
        ),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          // Membuat item dalam grid
          final contact = contacts[index];
          return Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              // Menampilkan data kontak
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child:
                      contact.imagePath != null && // operator ternary
                              File(contact.imagePath!).existsSync()
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(contact.imagePath!),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Icon(Icons.person, size: 60, color: Colors.grey),
                ),
                SizedBox(height: 8.0),
                Text(
                  contact.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.0),
                Text(
                  contact.phone,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showForm(contact: contact),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteContact(contact.id!),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Tombol tambah kontak
        child: Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
    );
  }
}
