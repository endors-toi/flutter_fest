import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fest/models/mensaje_chat.dart';
import 'package:flutter_fest/providers/authentication_provider.dart';
import 'package:flutter_fest/services/chat_service.dart';
import 'package:flutter_fest/widgets/user_drawer.dart';
import 'package:provider/provider.dart';

class GlobalChatPage extends StatefulWidget {
  const GlobalChatPage({super.key});

  @override
  State<GlobalChatPage> createState() => _GlobalChatPageState();
}

class _GlobalChatPageState extends State<GlobalChatPage> {
  TextEditingController _mensajeController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User? _user;
  bool _isLoggedIn = false;

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: UserDrawer(
            onRefresh: () => setState(() {
                  _getUser();
                })),
        appBar: AppBar(
          title: Text('¡Chatea con otros asistentes! :-)'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        ),
        body: Column(
          children: [
            Expanded(child: _chat()),
            _input(),
          ],
        ));
  }

  void _getUser() {
    setState(() {
      _user = Provider.of<AuthenticationProvider>(context, listen: false).user;
      _isLoggedIn = _user != null;
    });
  }

  Widget _chat() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: StreamBuilder(
        stream: ChatService.obtenerMensajes(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).highlightColor),
            );
          }
          return ListView.builder(
            reverse: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              MensajeChat mensaje =
                  MensajeChat.fromSnapshot(snapshot.data!.docs[index]);
              return ListTile(
                title: Text(
                  mensaje.usuario,
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey[700]),
                ),
                subtitle: Text(
                  mensaje.mensaje,
                  style: TextStyle(
                      fontSize: 16, color: Theme.of(context).primaryColorLight),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _input() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _mensajeController,
                decoration: InputDecoration(
                  enabled: _isLoggedIn,
                  hintText: _isLoggedIn
                      ? 'Escribe tu mensaje'
                      : 'Inicia sesión para chatear',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, escribe un mensaje';
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (_isLoggedIn && _formKey.currentState!.validate()) {
                  ChatService.enviarMensaje(
                    MensajeChat(
                      mensaje: _mensajeController.text,
                      usuario: _user!.displayName!,
                      timestamp: DateTime.now(),
                    ),
                  );
                  _mensajeController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
