import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

const URL_REQUEST = "https://api.hgbrasil.com/finance?format=json-cors&key=1fa7f390";

void main() async {

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData( //define um tema para toda a aplicação
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
  ));
}

Future<Map> getData() async {
    http.Response response = await http.get(URL_REQUEST); //realiza a requisição ao servidor (awai = indica que deve aguardar o retorno e atribuir ao objeto response)
    //print(json.decode(response.body)["results"]["currencies"]["USD"]); //os valores dentro dos colchetes indicam as chaves da árvore json que desejo printar
    return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  //chamada quando mudar o valor do real
  void _realChanged(String text){
    _fieldIsEmpty(text);
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);//duas casas decimais
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    _fieldIsEmpty(text);
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    _fieldIsEmpty(text);
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";  
    dolarController.text = "";
    euroController.text = "";  
  }

  //verifica se o campo está vazio, se sim, chama o clearAll
  void _fieldIsEmpty(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar( //detalhe da barra
        title: Text("\$ Conversor \$"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),

      body: FutureBuilder<Map>( //futurebuilder<tipo map> enquanto estiver obtendo os dados, exibe na tela que está carregando os dados
        future: getData(),//informa qual o futuro que desejo construir, no caso, o método de requisição 
        //snapshot é a cópia dos dados obtidos do servidor
        builder: (context, snapshot){ //o build informa que o conteúdo da tela vai ser formado pelo retorno do getData
          //mostra o dado na tela de acordo com o status da conexão
          switch(snapshot.connectionState){ //verifica os status da conexão
            case ConnectionState.none://se não estiver conectado
            case ConnectionState.waiting://ou se o status da conexão for aguardando
              return Center(//center é um widget que centraliza outro widget
                child: Text("Carregando dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center)
              );
            default: //caso tenha obtido alguma coisa
              if(snapshot.hasError){ //se tem algum erro retorna o widget retorna um texto centralizado informando
                return Center(//center é um widget que centraliza outro widget
                  child: Text("Erro ao carregar dados!",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center)
                );
              } else {

                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                      buildTextFild("Reais", "R\$", realController, _realChanged),
                      Divider(), //é um divisor para separar os campos
                      buildTextFild("Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextFild("Euros", "€\$", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),     
    );
  }
}

Widget buildTextFild(String label, String prefix, TextEditingController controller, Function function){
  return TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.amber),
            border: OutlineInputBorder(), //insere uma borda envolvendo o campo
            prefixText: prefix
          ),
          style: TextStyle(color: Colors.amber, fontSize: 25.0),
          onChanged: function,//sempre que houver alguma alteração nos campos, chama a função de alterar os valores 
          keyboardType: TextInputType.number,
        );
}