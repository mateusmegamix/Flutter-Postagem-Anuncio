import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Conversas.dart';
import 'Home.dart';
import 'Login.dart';
import 'Notas.dart';
import 'model/Conversa.dart';
import 'model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Contatos extends StatefulWidget {
  @override
  _ContatosState createState() => _ContatosState();
}

class _ContatosState extends State<Contatos> {
  int _indiceAtual = 2;

  //Menu
  List<String> itensMenu = ["Meus Produtos", "Bloco de Notas", "Configurações", "Deslogar"];

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

  //Validar para não mandar mensagens para si mesmo
  String _idUsuarioLogado;
  String _emailUsuarioLogado;

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
    _emailUsuarioLogado = usuarioLogado.email;
  }

  Future<List<Usuario>> _recuperarContatos() async {
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot =
        await db.collection("usuarios").getDocuments();

    List<Usuario> listaUsuarios = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var dados = item.data;
      if (dados["email"] == _emailUsuarioLogado) continue;

      Usuario usuario = Usuario();
      usuario.idUsuario = item.documentID;
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];
      usuario.urlImagem = dados["urlImagem"];

      listaUsuarios.add(usuario);
    }

    return listaUsuarios;
  }

  Future _verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;

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
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Row(
          children: <Widget>[
            Image.asset(
              "imagens/vegan.png",
              color: Colors.white,
              width: 60,
              height: 100,
            ),
            Text("Contatos", style: TextStyle(color: Colors.white, fontSize: 20),)
          ],
        ) ,
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
          child: FutureBuilder<List<Usuario>>(
        future: _recuperarContatos(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("Carregando contatos"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, indice) {
                    List<Usuario> listaItens = snapshot.data;
                    Usuario usuario = listaItens[indice];

                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, "/mensagens",
                            arguments: usuario);
                      },
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: usuario.urlImagem != null
                              ? NetworkImage(usuario.urlImagem)
                              : null),
                      title: Text(
                        usuario.nome,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    );
                  });
              break;
          }
        },
      )),
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
