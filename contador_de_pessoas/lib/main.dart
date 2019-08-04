import 'package:flutter/material.dart'; //import do material designer

void main() {
    //executa o app
    runApp(MaterialApp( //poderia ser new Material. o app é do tipo Material Designer, então cria um novo objeto do tipo
      title: "Contador de pessoas", // título do app
      home: 
       Home() //Classe que contém os elementos a serem mostrados na tela
    ));
}

//o widget state full é um state que permite que seu estado seja alterado
//assim, será possível alterar os dados da strings da tela
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  int _people = 0;
  void _changePeople(int delta){
    //seta o novo estádo da tela, alterando somente onde houve alguma modificação
    setState(() {
      _people += delta;
    });    
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          Image.asset(
            "images/restaurant.jpg",
            fit: BoxFit.cover, //a imagem vai cobrir toda a tela
            height: 1000.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Pessoas: $_people", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: 
                    FlatButton(
                      child: Text(
                        "+1", 
                        style: TextStyle(fontSize: 40.0, color: Colors.white),
                      ),
                      onPressed: (){_changePeople(1);}, //função chamada quando o botão é clicado
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: 
                    FlatButton(
                      child: Text(
                        "-1", 
                        style: TextStyle(fontSize: 40.0, color: Colors.white),
                      ),
                      onPressed: (){_changePeople(-1);}, //função chamada quando o botão é clicado
                    ),
                  ),
                ],
              ),
              Text(
                "Pode entrar!", 
                style: TextStyle(color: Colors.white, 
                    fontStyle: FontStyle.italic,
                    fontSize: 30),
              )
            ],
          )
        ],
      );
  }
}