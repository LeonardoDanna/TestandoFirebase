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
        primarySwatch: Colors.blue,
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: _idadeController,
                  decoration: InputDecoration(labelText: 'Idade'),
                ),
                TextField(
                  controller: _estadoCivilController,
                  decoration: InputDecoration(labelText: 'Estado Civil'),
                ),
                ElevatedButton(
                  child: Text('Adicionar'),
                  onPressed: () => _adicionarPessoa(
                    _nomeController.text,
                    _idadeController.text,
                    _estadoCivilController.text,
                  ),
                ),
              ],
            ),
          ),
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

                    return ListTile(
                      title: Text('$nome, $idade anos, $estadoCivil'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removerPessoa(id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
