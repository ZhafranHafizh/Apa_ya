import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SafeArea(child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseHelper _databaseHelper;
  List<Map<String, dynamic>> userData = [];
  final TextEditingController _nameEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _initializeDatabaseAndFetchData();
  }

  Future<void> _initializeDatabaseAndFetchData() async {
    await _databaseHelper.initializeDatabase();
    final List<Map<String, dynamic>> fetchedUserData =
        await _databaseHelper.fetchUserData();
    setState(() {
      userData = fetchedUserData;
    });
  }

  Future<void> _insertUserData(String name) async {
    await _databaseHelper.insertUserData(name);
    await _initializeDatabaseAndFetchData();
  }

  Future<void> _updateUserData(int id, String newName) async {
    await _databaseHelper.updateUserData(id, newName);
    await _initializeDatabaseAndFetchData();
  }

  Future<void> _deleteUserData(int id) async {
    await _databaseHelper.deleteUserData(id);
    await _initializeDatabaseAndFetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'List Users',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: userData.isEmpty
                  ? const Center(
                      child: Text('Tidak ada pengguna.'),
                    )
                  : ListView.builder(
                      itemCount: userData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final userDataItem = userData[index];
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${userDataItem['id']}'),
                              Text('Name: ${userDataItem['name']}')
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      String newName = userDataItem['name'];
                                      return AlertDialog(
                                        title: const Text('Edit User'),
                                        content: TextField(
                                          controller: TextEditingController(
                                              text: newName),
                                          onChanged: (value) {
                                            newName = value;
                                          },
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _updateUserData(
                                                  userDataItem['id'], newName);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Simpan'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Konfirmasi'),
                                        content: const Text(
                                            'Anda yakin ingin menghapus pengguna ini?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Tidak'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _deleteUserData(
                                                  userDataItem['id']);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Ya'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameEditingController,
              decoration: const InputDecoration(
                labelText: 'Input nama',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _insertUserData(_nameEditingController.text);
                _nameEditingController.clear();
              },
              child: const Text('Tambahkan'),
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseHelper {
  late sql.Database _db;

  Future<void> initializeDatabase() async {
    _db = await sql.openDatabase(
      'user.db',
      version: 1,
      onCreate: (sql.Database db, int version) async {
        await db.execute(
          'CREATE TABLE user(id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchUserData() async {
    return await _db.query('user');
  }

  Future<void> insertUserData(String name) async {
    await _db.rawInsert(
      'INSERT INTO user(name) VALUES(?)',
      [name],
    );
  }

  Future<void> updateUserData(int id, String newName) async {
    await _db.rawUpdate(
      'UPDATE user SET name = ? WHERE id = ?',
      [newName, id],
    );
  }

  Future<void> deleteUserData(int id) async {
    await _db.rawDelete(
      'DELETE FROM user WHERE id = ?',
      [id],
    );
  }
}
