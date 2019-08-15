import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: Home(),
  )); 
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _todoList = [];//irá armazenar as tarefas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),

      body: Column(
        children: <Widget>[
          Container( //para poder inserir o espaçamento
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded( //permite que o campo se expanda até onde puder sem sobrescrever o botão add
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent)
                    ),
                  ),
                ),

                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("Adicionar"),
                  textColor: Colors.white,
                  onPressed: (){},
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

    //método para retornar o diretório do arquivo json que irá armazenar os dados do app
  Future<File> _getFile() async {
    //pega o diretório onde pode armazenar os documentos do app (não é executado instantaneamente 'retorna um future')
    final DIRECTORY = await getApplicationDocumentsDirectory();
    //informa o caminho (path) do diretório +/data.json e abre o arquivo (file)
    return File("${DIRECTORY.path}/data.json");
  }

  Future<File> _saveData() async {
    //data é o dado que quero salvar
    String data = json.encode(_todoList);
    final file = await _getFile(); //pega o arquivo json
    return file.writeAsString(data);//escreve os dados no arquivo
  }

  Future<String> _readData() async {
    try{
      final file = await _getFile();
      return file.readAsString();//lẽ os dados como string
    } catch(erro){
      return null;
    }
  }
}