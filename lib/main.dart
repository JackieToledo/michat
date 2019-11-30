import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Import para hacer transparente la barra de estado:
import 'package:flutter/services.dart';

void main() => runApp(Chat());

final bd = Firestore.instance;

class Chat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Estado();
  }
}

class Estado extends StatefulWidget{
  @override
  State createState() => new Chats();
}

class Chats extends State<Estado> {

  final textController = TextEditingController();

  //Método que construye el diseño de la lista para cada mensaje:
  Widget buildItem(int index, DocumentSnapshot document){

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: 200.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(
                        right: 12, left: 12, top: 7, bottom: 5.0),
                    child: Text(document.data['mensaje'],
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 35,
              height: 35,
              margin: EdgeInsets.only(left: 5),
              child: Icon(Icons.account_circle),
            ),
          ],
        ),
      ),
    );
  }

  //Vista de la app_
  @override
  Widget build(BuildContext context) {

    //Poner la barra de estado transparente para que se vea blanca:
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
    ));

    return new MaterialApp(

        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: Colors.white),

        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,

              leading: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Container(
                      child: Icon(Icons.account_circle),
                    ),
                  ),

              title: Column(
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.only(top: 14),
                      alignment: Alignment(-1, 0),
                      child: Text("T.E. Programación",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black)
                      )
                  ),
                  Container(
                    alignment: Alignment(-1, 0),
                    child: Text("Toca para info del grupo",
                        style: TextStyle(
                            fontSize: 10,
                            color: Color.fromRGBO(10, 10, 10, .5)
                        )
                    ),
                  ),
                ],
              ),

              actions: <Widget>[
                IconButton(icon: Icon(Icons.videocam, color: Colors.deepPurple,),),
                IconButton(icon: Icon(Icons.call, color: Colors.deepPurple,),),
                IconButton(icon: Icon(Icons.more_vert, color: Colors.deepPurple,),)
              ],
            ),

            body: Container(

              //Escuchar en tiempo real modificaciones en la base de datos:
              child: StreamBuilder(
                  stream: bd.collection("chat").snapshots(),
                  builder: (context, snapshot) {

                    //Si no hay datos, mostrar carga:
                    if(!snapshot.hasData) {
                      return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          ));
                    } else { //Si hay datos, mostrarlos:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Flexible(
                            child: ListView.builder(
                              padding: EdgeInsets.all(20.0),
                              reverse: false,
                              itemBuilder: (context, index) =>
                                  buildItem(index, snapshot.data.documents[index]),
                              itemCount: snapshot.data.documents.length,
                            ),
                          ),

                          //Diseño de la barra inferior para escribir mensajes:
                          Container(
                              child: IconTheme(
                                data: new IconThemeData(color: Theme.of(context).accentColor),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(Icons.camera_alt, color: Colors.deepPurple,),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(Icons.photo, color: Colors.deepPurple,),
                                      ),
                                      Flexible(
                                        child: Container(
                                          height: 35,
                                          margin: EdgeInsets.only(top: 1, bottom: 1, right: 5),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Color.fromRGBO(10, 10, 10, .05)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 6, top: 8, right: 6),
                                            child:
                                            TextField(
                                              controller: textController,
                                              onSubmitted: (String text) {
                                                insertar(textController.text);
                                                textController.clear();
                                              },
                                              decoration: InputDecoration.collapsed(
                                                hintText: "Escribe un mensaje",
                                              ),
                                              cursorColor: Colors.deepPurple,
                                            ),
                                          ),
                                        ),
                                      ),

                                      Icon(Icons.insert_emoticon, color: Colors.deepPurple),

                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: IconButton(
                                          icon: Icon(Icons.send),
                                          color: Colors.deepPurple,
                                          onPressed: () {
                                            insertar(textController.text);
                                            textController.clear();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ),
                        ],
                      );
                    }
                  }
              ),
            )
        ));
  }
}

void insertar(String mensaje) async {
  await bd.collection("chat").add({'mensaje': mensaje});
}
