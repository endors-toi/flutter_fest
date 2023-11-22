import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fest/models/evento.dart';

class FirestoreService {
  static final CollectionReference eventos =
      FirebaseFirestore.instance.collection('eventos');

  // obtener eventos Future / Stream
  static Stream<QuerySnapshot> obtenerEventos() {
    return eventos.snapshots();
  }

  // obtener evento especifíco
  static Future<DocumentReference> obtenerEvento(String id) async {
    return await eventos.doc(id);
  }

  // agregar evento
  static Future<void> agregarEvento(Evento evento) {
    return eventos.add(evento.toMap());
  }

  // eliminar evento
  static Future<void> eliminarEvento(String id) {
    return eventos.doc(id).delete();
  }

  // editar evento
  static Future<void> editarEvento(Evento evento) {
    return eventos.doc(evento.documentId).update(evento.toMap());
  }

  // like evento
  static Future<void> likeEvento(String id) {
    return eventos.doc(id).update({'likes': FieldValue.increment(1)});
  }

  // dislike evento
  static Future<void> dislikeEvento(String id) {
    return eventos.doc(id).update({'likes': FieldValue.increment(-1)});
  }

  // obtener eventos por tipo
}
