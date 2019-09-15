import 'dart:convert'; //json
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pesquisa_gifs/view/gif_page.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;//conteúdo a ser pesquisado
  int _offSet = 0;//valor da quantidade de resultados da próxima página de exibição
  String _URL_INITIAL_API = "https://api.giphy.com/v1/gifs/trending?api_key=pFTRC7wzWO3Ac9nQXQ2ycnxA5o1UKa29&limit=20&rating=G";
  
  //método para buscar os gifs
  Future<Map>_getGifs() async {
    http.Response response;

    //primeira busca, quando o app abre e nada foi digitado ainda para a busca
    if(_search == null || _search.isEmpty)
      response = await http.get(_URL_INITIAL_API);
    else { //caso haja algo digitado
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=pFTRC7wzWO3Ac9nQXQ2ycnxA5o1UKa29&q=$_search&limit=19&offset=$_offSet&rating=G&lang=pt");
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getGifs().then((map){
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),//o título será uma imagem da web
        centerTitle: true,
      ),
      backgroundColor: Colors.black,

      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise aqui",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)
                ),
              ),
          
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text){//quando clicar no ícone do teclado, seta o valor digitado no _search
                setState(() {
                  _search = text;
                  //sempre que for fazer uma nova pesquisa/busca, reseta a quantidade de itens a ser buscado, pois ele sempre é incrementado no botão carregar mais para trazer novos resultados, assim sendo, evitará bugs
                  _offSet = 0;
                });
                /*pega o texto que foi digitado e atualiza o status da tela
                  quando isso correr, chama o future builder e faz uma nova requisição a api dos gifs
                  informando o que será pesquisado
                */
              },
            ),
          ),
          //o conteúdo com os gifs ocupa todo o espaço restante da coluna, assim sendo, ele ficará dentro do expanded para 'saber' o espaço que irá ocupar
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),//conteúdo do future são os gifs
              builder: (context, snapshot){//função que vai criar o layout dependendo do status do future
                switch(snapshot.connectionState){
                  case ConnectionState.waiting: // casso está esperando ou sem carregar nada
                  case ConnectionState.none: //mostra um indicator para mostrar que tem algo sendo carregado
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );

                  default: 
                    if(snapshot.hasError) return Container();
                    else return _createGifTable(context, snapshot);
                }
              }
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data){
    //quando não estiver pesquisando nada, não deixa o espaço de uma imagem no final (opção de pesquisar mais)
    if(_search == null){
      return data.length;
    }else {
      return data.length + 1;//caso contrário, cria mais um espaço para colocar o ícone de carregar mais
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //quantidade de colunas que o gride pode ter
        crossAxisSpacing: 10.0, //espaçamento dos itens na horizontal
        mainAxisSpacing: 10.0
      ),
      itemCount: _getCount(snapshot.data["data"]),//quantidade de gifs na tela
      itemBuilder: (context, index){ //retorna o item que vai ser colocado em cada posição (constro o grid gif por gif)

          //se não tiver pesquisando, retorna a imagem, ou se tiver pesquisando, e o item não é o último
          if(_search == null || index < snapshot.data["data"].length) {
            
            return GestureDetector(//retorna a imagem a ser construída ou o ícone (exibido quando o ususário estiver pesquisando)
              child: FadeInImage.memoryNetwork(//FadeInImage faz com que as imagens carregem de forma mais amigáveis
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: (){// Ao tocar na imagem, 
                Navigator.push(context, //cria uma rota entre as páginas
                  MaterialPageRoute( //GifPage é a nova tela que irá ser chamada no toque do gif
                    builder: (context) => GifPage(snapshot.data["data"][index]))
                );
              },
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
              },
            );
          } else {//caso contrário, mostra o botão de carregar mais
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70.0,),
                    Text("Carregar mais...", 
                      style: TextStyle(
                        color: Colors.white, fontSize: 22.0,
                      ),
                    )
                  ],
                ),
                onTap: (){//quando o usuário clicar no carregar mais
                  setState(() {
                    _offSet += 19;//soma mais 19 na quantidade de gifs que deverão ser carregados a cada busca
                  });
                },
              ),
            );
          }
      }
    ); 
  }
}