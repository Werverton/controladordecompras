import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Representantes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class Representative {
  final int id;
  final String name;
  final String contact;
  final String company;
  final String department;

  Representative({
    required this.id,
    required this.name,
    required this.contact,
    required this.company,
    required this.department,
  });
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  late Database _database;
  List<Representative> _representatives = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadRepresentatives();
  }

  _initializeDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    _database = await openDatabase(
      join(await getDatabasesPath(), 'representatives_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE representatives(id INTEGER PRIMARY KEY, name TEXT, contact TEXT, company TEXT, department TEXT)",
        );
      },
      version: 1,
    );
  }

  _loadRepresentatives() async {
    final List<Map<String, dynamic>> maps = await _database.query('representatives');

    setState(() {
      _representatives = List.generate(
        maps.length,
        (i) => Representative(
          id: maps[i]['id'],
          name: maps[i]['name'],
          contact: maps[i]['contact'],
          company: maps[i]['company'],
          department: maps[i]['department'],
        ),
      );
    });
  }

  _insertRepresentative() async {
    await _database.insert(
      'representatives',
      {
        'name': _nameController.text,
        'contact': _contactController.text,
        'company': _companyController.text,
        'department': _departmentController.text,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _clearFields();
    _loadRepresentatives();
  }

  _clearFields() {
    _nameController.clear();
    _contactController.clear();
    _companyController.clear();
    _departmentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Representantes'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nome do Representante'),
                  ),
                  TextField(
                    controller: _contactController,
                    decoration: InputDecoration(labelText: 'Contato'),
                  ),
                  TextField(
                    controller: _companyController,
                    decoration: InputDecoration(labelText: 'Empresa'),
                  ),
                  TextField(
                    controller: _departmentController,
                    decoration: InputDecoration(labelText: 'Departamento'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _insertRepresentative,
                    child: Text('Salvar'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Representantes Cadastrados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _representatives.isEmpty
                ? Text('Nenhum representante cadastrado.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _representatives.length,
                    itemBuilder: (context, index) {
                      final representative = _representatives[index];
                      return ListTile(
                        title: Text(representative.name),
                        subtitle: Text('${representative.company} - ${representative.department}'),
                        // Add more details as needed
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
