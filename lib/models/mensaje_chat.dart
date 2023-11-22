import 'package:cloud_firestore/cloud_firestore.dart';

class MensajeChat {
  String? _id;
  String _mensaje;
  String _usuario;
  Timestamp _timestamp;

  MensajeChat({
    String? id,
    required String mensaje,
    required String usuario,
    required DateTime timestamp,
  })  : _id = id,
        _mensaje = mensaje,
        _usuario = usuario,
        _timestamp = Timestamp.fromDate(timestamp);

  factory MensajeChat.fromSnapshot(QueryDocumentSnapshot doc) {
    return MensajeChat(
      id: doc.id,
      mensaje: doc['mensaje'],
      usuario: doc['usuario'],
      timestamp: doc['timestamp'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mensaje': _mensaje,
      'usuario': _usuario,
      'timestamp': _timestamp,
    };
  }

  //getters
  String? get id => _id;
  String get mensaje => _mensaje;
  String get usuario => _usuario;
  DateTime get timestamp => _timestamp.toDate();

  //setters
  set id(String? id) => this._id = id;
  set mensaje(String mensaje) => this._mensaje = mensaje;
  set usuario(String nombreUsuario) => this.usuario = nombreUsuario;
  set timestamp(DateTime timestamp) =>
      this._timestamp = Timestamp.fromDate(timestamp);
}
