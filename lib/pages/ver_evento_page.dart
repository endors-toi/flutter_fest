import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_fest/services/evento_service.dart';
import 'package:flutter_fest/services/firebase_storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:flutter_fest/models/evento.dart';
import 'package:line_icons/line_icons.dart';

class VerEventoPage extends StatefulWidget {
  final Evento evento;
  final bool editing;

  VerEventoPage({super.key, required this.evento, this.editing = false});

  @override
  _VerEventoPageState createState() => _VerEventoPageState();
}

class _VerEventoPageState extends State<VerEventoPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _lugarController;
  late TextEditingController _descripcionController;
  late TextEditingController _tipoController;
  late DateTime _fechaEvento;

  File? _image;
  bool _hasPickedImage = false;

  late int _localLikes;
  late bool _hasLiked;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Evento"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(children: [
                _hasPickedImage
                    ? Image.file(
                        _image!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        widget.evento.foto!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                widget.editing
                    ? Positioned(
                        bottom: 10,
                        right: 10,
                        child: InkWell(
                          child: Icon(
                            LineIcons.image,
                            size: 36,
                            color: Colors.white,
                            fill: 0.5,
                          ),
                          onTap: () => _elegirImagen(),
                        ),
                      )
                    : Container(),
              ]),
              SizedBox(height: 10),
              _campoAdaptativo('Nombre', widget.evento.nombre!),
              Divider(color: Colors.grey, height: 20),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      "Tipo: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    widget.editing
                        ? _dropdownTipo(context)
                        : Text(widget.evento.tipo!,
                            style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              _campoAdaptativo('Lugar', widget.evento.lugar!),
              widget.editing
                  ? Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "¿Cuándo?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${DateFormat('dd/MM/yyyy HH:mm').format(_fechaEvento)}",
                            style: TextStyle(fontSize: 18),
                          ),
                          Row(
                            children: [
                              InkWell(
                                child: Icon(LineIcons.calendar, size: 36),
                                onTapUp: (_) => _elegirFecha(),
                              ),
                              InkWell(
                                child: Icon(LineIcons.clock, size: 36),
                                onTapUp: (_) => _elegirHora(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : _campoAdaptativo('Fecha',
                      '${widget.evento.fecha()} a las ${widget.evento.hora()}'),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Descripción"),
                    Divider(),
                    widget.editing
                        ? TextFormField(
                            controller: _descripcionController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Descripción del evento",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          )
                        : Text(
                            widget.evento.descripcion!,
                            style: TextStyle(fontSize: 16),
                          ),
                  ],
                ),
              ),
              widget.editing
                  ? ElevatedButton(
                      style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(Size(200, 50))),
                      onPressed: () => _guardarEvento(),
                      child: Text("Guardar Evento"))
                  : _likeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownTipo(BuildContext context) {
    return Expanded(
      child: DropdownMenu(
        controller: _tipoController,
        dropdownMenuEntries: [
          DropdownMenuEntry(value: "CONCIERTO", label: "Concierto"),
          DropdownMenuEntry(value: "FIESTA", label: "Fiesta"),
          DropdownMenuEntry(value: "DEPORTIVO", label: "Deportivo"),
          DropdownMenuEntry(value: "EMPRESARIAL", label: "Empresarial"),
          DropdownMenuEntry(value: "CULTURAL", label: "Cultural"),
          DropdownMenuEntry(value: "ACADEMICO", label: "Academico"),
        ],
        onSelected: (value) {
          setState(() {
            _tipoController.text = value ?? "";
          });
        },
      ),
    );
  }

  Widget _campoAdaptativo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          label != 'Nombre'
              ? Text(
                  "$label: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )
              : Container(),
          Expanded(
            child: widget.editing
                ? TextFormField(
                    controller: _pickController(label),
                    decoration: InputDecoration(
                      hintText: value,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese un valor';
                      }
                      return null;
                    },
                  )
                : Text(value,
                    style: label != 'Nombre'
                        ? TextStyle(fontSize: 16)
                        : TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _likeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LikeButton(
          size: 100,
          circleColor: CircleColor(
              start: Colors.pinkAccent, end: Color.fromARGB(255, 204, 0, 255)),
          circleSize: 20,
          bubblesColor: BubblesColor(
            dotPrimaryColor: Colors.pinkAccent,
            dotSecondaryColor: Color.fromARGB(255, 204, 0, 255),
          ),
          likeBuilder: (bool isLiked) {
            return Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Color.fromARGB(255, 204, 0, 255) : Colors.grey,
              size: 100,
            );
          },
          isLiked: _hasLiked,
          likeCount: _localLikes,
          countPostion: CountPostion.bottom,
          onTap: (bool isLiked) async {
            if (isLiked) {
              EventoService.dislikeEvento(widget.evento.documentId!);
              _localLikes--;
              _hasLiked = false;
            } else {
              EventoService.likeEvento(widget.evento.documentId!);
              _localLikes++;
              _hasLiked = true;
            }
            setState(() {});
            return !isLiked;
          },
        ),
      ],
    );
  }

  _init() {
    _nombreController = TextEditingController(text: widget.evento.nombre);
    _lugarController = TextEditingController(text: widget.evento.lugar);
    _descripcionController =
        TextEditingController(text: widget.evento.descripcion);
    _tipoController = TextEditingController(text: widget.evento.tipo);
    _localLikes = widget.evento.likes!;
    _hasLiked = false;
    _fechaEvento = widget.evento.timestampToDate();
  }

  _pickController(String label) {
    switch (label) {
      case 'Tipo':
        return _tipoController;
      case 'Lugar':
        return _lugarController;
      case 'Nombre':
        return _nombreController;
      default:
        return _descripcionController;
    }
  }

  bool _validateForm() {
    if (_formKey.currentState!.validate()) {
      if (_fechaEvento.isBefore(DateTime.now())) {
        EasyLoading.showError("El evento no puede ser en el pasado.");
      } else {
        return true;
      }
    }
    return false;
  }

  _elegirFecha() {
    showDatePicker(
      context: context,
      firstDate: DateTime(1997),
      lastDate: DateTime(DateTime.now().year + 10, 12, 31),
      initialDate: _fechaEvento,
    ).then((fecha) {
      if (fecha != null) {
        setState(() {
          _fechaEvento = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            _fechaEvento.hour,
            _fechaEvento.minute,
          );
        });
      }
    });
  }

  _elegirHora() {
    showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: _fechaEvento.hour,
          minute: _fechaEvento.minute,
        )).then((hora) {
      if (hora != null) {
        setState(() {
          _fechaEvento = DateTime(
            _fechaEvento.year,
            _fechaEvento.month,
            _fechaEvento.day,
            hora.hour,
            hora.minute,
          );
        });
      }
    });
  }

  _elegirImagen() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _hasPickedImage = true;
      });
    }
  }

  _guardarEvento() async {
    if (_validateForm()) {
      String url = widget.evento.foto!;
      if (_hasPickedImage) {
        EasyLoading.show(status: "Subiendo imagen...");
        url = await FirebaseStorageService().uploadFile(_image!);
      }
      Evento evento = Evento(
        documentId: widget.evento.documentId,
        nombre: _nombreController.text,
        lugar: _lugarController.text,
        descripcion: _descripcionController.text,
        tipo: _tipoController.text,
        likes: _localLikes,
        timestamp: _fechaEvento,
        foto: url,
      );
      EasyLoading.show(status: "Guardando evento...");
      EventoService.editarEvento(evento).then((_) {
        EasyLoading.showSuccess("Evento guardado :-)");
        Navigator.pop(context);
      });
      ;
    }
  }
}
