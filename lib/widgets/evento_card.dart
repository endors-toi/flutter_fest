import 'package:flutter/material.dart';
import 'package:flutter_fest/models/evento.dart';

class EventoCard extends StatelessWidget {
  const EventoCard({
    super.key,
    required this.evento,
  });

  final Evento evento;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 5,
        child: Column(children: [
          Image.asset('assets/images/nostalgia.jpg'),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(evento.nombre!, style: TextStyle(fontSize: 28))),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("Tipo: " + evento.tipo!),
          ),
        ]),
      ),
    );
  }
}
