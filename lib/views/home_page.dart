import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static String tag = '/home';

  @override
  Widget build(BuildContext context) {
    var snapshots = FirebaseFirestore.instance
        .collection('tarefas')
        .where('excluido', isEqualTo: false)
        .orderBy('data')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("Tarefas"),
      ),
      backgroundColor: Colors.grey[200],
      body: StreamBuilder(
        stream: snapshots,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.docs.length == 0) {
            return Center(child: Text('Nenhuma tarefa para chamar de sua'));
          }

          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (BuildContext context, int i) {
              var doc = snapshot.data.docs[i];
              var item = doc.data();

              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                ),
                margin: const EdgeInsets.all(5),
                child: ListTile(
                  isThreeLine: true,
                  leading: IconButton(
                    icon: Icon(
                      item['realizado']
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      size: 32,
                    ),
                    onPressed: () => doc.reference.update({
                      'realizado': !item['realizado'],
                    }),
                  ),
                  title: Text(item['titulo']),
                  subtitle: Text(item["descricao"]),
                  trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                    onPressed: () => doc.reference.update({
                      'excluido': true,
                    }),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => modalCreate(context),
        tooltip: 'Adicionar',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  modalCreate(BuildContext context) {
    GlobalKey<FormState> form = GlobalKey<FormState>();

    var titulo = TextEditingController();
    var descricao = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Criar nova tarefa'),
            content: Form(
                key: form,
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Titulo'),
                      TextFormField(
                        controller: titulo,
                        decoration: InputDecoration(
                            hintText: 'Ex.: Ir no mercado',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Este campo não pode ser vazio';
                          }
                        },
                      ),
                      SizedBox(height: 30),
                      Text('Descrição'),
                      TextFormField(
                        controller: descricao,
                        decoration: InputDecoration(
                            hintText: '(Opcional)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                      ),
                    ],
                  ),
                )),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar')),
              FlatButton(
                  onPressed: () async {
                    if (form.currentState.validate()) {
                      await FirebaseFirestore.instance
                          .collection('tarefas')
                          .add({
                        'titulo': titulo.text,
                        'descricao': descricao.text,
                        'data': Timestamp.now(),
                        'realizado': false,
                        'excluido': false
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  color: Colors.green,
                  child: Text('Salvar')),
            ],
          );
        });
  }
}
