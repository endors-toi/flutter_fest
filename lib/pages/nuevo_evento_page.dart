import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_fest/models/evento.dart';
import 'package:flutter_fest/services/firebase_storage_service.dart';
import 'package:flutter_fest/services/evento_service.dart';
import 'package:flutter_fest/widgets/evento_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';

class NuevoEventoPage extends StatefulWidget {
  const NuevoEventoPage({super.key});

  @override
  State<NuevoEventoPage> createState() => _NuevoEventoPageState();
}

class _NuevoEventoPageState extends State<NuevoEventoPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _lugarController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  TextEditingController _tipoController = TextEditingController();
  DateTime _timestamp = DateTime.now();
  File? _image;

  bool _isDatePicked = false;
  bool _isTimePicked = false;

  late Evento _nuevoEvento;

  @override
  void dispose() {
    _nombreController.dispose();
    _lugarController.dispose();
    _descripcionController.dispose();
    _tipoController.dispose();
    _timestamp = DateTime.now();
    _isDatePicked = false;
    _isTimePicked = false;
    _image = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nuevoEvento = Evento(
      nombre: _nombreController.text,
      descripcion: _descripcionController.text,
      lugar: _lugarController.text,
      tipo: _tipoController.text,
      timestamp: _timestamp,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo evento'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(LineIcons.times),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              /*
                Los eventos como mínimo deben tener: nombre, fecha, hora, lugar, descripción,
                tipo (concierto, fiesta, evento, deportivo, etc.), la cantidad de “me gusta” y una fotografía.
              */
              Expanded(
                child: ListView(
                  children: [
                    EventoCard(
                      evento: _nuevoEvento,
                      creating: true,
                      image: _image,
                    ),
                    Container(
                      margin: EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nombre',
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (nombre) {
                          if (nombre == null || nombre.trim() == "") {
                            return 'Debes proporcionar un nombre.';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _descripcionController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Descripción',
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (desc) {
                          if (desc == null || desc.trim() == "") {
                            return 'Debes proporcionar una descripción.';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _lugarController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Lugar',
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (lugar) {
                          if (lugar == null || lugar.trim() == "") {
                            return 'Debes proporcionar un lugar.';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: _dropdownTipo(context),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            child: Icon(LineIcons.image, size: 36),
                            onTapUp: (_) => _elegirImagen(),
                          ),
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
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(0, 50))),
                  onPressed: () {
                    _guardarEvento();
                  },
                  child: Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DropdownMenu<String> _dropdownTipo(BuildContext context) {
    return DropdownMenu(
      width: MediaQuery.of(context).size.width - 30,
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
      label: Text("Tipo de Evento"),
    );
  }

  _elegirFecha() {
    showDatePicker(
      context: context,
      firstDate: DateTime(1997),
      lastDate: DateTime(DateTime.now().year + 10, 12, 31),
      initialDate: _timestamp,
    ).then((fecha) {
      if (fecha != null) {
        setState(() {
          _timestamp = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            _timestamp.hour,
            _timestamp.minute,
          );
          _isDatePicked = true;
        });
      }
    });
  }

  _elegirHora() {
    showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: _timestamp.hour,
          minute: _timestamp.minute,
        )).then((hora) {
      if (hora != null) {
        setState(() {
          _timestamp = DateTime(
            _timestamp.year,
            _timestamp.month,
            _timestamp.day,
            hora.hour,
            hora.minute,
          );
          _isTimePicked = true;
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
      });
    }
  }

  bool _validateForm() {
    if (_formKey.currentState!.validate()) {
      String errores = "";
      if (_image == null) errores += "Debes subir una imagen.\n";
      if (_tipoController.text == "")
        errores += "Debes seleccionar un tipo de evento.\n";
      if (!_isDatePicked) errores += "Debes seleccionar una fecha.\n";
      if (!_isTimePicked) errores += "Debes seleccionar una hora.\n";
      // if (_isDatePicked && _isTimePicked) {
      //   if (_timestamp.isBefore(DateTime.now())) {
      //     errores += "El evento no puede ser pasado.";
      //   }
      // }
      if (errores != "") {
        EasyLoading.showError(errores, duration: Duration(seconds: 3));
      } else {
        return true;
      }
    }
    return false;
  }

  _guardarEvento() async {
    if (_validateForm()) {
      EasyLoading.show(status: "Subiendo imagen...");
      FirebaseStorageService().uploadFile(_image!).then((url) {
        setState(() {
          _nuevoEvento.foto = url;
        });
        EasyLoading.show(status: "Guardando evento...");
        EventoService.agregarEvento(_nuevoEvento).then((_) {
          EasyLoading.showSuccess("Evento guardado :-)");
          // Navigator.pop(context);
        });
      });
    }
  }
}
