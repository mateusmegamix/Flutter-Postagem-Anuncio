import 'package:flutter/material.dart';
import 'package:megamix/Cadastro_Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home.dart';
import 'model/Usuario.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail =
      TextEditingController(text: "mateusp.1996@gmail.com");
  TextEditingController _controllerSenha =
      TextEditingController(text: "1234567");
  String _mensagemErro = "";

  _validarCampos() {
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty && senha.length > 6) {
        setState(() {
          _mensagemErro = "";
        });

        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        _logarUsuario(usuario);
      } else {
        setState(() {
          _mensagemErro = "*Preencha a senha!";
        });
      }
    }
  }

  _logarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      Navigator.pushReplacementNamed(context, "/home");
    }).catchError((error) {
      setState(() {
        _mensagemErro =
            "*Erro ao autenticar usuário, verifique e-mail e senha e tente novamente";
      });
    });
  }

  Future _verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut();

    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado != null) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verificaUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/fundo2.jpg"), fit: BoxFit.cover)),
        padding: EdgeInsets.only(top: 20, left: 32, right: 32, bottom: 110),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: Stack(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(
                            top: 300, left: 0, right: 0, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            TextField(
                              controller: _controllerEmail,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                //icon: Icon(Icons.person, color: Colors.black),
                                hintText: "E-mail",
                                filled: true,
                                fillColor: Colors.white54,
                                hintStyle: TextStyle(
                                    color: Colors.grey[600], fontSize: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: TextField(
                                controller: _controllerSenha,
                                obscureText: true,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  //icon: Icon(Icons.lock, color: Colors.black),
                                  hintText: "Senha",
                                  filled: true,
                                  fillColor: Colors.white54,
                                  hintStyle: TextStyle(
                                      color: Colors.grey[600], fontSize: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 45, left: 0, right: 0, bottom: 25),
                              child: RaisedButton(
                                  child: Text(
                                    "Entrar",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  color: Colors.green,
                                  padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  onPressed: () {
                                    _validarCampos();
                                  }),
                            ),
                            Center(
                              child: GestureDetector(
                                child: Text(
                                  "Não tem conta? cadastre-se!",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Cadastro_Usuario()));
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Center(
                                child: Text(
                                  _mensagemErro,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 20),
                                ),
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
