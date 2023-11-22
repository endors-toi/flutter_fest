import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_fest/models/evento.dart';
import 'package:flutter_fest/pages/ver_evento_page.dart';
import 'package:flutter_fest/providers/authentication_provider.dart';
import 'package:flutter_fest/services/firestore_service.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

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
  late bool _isLoggedIn;
  late int _localLikes;
  late bool _hasLiked;

  @override
  void initState() {
    _isLoggedIn = Provider.of<AuthenticationProvider>(context, listen: false)
        .isLoggedIn();
    _localLikes = widget.evento.likes!;
    _hasLiked = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _isLoggedIn ? () => mostrarOpciones() : () {},
      child: Container(
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
                  child: !widget.creating
                      ? LikeButton(
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
                          isLiked: _hasLiked,
                          likeCount: _localLikes,
                          countPostion: CountPostion.bottom,
                          onTap: (bool isLiked) async {
                            if (isLiked) {
                              FirestoreService.dislikeEvento(
                                  widget.evento.documentId!);
                              _localLikes--;
                              _hasLiked = false;
                            } else {
                              FirestoreService.likeEvento(
                                  widget.evento.documentId!);
                              _localLikes++;
                              _hasLiked = true;
                            }
                            setState(() {});
                            return !isLiked;
                          },
                        )
                      : null,
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
      ),
    );
  }

  mostrarOpciones() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VerEventoPage(evento: widget.evento),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Eliminar'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Eliminar Evento'),
                          content: Text(
                              '¿Está seguro que desea eliminar este evento?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                EasyLoading.show(status: 'Eliminando...');
                                FirestoreService.eliminarEvento(
                                        widget.evento.documentId!)
                                    .then((_) {
                                  EasyLoading.showSuccess('Evento eliminado');
                                  Navigator.pop(context);
                                });
                              },
                              child: Text('Eliminar'),
                            ),
                          ],
                        );
                      });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
