import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=8f9908d7";

void main() async {

//  http.Response response = await http.get(request);
//  double valorBTCCompra = json.decode(response.body)["results"]["currencies"]["BTC"]["buy"];
//  double valorBTCVenda = json.decode(response.body)["results"]["currencies"]["BTC"]["sell"];
//
//  print(json.decode(response.body)["results"]["currencies"]["BTC"]["buy"]);
//  print("BTC Compra: ${valorBTCCompra} - BTC Venda: ${valorBTCVenda}");

  
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle:
          TextStyle(color: Colors.amber),
      )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
       future: getData(),
       builder: (context, snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Text("Carregando Dados...",
                style: TextStyle(
                color: Colors.amber,
                fontSize: 25.0),
              textAlign: TextAlign.center,)
            );
          default:
            if(snapshot.hasError) {
              return Center(
                  child: Text("Erro ao Carregar Dados :(",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0),
                    textAlign: TextAlign.center,)
              );
            }
            else {
              dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
              euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

              return SingleChildScrollView(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(Icons.monetization_on, size: 130.0, color: Colors.amber),
                    buildTextField("Reais", "R\$", realController, _realChanged),
                    Divider(),
                    buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                    Divider(),
                    buildTextField("Euros", "\$", euroController, _euroChanged),
                    Divider(),
                  ],
                ),
              );
            }
        }
       })
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 25.0
    ),
    onChanged: function,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

Future<Map> getData() async{
  http.Response response = await http.get(request);
  return json.decode(response.body);
}