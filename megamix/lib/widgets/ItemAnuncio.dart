import 'package:flutter/material.dart';
import 'package:megamix/model/Anuncio.dart';

class ItemAnuncio extends StatelessWidget {

  Anuncio anuncio;
  VoidCallback onTapItem;
  VoidCallback onPressedRemover;

  ItemAnuncio({
    @required this.anuncio,
    this.onTapItem,
    this.onPressedRemover
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTapItem,
      child: Card(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(children: <Widget>[

              SizedBox(
              width: 120,
              height: 120,
              child: Image.network(
                anuncio.fotos[0],
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      anuncio.titulo,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text("R\$ ${anuncio.preco} "),
                  ],),
              ),
            ),
            if( this.onPressedRemover != null) Expanded(
        flex: 1,
        child: FlatButton(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          onPressed: this.onPressedRemover,
          child: Icon(Icons.delete_forever, color: Colors.red,),
        ),
      )
      //botao remover

      ],),)
    ,
    )
    ,
    );
  }
}