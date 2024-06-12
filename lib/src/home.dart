import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Contato {
  int id;
  String nome;
  String email;
  String numero;

  Contato({
    required this.id,
    required this.nome,
    required this.email,
    required this.numero,
  });

  factory Contato.fromJson(Map<String, dynamic> json) {
    return Contato(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      numero: json['numero'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'numero': numero,
    };
  }
}

class ListaContato extends StatefulWidget {
  @override
  _ListaContatoState createState() => _ListaContatoState();
}

class _ListaContatoState extends State<ListaContato> {
  List<Contato> contatos = [];
  TextEditingController nomeControle = TextEditingController();
  TextEditingController numeroControle = TextEditingController();
  TextEditingController emailControle = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/contatos'),
    );

    if (response.statusCode == 200) {
      setState(() {
        Iterable list = json.decode(response.body);
        contatos = list.map((model) => Contato.fromJson(model)).toList();
      });
    } else {
      throw Exception('Falha ao carregar contatos');
    }
  }

  Future<void> _criarContato(Contato contato) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/contatos/novo'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(contato.toJson()),
    );

    if (response.statusCode == 200) {
      _carregarDados();
    } else {
      throw Exception('Falha ao criar contato');
    }
  }

  Future<void> _atualizarContato(Contato contato) async {
    final response = await http.put(
      Uri.parse('http://127.0.0.1:5000/contatos/editar/${contato.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(contato.toJson()),
    );

    if (response.statusCode == 200) {
      _carregarDados();
    } else {
      throw Exception('Falha ao atualizar contato');
    }
  }

  Future<void> _deletarContato(int id) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:5000/contatos/delete/$id'),
    );

    if (response.statusCode == 200) {
      _carregarDados();
    } else {
      throw Exception('Falha ao deletar contato');
    }
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir este contato?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletarContato(id);
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Expanded(
              child: Text('Lista de Contatos'),
            ),
            FloatingActionButton(
              onPressed: () => _showAddDialog(context),
              child: Icon(Icons.add),
              backgroundColor: Colors.cyanAccent,
              mini: true,
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: contatos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contatos[index].nome,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16),
                    SizedBox(width: 8),
                    Text(contatos[index].numero),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.email, size: 16),
                    SizedBox(width: 8),
                    Text(contatos[index].email),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context, contatos[index]),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _showDeleteDialog(context, contatos[index].id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeControle,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: numeroControle,
                decoration: InputDecoration(labelText: 'Número'),
              ),
              TextField(
                controller: emailControle,
                decoration: InputDecoration(labelText: 'E-mail'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final novoContato = Contato(
                  id: 0, // Id será definido pelo servidor
                  nome: nomeControle.text,
                  numero: numeroControle.text,
                  email: emailControle.text,
                );
                _criarContato(novoContato);
                nomeControle.clear();
                numeroControle.clear();
                emailControle.clear();
                Navigator.pop(context);
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Contato contato) {
    nomeControle.text = contato.nome;
    numeroControle.text = contato.numero;
    emailControle.text = contato.email;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar contato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeControle,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: numeroControle,
                decoration: InputDecoration(labelText: 'Número'),
              ),
              TextField(
                controller: emailControle,
                decoration: InputDecoration(labelText: 'E-mail'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final contatoAtualizado = Contato(
                  id: contato.id,
                  nome: nomeControle.text,
                  numero: numeroControle.text,
                  email: emailControle.text,
                );
                _atualizarContato(contatoAtualizado);
                nomeControle.clear();
                numeroControle.clear();
                emailControle.clear();
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}