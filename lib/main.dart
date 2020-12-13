import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:lottie/lottie.dart';

const request = "https://api.hgbrasil.com/finance/quotations?key=e3bbe724";

void main() async {
  print(await getData());
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        hintColor: Colors.black,
        primaryColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          hintStyle: TextStyle(color: Colors.black),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _resetFields() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    setState(() {
      _formKey = GlobalKey<FormState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0FFFF),
      appBar: AppBar(
        title:
            Text("Conversor de Moedas", style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            onPressed: _resetFields,
          ),
        ],
        backgroundColor: Color(0xFF00FA9A),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    child: Lottie.asset(
                      'lib/assets/loading_money.json',
                      repeat: true,
                      reverse: true,
                      animate: true,
                    ),
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      child: Lottie.asset(
                        'lib/assets/error.json',
                        repeat: true,
                        reverse: true,
                        animate: true,
                      ),
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 250,
                            height: 250,
                            child: Lottie.asset(
                              'lib/assets/money.json',
                              repeat: true,
                              reverse: true,
                              animate: true,
                            ),
                          ),
                          buildTextField("Real Brasileiro", " R\$: ",
                              realController, _realChanged),
                          Divider(),
                          buildTextField("Dólar Americano", "US\$: ",
                              dolarController, _dolarChanged),
                          Divider(),
                          buildTextField(
                              "Euro", " €: ", euroController, _euroChanged),
                        ]),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController control, Function f) {
  return TextField(
    controller: control,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black, fontSize: 25.0),
        border: OutlineInputBorder(),
        prefixText: prefix,
        prefixStyle: TextStyle(color: Colors.black, fontSize: 20.0)),
    style: TextStyle(color: Colors.black, fontSize: 20.0),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
