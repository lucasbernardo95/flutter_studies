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

  final _todoController = TextEditingController();

  List _todoList = [];//irá armazenar as tarefas

  Map<String, dynamic> _lastRemoved = Map();//armazena o último elemento removido
  int _indexLastRemoved; //índice do último elemento removido

  //método que é chamado sempre que o widget é iniciado
  @override
  void initState(){
    super.initState();
    _readData().then((data){//chama o readData e, quando ele carregar os dados, chama a função anônima passando o retorno (data) do readData
      setState(() {
        _todoList = json.decode(data);//converte o conteúdo da string para lista
      });
    });
  }

  //adiciona uma tarefa
  void _addAssignment(){
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _todoController.text;
      _todoController.text = "";//limpa o texto digitado no textfield
      newTodo["ok"] = false;//nova tarefa é iniciado como false
      _todoList.add(newTodo);

      _saveData();//salva o conteúdo da lista no arquivo
    });
  }

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
                    controller: _todoController,
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
                  onPressed: _addAssignment,
                )
              ],
            ),
          ),
          //conteúdo da lista
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(//listview assim como no android nativo,  os elementos escondidos não serão renderizados
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _todoList.length,
                itemBuilder: buildItem, //para cada item da lista chama o builditem,
              ),
            ),
          )
        ],
      ),
    );
  }
  //como a função está sendo chamada no build o método sabe qual o context e o index
  //mas, caso fosse necessário, ao invéz de informar os parâmetros assim: Widget buildItem(context, index)
  //poderia especificar manualmente assim:(BuildContext context, int index)
  Widget buildItem(context, index){

    //obs: caso não fosse especificado a direção, poderia arrastar para qualquer direção
    return Dismissible(//componente que permite que arraste o elemento para a direita para poder excluir
      key: Key(//identificador do elemento que está sendo deslizado na tela
        DateTime.now().millisecondsSinceEpoch.toString() //pega o tempo atual em milissegundos 
      ),
      background: Container(
        color: Colors.red,//quando deslizar a tela, fica vermelho
        child: Align(//mostra o ícone da lixeira indicando que o elemento está sendo deletado
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd, //direção da esquerda para a direita
      //indica o filho, em quem que vou dar o dismissible (quem que vou deslizar)
      child: CheckboxListTile(//tipo de ListTil que contém um checkbox
        title: Text(_todoList[index]["title"]),
        value: _todoList[index]["ok"],
        secondary: CircleAvatar( //desenha um avata (uma espécie de icone) que vai varear indicando se a tarefa foi concluída ou não
          child: //se marcado, desenha o ícone do check
            Icon(_todoList[index]["ok"] ? 
            Icons.check : Icons.error),
        ),
        onChanged: (check){//quando houver uma alteração , insere o valor do checkbox na lista
          setState(() {
            _todoList[index]["ok"] = check;
            _saveData();//atualiza o valor no arquivo
          }); 
        },
      ),
      //chamado sempre que um item for arrastado para a direita
      onDismissed: (direction){ //a única direao que foi informada acima foi a  DismissDirection.startToEnd
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);//recupera o índice do item que está sendo removido    
          _indexLastRemoved = index; //salva o índice
          _todoList.removeAt(index);//remove o elemento na posição informada    

          _saveData();//grava a moodificação

          final snackBar = SnackBar(
            content: Text("Tarefa ${_lastRemoved["title"]} removida."),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  _todoList.insert(_indexLastRemoved, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 3),
          );

          Scaffold.of(context).removeCurrentSnackBar();  //faz com que a snackbar atual seja removida antes de mostrar uma nova, evitando uma pilha de snackbar
          Scaffold.of(context).showSnackBar(snackBar);
        });
      },
    );
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration( seconds: 1));//espera um segundo

    //ordena a lista fazendo com que as tarefas não concluídas fiquem acima das concluídas
    /**
     * retorna um número positivo se atual > proximo
     * 0 se atual = proximo
     * e um número negativo se atual > proximo
     */
    setState(() {
      _todoList.sort((atual, proximo){ //os parâmetros são maps
        if(atual["ok"] && !proximo["ok"]) return 1;
        else if(!atual["ok"] && proximo["ok"]) return -1;
        else return 0;
        _saveData();//salva a alteração
      });
    });

    return null;
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