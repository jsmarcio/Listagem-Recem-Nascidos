import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de recém nascido',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: ListagemRecemNascidos(),
    );
  }
}

class ListagemRecemNascidos extends StatefulWidget {
  @override
  _ListagemRecemNascidosState createState() => _ListagemRecemNascidosState();
}

class _ListagemRecemNascidosState extends State<ListagemRecemNascidos> {
  List<RecemNascido> _recemNascidos = List();

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text(
          'Listagen de Recém Nascidos',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
      body: ListView.builder(
        itemCount: _recemNascidos.length,
        itemBuilder: (context, index) {
          var item = _recemNascidos[index];
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {},
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  leading: item.verificado
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                      : null,
                  contentPadding: EdgeInsets.all(16.0),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${item.nome}',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    children: <Widget>[
                      Divider(
                        color: Colors.transparent,
                        height: 4,
                      ),
                      Row(
                        children: <Widget>[
                          Text('Data de nascimento: '),
                          VerticalDivider(
                            color: Colors.transparent,
                          ),
                          Text('${item.dataNascimento}'),
                        ],
                      ),
                      Divider(
                        color: Colors.transparent,
                        height: 4,
                      ),
                      Row(
                        children: <Widget>[
                          Text('Local do nascimento: '),
                          VerticalDivider(
                            color: Colors.transparent,
                          ),
                          Text('${item.local}'),
                        ],
                      ),
                      Divider(
                        color: Colors.transparent,
                        height: 4,
                      ),
                      Row(
                        children: <Widget>[
                          Text('Peso: '),
                          VerticalDivider(
                            color: Colors.transparent,
                          ),
                          Text('${item.peso} kg'),
                          VerticalDivider(
                            color: Colors.transparent,
                          ),
                          Text('Altura: '),
                          VerticalDivider(
                            color: Colors.transparent,
                          ),
                          Text('${item.tamanho} cm'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            confirmDismiss: (DismissDirection dismissDirection) async {
              SharedPreferences storage = await SharedPreferences.getInstance();
              switch (dismissDirection) {
                case DismissDirection.endToStart:
                  setState(() {
                    item.verificado = item.verificado ? false : true;
                  });
                  var babyMap = RecemNascido.encode(_recemNascidos);
                  storage.setString('recemNascidos', babyMap);

                  return true;
                case DismissDirection.startToEnd:
                  bool canDelete = await _showConfirmationDialog(context, 'Remover') == true;
                  if (canDelete) {
                    setState(() {
                      _recemNascidos.remove(item);
                    });
                    var babyMap = RecemNascido.encode(_recemNascidos);
                    storage.setString('recemNascidos', babyMap);
                  }
                  return canDelete;
                case DismissDirection.horizontal:
                case DismissDirection.vertical:
                case DismissDirection.up:
                case DismissDirection.down:
                  assert(false);
              }
              return false;
            },
            background: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              color: Colors.redAccent,
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 32.0,
                  ),
                  VerticalDivider(
                    color: Colors.transparent,
                  ),
                  Text(
                    'REMOVER',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
            secondaryBackground: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              color: Colors.green,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32.0,
                  ),
                  VerticalDivider(
                    color: Colors.transparent,
                  ),
                  Text(
                    item.verificado ? 'TIRAR VERIFICAÇÃO' : 'VERIFICAR',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
        onPressed: () {
          Future<RecemNascido> recemNascidoCriado = Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CadastroRecemNascido()),
          );
          recemNascidoCriado.then((rnRecebido) async {
            if(rnRecebido != null){
              SharedPreferences storage = await SharedPreferences.getInstance();

              setState(() {
                _recemNascidos.add(rnRecebido);
              });

              var babyMap = RecemNascido.encode(_recemNascidos);

              storage.setString('recemNascidos', babyMap);
            }
          });
        },
      ),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String action) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tem certeza que deseja $action este item?'),
          actions: <Widget>[
            FlatButton(
              child: const Text(
                'REMOVER',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.pop(context, true); // showDialog() returns true
              },
            ),
            FlatButton(
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.pop(context, false); // showDialog() returns false
              },
            ),
          ],
        );
      },
    );
  }

  void getList() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String listString = storage.getString('recemNascidos');
    setState(() {
      _recemNascidos = RecemNascido.decode(listString);
    });
  }
}

