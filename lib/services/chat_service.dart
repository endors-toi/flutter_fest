import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fest/models/mensaje_chat.dart';

class ChatService {
  static final CollectionReference globalchat =
      FirebaseFirestore.instance.collection('chat');

  // obtener mensajes
  static Stream<QuerySnapshot> obtenerMensajes() {
    return globalchat.orderBy('timestamp', descending: true).snapshots();
  }

  // agregar mensaje al chat
  static Future<void> enviarMensaje(MensajeChat mensaje) {
    return globalchat.add(mensaje.toMap());
  }

  // eliminar mensaje
  static Future<void> eliminarMensaje(String id) {
    return globalchat.doc(id).collection('mensajes').doc(id).delete();
  }
}
