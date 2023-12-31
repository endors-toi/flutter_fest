/*
  Los eventos como mínimo deben tener: nombre, fecha, hora, lugar, descripción,
  tipo (concierto, fiesta, evento, deportivo, etc.), la cantidad de “me gusta” y una fotografía.
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fest/services/evento_service.dart';
import 'package:intl/intl.dart';

class Evento {
  String? _documentId;
  String? _nombre;
  Timestamp? _timestamp;
  String? _lugar;
  String? _descripcion;
  String? _tipo;
  int? _likes;
  String? _foto;

  Evento({
    String? documentId,
    String? nombre,
    DateTime? timestamp,
    String? lugar,
    String? descripcion,
    String? tipo,
    int? likes = 0,
    String? foto,
  })  : _documentId = documentId,
        _nombre = nombre,
        _timestamp = Timestamp.fromDate(timestamp!),
        _lugar = lugar,
        _descripcion = descripcion,
        _tipo = tipo,
        _likes = likes,
        _foto = foto;

  Evento.fromSnapshot(QueryDocumentSnapshot doc)
      : _documentId = doc.id,
        _nombre = extraerCampo(doc, 'nombre') ?? 'Sin nombre',
        _timestamp = extraerCampo(doc, 'timestamp'),
        _lugar = extraerCampo(doc, 'lugar') ?? 'Sin lugar',
        _descripcion = extraerCampo(doc, 'descripcion') ?? 'Sin descripcion',
        _tipo = extraerCampo(doc, 'tipo') ?? 'Sin tipo',
        _likes = extraerCampo(doc, 'likes') ?? -1,
        _foto = extraerCampo(doc, 'foto') ?? 'Sin foto';

  // Getters
  String? get documentId => _documentId;
  String? get nombre => _nombre;
  Timestamp? get timestamp => _timestamp;
  String? get lugar => _lugar;
  String? get descripcion => _descripcion;
  String? get tipo => _tipo;
  int? get likes => _likes;
  String? get foto => _foto;

  // Setters
  set documentId(String? documentId) => _documentId = documentId;
  set nombre(String? nombre) => _nombre = nombre;
  set timestamp(Timestamp? timestamp) => _timestamp = timestamp;
  set lugar(String? lugar) => _lugar = lugar;
  set descripcion(String? descripcion) => _descripcion = descripcion;
  set tipo(String? tipo) => _tipo = tipo;
  set likes(int? likes) => _likes = likes;
  set foto(String? foto) => _foto = foto;

  // Métodos
  String fecha() {
    return DateFormat("dd/MM/yyyy").format(_timestamp!.toDate());
  }

  String hora() {
    return DateFormat("HH:mm").format(_timestamp!.toDate());
  }

  DateTime timestampToDate() {
    return _timestamp!.toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': _nombre,
      'timestamp': _timestamp,
      'lugar': _lugar,
      'descripcion': _descripcion,
      'tipo': _tipo,
      'likes': _likes,
      'foto': _foto,
    };
  }

  Future<void> like() async {
    var doc = await EventoService.obtenerEvento(_documentId!);
    doc.update({'likes': FieldValue.increment(1)});
    _likes = await doc.get().then((value) => value.get('likes'));
  }

  Future<void> dislike() async {
    var doc = await EventoService.obtenerEvento(_documentId!);
    var currentLikes = await doc.get().then((value) => value.get('likes'));
    if (currentLikes > 0) await doc.update({'likes': FieldValue.increment(-1)});
    _likes = await doc.get().then((value) => value.get('likes'));
  }
}

dynamic extraerCampo(QueryDocumentSnapshot doc, String nombreCampo) =>
    doc.data().toString().contains(nombreCampo) ? doc.get(nombreCampo) : null;
