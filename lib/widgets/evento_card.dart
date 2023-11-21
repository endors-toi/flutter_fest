import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fest/models/evento.dart';
import 'package:like_button/like_button.dart';

class EventoCard extends StatefulWidget {
  final Evento evento;
  final bool creating;
  final File? image;

  EventoCard({
    super.key,
    required this.evento,
    this.creating = false,
    this.image,
  });

  @override
  State<EventoCard> createState() => _EventoCardState();
}

class _EventoCardState extends State<EventoCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 8,
        child: Column(children: [
          Container(
            height: 250,
            width: double.infinity,
            child: widget.creating
                ? widget.image != null
                    ? Image.file(widget.image!, fit: BoxFit.cover)
                    : Image.asset('assets/images/nostalgia.jpg')
                : widget.evento.foto != null && widget.evento.foto != ''
                    ? Image.network(widget.evento.foto!, fit: BoxFit.cover)
                    : Image.asset('assets/images/nostalgia.jpg'),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.evento.nombre!,
                    style: TextStyle(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8, right: 8),
                child: !widget.creating ? Like(eventoCard: widget) : null,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Tipo: " + widget.evento.tipo!),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Lugar: " + widget.evento.lugar!),
              ),
            ],
          ),
          Text('${widget.evento.fecha()} a las ${widget.evento.hora()}'),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(widget.evento.descripcion!,
                style: TextStyle(fontSize: 16)),
          ),
        ]),
      ),
    );
  }
}

class Like extends StatefulWidget {
  const Like({
    super.key,
    required this.eventoCard,
  });

  final EventoCard eventoCard;

  @override
  State<Like> createState() => _LikeState();
}

class _LikeState extends State<Like> {
  @override
  Widget build(BuildContext context) {
    return LikeButton(
      size: 30,
      circleColor: CircleColor(
        start: Colors.pinkAccent,
        end: Colors.pink,
      ),
      bubblesColor: BubblesColor(
        dotPrimaryColor: Colors.pinkAccent,
        dotSecondaryColor: Colors.pink,
      ),
      likeBuilder: (bool isLiked) {
        return Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.pink : Colors.grey,
          size: 30,
        );
      },
      likeCount: widget.eventoCard.evento.likes,
      countPostion: CountPostion.bottom,
      onTap: onLiked,
    );
  }

  Future<bool?> onLiked(bool isLiked) async {
    if (isLiked) {
      await widget.eventoCard.evento.like();
    } else {
      await widget.eventoCard.evento.dislike();
    }
    setState(() {});
    return !isLiked;
  }
}
