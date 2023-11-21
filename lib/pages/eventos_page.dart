import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_fest/models/evento.dart';
import 'package:flutter_fest/pages/nuevo_evento_page.dart';
import 'package:flutter_fest/providers/authentication_provider.dart';
import 'package:flutter_fest/services/firestore_service.dart';
import 'package:flutter_fest/widgets/evento_card.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  User? _user;

  @override
  void initState() {
    _user = Provider.of<AuthenticationProvider>(context, listen: false).user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      drawer: _drawer(context),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirestoreService.obtenerEventos(),
          builder: _streamBuilder,
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text('Flutter Fest'),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      actions: [
        _user != null
            ? IconButton(
                icon: Icon(LineIcons.plusCircle),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NuevoEventoPage()));
                },
              )
            : Column(),
      ],
    );
  }

  Drawer _drawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: _user != null
                      ? NetworkImage(_user!.photoURL!)
                      : Image.asset('assets/images/flutter_fest.png').image,
                  radius: 50,
                ),
                Divider(color: Colors.transparent, height: 10),
                Text(_user != null
                    ? _user!.displayName!
                    : '¡Bienvenido/a a Flutter Fest!'),
              ],
            ),
          ),
          Spacer(),
          _user != null
              ? ListTile(
                  leading: Icon(FeatherIcons.logOut),
                  title: Text("Cerrar sesión"),
                  onTap: () {
                    if (_user != null) {
                      Provider.of<AuthenticationProvider>(context,
                              listen: false)
                          .signOut()
                          .then((_) {
                        setState(() {
                          _user = null;
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                )
              : SignInButton(
                  Buttons.google,
                  onPressed: () async {
                    await Provider.of<AuthenticationProvider>(context,
                            listen: false)
                        .signInWithGoogle();
                    setState(() {
                      _user = Provider.of<AuthenticationProvider>(context,
                              listen: false)
                          .user;
                    });
                  },
                ),
        ],
      ),
    );
  }

  Widget _streamBuilder(context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData ||
        snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          Evento evento = Evento.fromSnapshot(snapshot.data!.docs[index]);
          return EventoCard(evento: evento);
        },
      );
    }
  }
}
