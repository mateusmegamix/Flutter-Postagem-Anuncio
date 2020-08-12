import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megamix/model/Anuncio.dart';
import 'package:megamix/widgets/ItemAnuncio.dart';


class MeusProdutos extends StatefulWidget {
  @override
  _MeusProdutosState createState() => _MeusProdutosState();
}

class _MeusProdutosState extends State<MeusProdutos> {

  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _idUsuarioLogado;

  _recuperaDadosUsuarioLogado() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {

    await _recuperaDadosUsuarioLogado();

    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .document( _idUsuarioLogado )
        .collection("anuncios")
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
    });

  }

  _removerAnuncio(String idAnuncio){

    Firestore db = Firestore.instance;
    db.collection("meus_anuncios")
        .document( _idUsuarioLogado )
        .collection("anuncios")
        .document( idAnuncio )
        .delete().then((_){


          db.collection("anuncios")
              .document(idAnuncio)
              .delete();
    });

  }

  List<String> itensMenu = ["Meus Produtos", "Bloco de Notas", "Configurações", "Deslogar"];

  _escolhaMenuItem(String itemEscolhido) {
    //print("Item escolhido: " + itemEscolhido);

    switch (itemEscolhido) {
      case "Bloco de Notas":
        Navigator.pushNamed(context, "/notas");
        break;
      case "Configurações":
        Navigator.pushNamed(context, "/configuracoes");
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;
    }
  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
  }

  Future _verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut();

    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado == null) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verificaUsuarioLogado();
    _recuperaDadosUsuarioLogado();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {

    var carregandoDados = Center(
      child: Column(children: <Widget>[
        Text("Carregando produtos"),
        CircularProgressIndicator()
      ],),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Image.asset(
              "imagens/vegan.png",
              color: Colors.white,
              width: 60,
              height: 100,
            ),
            Text("Meus Proudtos", style: TextStyle(color: Colors.white, fontSize: 20),)
          ],
        ),
        elevation: Platform.isIOS ? 0 : 4,
        backgroundColor: Colors.green[700],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
          icon: Icon(Icons.add),
          label: Text("Adicionar"),
          onPressed: (){

            Navigator.pushNamedAndRemoveUntil(context, "/produtos", (_) => false);

          }),
      body: StreamBuilder(
          stream: _controller.stream,
          builder: (context, snapshot){

            switch( snapshot.connectionState ){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return carregandoDados;
                break;
              case ConnectionState.active:
              case ConnectionState.done:

                if(snapshot.hasError)
                  return Text("Erro ao carregar os dados!");

                QuerySnapshot querySnapshot = snapshot.data;

                return ListView.builder(
                  itemCount: querySnapshot.documents.length,
                  itemBuilder: (_, indice){

                    List<DocumentSnapshot> anuncios = querySnapshot.documents.toList();
                    DocumentSnapshot documentSnapshot = anuncios[indice];
                    Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                    return ItemAnuncio(
                      anuncio: anuncio,
                      onPressedRemover:(){
                        showDialog(
                            context: context,
                          builder: (context){
                              return AlertDialog(
                                title: Text("Confirmar"),
                                content: Text("Deseja realmente excluir o anúncio?"),
                                actions: <Widget>[

                                  FlatButton(
                                    child: Text(
                                      "Cancelar",
                                      style: TextStyle(
                                        color: Colors.grey
                                      ),
                                    ),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  ),

                                  FlatButton(
                                    child: Text(
                                      "Remover",
                                      style: TextStyle(
                                          color: Colors.red
                                      ),
                                    ),
                                    onPressed: (){
                                      _removerAnuncio(anuncio.id);
                                      Navigator.of(context).pop();
                                    },
                                  ),

                                ],
                              );
                          }
                        );
                      },
                    );
                  },
                );
            }
            return Container();
          },
      )
    );
  }
}
