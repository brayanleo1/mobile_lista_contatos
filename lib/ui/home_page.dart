import 'dart:io';

import 'package:mobile_lista_contatos/domain/contact.dart';
import 'package:mobile_lista_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contact_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactPage helper = ContactHelper();
  List<Contact> contatos = [];

  @override
  void initState() {
    super.initState();
    updateList();
  }

  void updateList() {
    helper.getAllContact().then((list) {
      setState(() {
        contatos = list.cast<Contact>();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.lightBlue,
        centerTitle: true
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.lightBlue,
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contatos.length,
          itemBuilder: (context, index) {
            return _contatoCard(context, index);
          }
        ),
    );
  }

  Widget _contatoCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contatos[index].img != ''
                    ? FileImage(File(contatos[index].img))
                    :AssetImage("images/pessoa.jpg")
                        as ImageProvider
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contatos[index].name,
                      style: TextStyle(
                        fontSize: 22.0, fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      contatos[index].email,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      contatos[index].phone,
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      }
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextButton(
                      child: Text("ligar",
                      style: TextStyle(
                        color: Colors.lightBlue, fontSize: 20.0
                      )),
                      onPressed: () {
                        launch("tel:${contatos[index].phone}");
                        Navigator.pop(context);
                      }
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextButton(
                      child: Text("editar",
                      style: TextStyle(
                        color: Colors.lightBlue, fontSize: 20.0
                      )),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contatos[index]);
                      }
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextButton(
                      child: Text("excluir",
                      style: TextStyle(
                        color: Colors.lightBlue, fontSize: 20.0
                      )),
                      onPressed: () {
                        helper.deleteContact(contatos[index].id);
                        updateList();
                        Navigator.pop(context);
                      }
                    )
                  )
                ],
              ),
            );
          },
        );
      }
    );
  }

  void _showContactPage({Contact? contact}) async {
    Contact contatoRet = await Navigator.push(context,
    MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (contatoRet.id == 0) {
      await helper.saveContact(contatoRet);
    } else {
      await helper.updateContact(contatoRet);
    }

    updateList();
  }
}