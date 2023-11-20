import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fest/models/evento.dart';
import 'package:flutter_fest/pages/nuevo_evento_page.dart';
import 'package:flutter_fest/services/firestore_service.dart';
import 'package:flutter_fest/widgets/evento_card.dart';
import 'package:line_icons/line_icons.dart';

class EventosPage extends StatelessWidget {
  const EventosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
