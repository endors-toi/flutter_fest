import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fest/login_page.dart';
import 'package:flutter_fest/models/evento.dart';
import 'package:flutter_fest/pages/nuevo_evento_page.dart';
import 'package:flutter_fest/services/authentication_provider.dart';
import 'package:flutter_fest/services/firestore_service.dart';
import 'package:flutter_fest/widgets/evento_card.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

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
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_user != null
                        ? _user!.photoURL!
                        : 'https://via.placeholder.com/150'),
                    radius: 50,
                  ),
                  Divider(color: Colors.transparent, height: 10),
                  Text(_user != null ? _user!.displayName! : 'No user'),
                ],
              ),
            ),
            Spacer(),
            ListTile(
              leading: Icon(LineIcons.alternateSignOut),
              title: Text("Cerrar sesión"),
              onTap: () {
                Provider.of<AuthenticationProvider>(context, listen: false)
                    .signOut();
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Flutter Fest'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(LineIcons.plusCircle),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => NuevoEventoPage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirestoreService.obtenerEventos(),
          builder: _streamBuilder,
        ),
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
