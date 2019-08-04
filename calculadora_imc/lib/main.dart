import 'package:flutter/material.dart';

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

  //controladores para receber os valores digitados nos campos de peso e altura
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  //objeto que permite a validação dos fields do formulário
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _info = "Informe seus dados!";

  void _resetFields(){
      //o texteditingcontroler não necessita estar dentro do setstate, pois ele se redesenha na tela sempre que houver uma alteração
      weightController.text = "";
      heightController.text = "";
      setState(() {
        _info = "Informe seus dados!";
        _formKey = GlobalKey<FormState>();//reseta também as informações do formulário, como informações de erro se houverem
      });
  }

  void _calculate(){
    setState(() {
      double weight = double.parse(weightController.text);
      double height = double.parse(heightController.text) / 100; //altura em metros
      double imc = weight / (height * height);

      if (imc < 18.6){
        _info = "Abaixo do peso (${imc.toStringAsPrecision(2)})!";
      } else if (imc >= 18.6 && imc < 24.9) {
        _info = "Peso ideal (${imc.toStringAsPrecision(2)})!";
      } else if (imc >= 24.9 && imc < 29.9) {
        _info = "Levemente acima do peso (${imc.toStringAsPrecision(2)})!";
      } else if (imc >= 29.9 && imc < 34.9) {
        _info = "Obesidade grau 1 (${imc.toStringAsPrecision(2)})!";
      } else if (imc >= 34.9 && imc < 39.9) {
        _info = "Obesidade grau 2 (${imc.toStringAsPrecision(2)})!";
      } else {
        _info = "Obesidade grau 3 (${imc.toStringAsPrecision(2)})!";
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //menu com barras
      appBar: AppBar(
        title: Text("Calculadora de IMC"),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[//todas as ações devem ficar aqui
          IconButton(
            icon: Icon(Icons.refresh),//escolhe o ícone
            onPressed: _resetFields
          )
        ],
      ),

      backgroundColor: Colors.white, //cor de bundo da aplicação
      body: SingleChildScrollView(   //é um scrollview de apenas um filho
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0), //enchimentos da tela para não ficar com as bordas coladas
        child: Form(  //cria o formulário 
          key: _formKey,
          child: Column(               //inserir o conteúdo da coluna dentro do scrollview para qur 
                                     //seja possível rolar a tela quando o teclado for exibido e evitar erros na exibição  (aula 45 4 minutos)
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.person_outline, size: 120.0, color: Colors.red),
              TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Peso (kg)",
                    labelStyle: TextStyle(color:  Colors.red)),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 25.0),
                  controller: weightController, //informa quem irá controlar o valor digitado para peso
                  validator: (value){ //o validator chamar uma função anônima informando o valor digitado
                    if(value.isEmpty){
                      return "Insira seu peso!";
                    }
                  },
              ), 
              TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Altura (cm)",
                    labelStyle: TextStyle(color:  Colors.red)),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 25.0),
                  controller: heightController,
                  validator: (value){
                    if(value.isEmpty){
                      return "Insira sua altura!";
                    }
                  },
              ),
              Padding(
                padding: EdgeInsets.only(top:10.0, bottom: 10.0),
                child: Container(
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: (){ 
                      //se algo for digitado, calcula o imc
                      if(_formKey.currentState.validate()){
                        _calculate();
                      }
                    },
                    child: Text("Calcular", 
                      style:  TextStyle(color: Colors.white, fontSize: 25.0),),
                    color: Colors.red,
                ),
                )
              ),
              Text(_info,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 25.0),)
            ],
          ),
        ),
      )
    );
  }
}