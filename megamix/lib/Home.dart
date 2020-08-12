import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:megamix/util/Config.dart';
import 'package:megamix/widgets/ItemAnuncio.dart';

import 'model/Anuncio.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<DropdownMenuItem<String>> _listaItensDropCategorias;
  List<DropdownMenuItem<String>> _listaItensDropEstados;

  final _controller = StreamController<QuerySnapshot>.broadcast();
  String _itemSelecionadoEstado;
  String _itemSelecionadoCategoria;

  String _emailUsuario = "";

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    setState(() {
      _emailUsuario = usuarioLogado.email;
    });
  }

  List<String> itensMenu = [
    "Meus Produtos",
    "Bloco de Notas",
    "Configurações",
    "Deslogar"
  ];

  _escolhaMenuItem(String itemEscolhido) {
    //print("Item escolhido: " + itemEscolhido);

    switch (itemEscolhido) {
      case "Meus Produtos":
        Navigator.pushNamed(context, "/meusprodutos");
        break;
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

    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado == null) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  _CarregarItensDropdown() {
    _listaItensDropCategorias = Config.getCategorias();

    _listaItensDropEstados = Config.getEstados();
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db.collection("anuncios").snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  Future<Stream<QuerySnapshot>> _filtrarAnuncios() async {
    Firestore db = Firestore.instance;
    Query query = db.collection("anuncios");

    if(_itemSelecionadoEstado != null){
      query = query.where("estado", isEqualTo: _itemSelecionadoEstado);
    }

    if(_itemSelecionadoCategoria != null){
      query = query.where("categoria", isEqualTo: _itemSelecionadoCategoria);
    }

    Stream<QuerySnapshot> stream = query.snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _CarregarItensDropdown();
    _verificaUsuarioLogado();
    _recuperarDadosUsuario();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {

    var carregandodados = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando Produtos"),
          CircularProgressIndicator()
        ],
      ),
    );

    int _indiceAtual = 0;

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
            Text(
              "Aplicativo",
              style: TextStyle(color: Colors.white, fontSize: 20),
            )
          ],
        ),
        elevation: Platform.isIOS ? 0 : 4,
        backgroundColor: Colors.green[700],
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonHideUnderline(
                      child: Center(
                    child: DropdownButton(
                      iconEnabledColor: Colors.green,
                      value: _itemSelecionadoEstado,
                      items: _listaItensDropEstados,
                      style: TextStyle(fontSize: 22, color: Colors.black),
                      onChanged: (estado) {
                        setState(() {
                          _itemSelecionadoEstado = estado;
                          _filtrarAnuncios();
                        });
                      },
                    ),
                  )),
                ),
                Container(
                  color: Colors.grey[200],
                  width: 2,
                  height: 50,
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                      child: Center(
                    child: DropdownButton(
                      iconEnabledColor: Colors.green,
                      value: _itemSelecionadoCategoria,
                      items: _listaItensDropCategorias,
                      style: TextStyle(fontSize: 22, color: Colors.black),
                      onChanged: (categoria) {
                        setState(() {
                          _itemSelecionadoCategoria = categoria;
                          _filtrarAnuncios();
                        });
                      },
                    ),
                  )),
                ),
              ],
            ),
            StreamBuilder(
              stream: _controller.stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return carregandodados;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    QuerySnapshot querySnapshot = snapshot.data;

                    if (querySnapshot.documents.length == 0) {
                      return Container(
                        padding: EdgeInsets.all(25),
                        child: Text(
                          "Nenhum anúncio!",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return Expanded(
                      child: ListView.builder(
                          itemCount: querySnapshot.documents.length,
                          itemBuilder: (_, indice) {
                            List<DocumentSnapshot> anuncios =
                                querySnapshot.documents.toList();
                            DocumentSnapshot documentSnapshot =
                                anuncios[indice];
                            Anuncio anuncio =
                                Anuncio.fromDocumentSnapshot(documentSnapshot);

                            return ItemAnuncio(
                                anuncio: anuncio,
                                onTapItem: () {
                              Navigator.pushNamed(context, "/detalhes", arguments: anuncio);
                            },
                            );
                          }),
                    );
                }
                return Container();
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _indiceAtual,
          onTap: (indice) {
            setState(() {
              _indiceAtual = indice;
            });
            switch (_indiceAtual) {
              case 0:
                Navigator.pushNamedAndRemoveUntil(
                    context, "/home", (_) => false);
                break;
              case 1:
                Navigator.pushNamedAndRemoveUntil(
                    context, "/conversas", (_) => false);
                break;
              case 2:
                Navigator.pushNamedAndRemoveUntil(
                    context, "/contatos", (_) => false);
                break;
              case 3:
                Navigator.pushNamedAndRemoveUntil(
                    context, "/produtos", (_) => false);
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          fixedColor: Colors.green,
          items: [
            BottomNavigationBarItem(
                //backgroundColor: Colors.orange,
                title: Text("Início"),
                icon: Icon(Icons.home)),
            BottomNavigationBarItem(
                //backgroundColor: Colors.red,
                title: Text("Mensagens"),
                icon: Icon(Icons.chat)),
            BottomNavigationBarItem(
                //backgroundColor: Colors.blue,
                title: Text("Contatos"),
                icon: Icon(Icons.contacts)),
            BottomNavigationBarItem(
                //backgroundColor: Colors.green,
                title: Text("Produtos"),
                icon: Icon(Icons.local_florist)),
          ]),
    );
  }
}
