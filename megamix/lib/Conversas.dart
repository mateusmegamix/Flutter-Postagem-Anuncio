import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megamix/model/Conversa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/Usuario.dart';

class Conversas extends StatefulWidget {
  @override
  _ConversasState createState() => _ConversasState();
}

class _ConversasState extends State<Conversas> {

  List<Conversa> _listaConversas = List();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;
  String _idUsuarioLogado;
  String _emailUsuarioLogado;

  Stream<QuerySnapshot> _adicionarListenerConversas() {
    final stream = db
        .collection("conversas")
        .document(_idUsuarioLogado)
        .collection("ultima_conversa")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
    _emailUsuarioLogado = usuarioLogado.email;

    _adicionarListenerConversas();
  }

  int _indiceAtual = 1;
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

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
    _verificaUsuarioLogado();
    _recuperarContatos();

    Conversa conversa = Conversa();
    conversa.nome = "Ana Clara";
    conversa.mensagem = "Olá tudo bem?";
    conversa.caminhoFoto =
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-36cd8.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=97a6dbed-2ede-4d14-909f-9fe95df60e30";

    _listaConversas.add(conversa);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
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
              "Mensagens",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("Carregando conversas"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text("Erro ao carregar os dados!");
              } else {
                QuerySnapshot querySnapshot = snapshot.data;

                if (querySnapshot.documents.length == 0) {
                  return Center(
                    child: Text(
                      "Você não tem nenhuma mensagem ainda :( ",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                return ListView.builder(
                    itemCount: _listaConversas.length,
                    itemBuilder: (context, indice) {
                      List<DocumentSnapshot> conversas =
                          querySnapshot.documents.toList();
                      DocumentSnapshot item = conversas[indice];

                      String urlImagem = item["caminhoFoto"];
                      String tipo = item["tipoMensagem"];
                      String mensagem = item["mensagem"];
                      String nome = item["nome"];
                      String idDestinatario = item["idDestinatario"];

                      Usuario usuario = Usuario();
                      usuario.nome = nome;
                      usuario.urlImagem = urlImagem;
                      usuario.idUsuario = idDestinatario;

                      return ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, "/mensagens",
                              arguments: usuario);
                        },
                        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: urlImagem != null
                              ? NetworkImage(urlImagem)
                              : null,
                        ),
                        title: Text(
                          nome,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(tipo == "texto" ? mensagem : "Imagem...",
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                      );
                    });
              }
          }
          return Container();
        },
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
