import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contact_model.dart';

class DBHelper {
  static Database? _database;
  static final DBHelper instance = DBHelper._init();

  DBHelper._init(); // Konstruktor

  Future<Database> get database async {
    //
    if (_database != null)
      return _database!; // Jika database sudah ada, kembalikan database yang sudah ada
    _database = await _initDB('contacts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Membuat database
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      // Membuka database
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE contacts ADD COLUMN imagePath TEXT');
          // Run migration according to the oldVersion
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Membuat tabel contacts
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        imagePath TEXT
      )
    ''');
  }

  // CREATE - Tambah kontak baru
  Future<int> addContact(Contact contact) async {
    final db = await instance.database;
    return await db.insert('contacts', contact.toMap());
  }

  // READ - Ambil semua kontak
  Future<List<Contact>> getContacts() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> contacts = await db.query('contacts');
    return contacts.map((c) => Contact.fromMap(c)).toList();
  }

  // UPDATE - Perbarui kontak
  Future<int> updateContact(Contact contact) async {
    final db = await instance.database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // DELETE - Hapus kontak
  Future<int> deleteContact(int id) async {
    final db = await instance.database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}