class CadastroRecemNascido extends StatefulWidget {
  @override
  _CadastroRecemNascidoState createState() => _CadastroRecemNascidoState();
}

class _CadastroRecemNascidoState extends State<CadastroRecemNascido> {
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _dataController = TextEditingController();
  TextEditingController _localController = TextEditingController();
  TextEditingController _pesoController = TextEditingController();
  TextEditingController _alturaController = TextEditingController();

  static int _id = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Recém Nascido'),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 32.0,
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            CampoForm(nomeCampo: 'Nome', descCampo: 'João da Silva', controller: _nomeController, type: TextInputType.text),
            CampoForm(nomeCampo: 'Data de Nascimento', descCampo: '10/01/2020', controller: _dataController, type: TextInputType.text),
            CampoForm(nomeCampo: 'Local do nascimento', descCampo:'Hospital São Paulo', controller: _localController, type: TextInputType.text),
            CampoForm(nomeCampo: 'Peso', descCampo:'3.55', controller: _pesoController, type: TextInputType.number),
            CampoForm(nomeCampo: 'Altura', descCampo:'0.52', controller: _alturaController, type: TextInputType.number),
            RaisedButton(
              color: Colors.redAccent,
              onPressed: () async {
                double _peso = double.tryParse(_pesoController.text);
                double _altura = double.tryParse(_alturaController.text);

                _id++;

                RecemNascido baby = RecemNascido(
                    id: _id,
                    nome: _nomeController.text,
                    dataNascimento: _dataController.text,
                    local: _localController.text,
                    peso: _peso,
                    tamanho: _altura,
                    verificado: false);

                Navigator.pop(context, baby);
              },
              child: Text(
                'SALVAR',
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding CampoForm({String nomeCampo, String descCampo, TextEditingController controller, TextInputType type}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(hintText: descCampo, labelText: nomeCampo),
        controller: controller,
        keyboardType: type,
      ),
    );
  }
}

class RecemNascido {
  int id;
  String nome, dataNascimento, local;
  double peso, tamanho;
  bool verificado = false;

  RecemNascido(
      {this.id,
      this.nome,
      this.dataNascimento,
      this.local,
      this.peso,
      this.tamanho,
      this.verificado});

  factory RecemNascido.fromJson(Map<String, dynamic> jsonData) {
    return RecemNascido(
        id: jsonData['id'],
        nome: jsonData['nome'],
        dataNascimento: jsonData['dataNascimento'],
        local: jsonData['local'],
        peso: jsonData['peso'],
        tamanho: jsonData['tamanho'],
        verificado: jsonData['verificado']);
  }

  static Map<String, dynamic> toMap(RecemNascido rn) => {
        'id': rn.id,
        'nome': rn.nome,
        'dataNascimento': rn.dataNascimento,
        'local': rn.local,
        'peso': rn.peso,
        'tamanho': rn.tamanho,
        'verificado': rn.verificado
      };

  static String encode(List<RecemNascido> recemNascidos) => json.encode(
        recemNascidos
            .map<Map<String, dynamic>>((rn) => RecemNascido.toMap(rn))
            .toList(),
      );

  static List<RecemNascido> decode(String recemNascidos) =>
      (json.decode(recemNascidos) as List<dynamic>)
          .map<RecemNascido>((item) => RecemNascido.fromJson(item))
          .toList();

  @override
  String toString() {
    return 'Recém nascido {nome: $nome, dataNascimento: $dataNascimento, local: $local, peso: $peso, tamanho: $tamanho, verificado: $verificado}';
  }
}
