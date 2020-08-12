import 'package:brasil_fields/modelos/estados.dart';
import 'package:flutter/material.dart';

class Config {

  static List<DropdownMenuItem<String>> getEstados(){
    List<DropdownMenuItem<String>> listaItensDropEstados = [];

    listaItensDropEstados.add(
        DropdownMenuItem(child: Text(
          "Região", style: TextStyle(color: Colors.green),
        ), value: null)
    );

    for(var estado in Estados.listaEstadosAbrv){
      listaItensDropEstados.add(
          DropdownMenuItem(child: Text(estado), value: estado,)
      );
    }

    return listaItensDropEstados;
  }

  static List<DropdownMenuItem<String>> getCategorias(){
    List<DropdownMenuItem<String>> itensDropCategorias = [];

    itensDropCategorias.add(
        DropdownMenuItem(child: Text(
          "Categoria", style: TextStyle(color: Colors.green),
        ), value: null)
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Bolo"), value: "Bolo")
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Sopa"), value: "Sopa")
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Salada"), value: "Salada")
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Doce"), value: "Doce")
    );

    itensDropCategorias.add(
        DropdownMenuItem(child: Text("Salgado"), value: "Salgado")
    );

    return itensDropCategorias;
  }
}