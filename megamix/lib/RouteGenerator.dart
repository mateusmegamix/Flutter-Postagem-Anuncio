import 'package:flutter/material.dart';
import 'Cadastro_Usuario.dart';
import 'Configuracoes.dart';
import 'Contatos.dart';
import 'Conversas.dart';
import 'Detalhes.dart';
import 'Home.dart';
import 'Login.dart';
import 'Mensagens.dart';
import 'MeusProdutos.dart';
import 'Notas.dart';
import 'Produtos.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Login());
      case "/login":
        return MaterialPageRoute(builder: (_) => Login());
      case "/usuario":
        return MaterialPageRoute(builder: (_) => Cadastro_Usuario());
      case "/home":
        return MaterialPageRoute(builder: (_) => Home());
      case "/conversas":
        return MaterialPageRoute(builder: (_) => Conversas());
      case "/contatos":
        return MaterialPageRoute(builder: (_) => Contatos());
      case "/notas":
        return MaterialPageRoute(builder: (_) => Notas());
      case "/configuracoes":
        return MaterialPageRoute(builder: (_) => Configuracoes());
      case "/produtos":
        return MaterialPageRoute(builder: (_) => Produto());
      case "/meusprodutos":
        return MaterialPageRoute(builder: (_) => MeusProdutos());
      case "/detalhes":
        return MaterialPageRoute(builder: (_) => Detalhes(args));
      case "/mensagens":
        return MaterialPageRoute(builder: (_) => Mensagens(args));

      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada"),
        ),
        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}
