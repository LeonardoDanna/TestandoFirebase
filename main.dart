import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Pessoas',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ).copyWith(
          secondary: Colors.greenAccent,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PessoaLista(),
    );
  }
}

class PessoaLista extends StatefulWidget {
  @override
  _PessoaListaState createState() => _PessoaListaState();
}

class _PessoaListaState extends State<PessoaLista> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _estadoCivilController = TextEditingController();

  Future<void> _adicionarPessoa(String nome, String idade, String estadoCivil) async {
    if (nome.isNotEmpty && idade.isNotEmpty && estadoCivil.isNotEmpty) {
      await FirebaseFirestore.instance.collection('pessoas').add({
        'nome': nome,
        'idade': idade,
        'estadoCivil': estadoCivil,
      });
      _nomeController.clear();
      _idadeController.clear();
      _estadoCivilController.clear();
    }
  }

  Future<void> _removerPessoa(String id) async {
    await FirebaseFirestore.instance.collection('pessoas').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Pessoas'),
        backgroundColor: Colors.green[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Adicionar Nova Pessoa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
                fillColor: Colors.green[50],
                filled: true,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _idadeController,
              decoration: InputDecoration(
                labelText: 'Idade',
                border: OutlineInputBorder(),
                fillColor: Colors.green[50],
                filled: true,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _estadoCivilController,
              decoration: InputDecoration(
                labelText: 'Estado Civil',
                border: OutlineInputBorder(),
                fillColor: Colors.green[50],
                filled: true,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.green[200],
                side: BorderSide(color: Colors.green, width: 2.0), // Adiciona a borda ao botão
              ),
              child: Text('Adicionar'),
              onPressed: () => _adicionarPessoa(
                _nomeController.text,
                _idadeController.text,
                _estadoCivilController.text,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('pessoas').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }

                  final pessoas = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: pessoas.length,
                    itemBuilder: (context, index) {
                      final pessoa = pessoas[index];
                      final nome = pessoa['nome'];
                      final idade = pessoa['idade'];
                      final estadoCivil = pessoa['estadoCivil'];
                      final id = pessoa.id;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Card(
                          color: Colors.green[50],
                          child: ListTile(
                            title: Text(
                              '$nome, $idade anos, $estadoCivil',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal, // Ajusta para uma fonte mais fina
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.green[300]),
                              onPressed: () => _removerPessoa(id),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
