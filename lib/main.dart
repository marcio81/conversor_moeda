import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=5ca21b79";

void main() async {
  //função asincrona para não travar o app
  //print(await getData());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(15),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(15),
        ),
        labelStyle: TextStyle(color: Colors.amber),
        hintStyle: TextStyle(color: Colors.white),
        prefixStyle: TextStyle(color: Colors.amber, fontSize: 25),
      ),
    ),
  ));
}

Future<Map> getData() async {
  // solicita os dados
  http.Response response =
      await http.get(request); // o await é pra esperar a resposta.
  return json.decode(response.body);
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
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
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
            future: getData(), // retorna o futuro
            builder: (context, snapshot) {
              //o que elel vai mostrar em cada caso
              switch (snapshot.connectionState) {
                //pra informar o status da conecção
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      "Carregando os dados...",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Erro ao carregar dados...",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 150.0,
                            color: Colors.amber,
                          ),
                          Divider(),
                          buildTextFild(
                              "Reais", "R\$", realController, _realChanged),
                          Divider(),
                          buildTextFild(
                              "Dólar", "US\$", dolarController, _dolarChanged),
                          Divider(),
                          buildTextFild(
                              "Euro", "€", euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextFild(
    String label, String prefix, TextEditingController c, Function change) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    onChanged: change,
    keyboardType: TextInputType.number,
  );
}
