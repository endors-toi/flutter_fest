import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fest/models/evento.dart';

class FirestoreService {
  static final CollectionReference eventos =
      FirebaseFirestore.instance.collection('eventos');

  // obtener eventos Future / Stream
  static Stream<QuerySnapshot> obtenerEventos() {
    return eventos.snapshots();
  }

  // agregar evento
  static Future<void> agregarEvento(Evento evento) {
    return eventos.add(evento);
  }

  // obtener evento especifíco
  // obtener eventos por tipo
  // editar evento (put/patch)
  // eliminar evento
}
