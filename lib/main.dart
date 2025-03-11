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
      debugShowCheckedModeBanner: false,
      title: 'CRUD Contacts',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ContactPage(),
    );
  }
}

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final data = await DBHelper.instance.getContacts();
    setState(() {
      contacts = data;
    });
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
    await DBHelper.instance.deleteContact(id);
    _loadContacts();
  }

  void _showForm({Contact? contact}) {
    final TextEditingController nameController = TextEditingController(
      text: contact?.name ?? '',
    );
    final TextEditingController phoneController = TextEditingController(
      text: contact?.phone ?? '',
    );
    String? imagePath = contact?.imagePath;

    Future<void> _pickImage(Function(String) onImagePicked) async {
      if (Platform.isAndroid || Platform.isIOS) {
        // Gunakan image_picker untuk mobile
        final picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
        );
        if (pickedFile != null) {
          onImagePicked(pickedFile.path);
        }
      }
      // else {
      //   // Gunakan file_picker untuk desktop
      //   FilePickerResult? result = await FilePicker.platform.pickFiles(
      //     type: FileType.image, // Hanya izinkan memilih gambar
      //   );
      //   if (result != null) {
      //     onImagePicked(result.files.single.path!);
      //   }
      // }
      // final pickedFile = await ImagePicker().pickImage(
      //   source: ImageSource.gallery,
      // );
      // if (pickedFile != null) {
      //   setState(() {
      //     imagePath = pickedFile.path;
      //   });
      // }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(contact == null ? 'Tambah Kontak' : 'Edit Kontak'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(labelText: 'Nama'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z. ]')),
                ],
              ),
              TextField(
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
                  await _pickImage((pickedPath) {
                    setState(() {
                      imagePath = pickedPath;
                    });
                  });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 20, 1, 2),
      appBar: AppBar(
        title: Text('Daftar Kontak', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dua kolom dalam grid
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 3 / 3.5,
        ),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child:
                      contact.imagePath != null
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
        child: Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
    );
  }
}
