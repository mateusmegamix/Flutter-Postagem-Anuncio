import 'dart:io';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/Anuncio.dart';

class Detalhes extends StatefulWidget {

  Anuncio anuncio;
  Detalhes(this.anuncio);

  @override
  _DetalhesState createState() => _DetalhesState();
}

class _DetalhesState extends State<Detalhes> {

  Anuncio _anuncio;

  List<Widget> _getListaImagens(){

    List<String> listaUrlImagens = _anuncio.fotos;
    return listaUrlImagens.map((url){
      return Container(
        height: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.fitWidth
          )
        ),
      );
    }).toList();
  }

  _ligarTelefone(String telefone) async{
    if(await canLaunch("tel:$telefone")){
      await launch("tel:$telefone");
    }else{
      print("Não é possivel fazer a ligação");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _anuncio = widget.anuncio;
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
              "Produto",
              style: TextStyle(color: Colors.white, fontSize: 20),
            )
          ],
        ),
        elevation: Platform.isIOS ? 0 : 4,
        backgroundColor: Colors.green[700],
      ),
      body: Stack(children: <Widget>[

        ListView(children: <Widget>[
          SizedBox(
            height: 250,
            child: Carousel(
              images: _getListaImagens(),
              dotSize: 8,
              dotBgColor: Colors.transparent,
              dotColor: Colors.white,
              autoplay: false,
              dotIncreasedColor: Colors.green[700],
            ),
          ),

          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text(
                "R\$ ${_anuncio.preco}",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700]
                ),
              ),

              Text(
                "${_anuncio.titulo}",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w400
                ),
              ),

              Padding(
               padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),

              Text(
                "Descrição",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "${_anuncio.descricao}",
                style: TextStyle(
                  fontSize: 18
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),

              Text(
                "Contato",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 66),
                child: Text(
                  "${_anuncio.telefone}",
                  style: TextStyle(
                      fontSize: 18
                  ),
                ),
              ),

            ],),
          ),

        ],),

        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: GestureDetector(
            child: Container(
              child: Text("Ligar", style: TextStyle(fontSize: 18, color: Colors.white),),
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(32)
              ),
            ),

           onTap: (){
            _ligarTelefone(_anuncio.telefone);
          },
          ),
        ),

      ],),
    );
  }
}
