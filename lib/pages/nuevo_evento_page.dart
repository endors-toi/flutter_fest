import 'package:flutter/material.dart';

class NuevoEventoPage extends StatefulWidget {
  const NuevoEventoPage({super.key});

  @override
  State<NuevoEventoPage> createState() => _NuevoEventoPageState();
}

class _NuevoEventoPageState extends State<NuevoEventoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo evento'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            /*
              Los eventos como mínimo deben tener: nombre, fecha, hora, lugar, descripción,
              tipo (concierto, fiesta, evento, deportivo, etc.), la cantidad de “me gusta” y una fotografía.
            */
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Fecha',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Hora',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Lugar',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Descripción',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Tipo',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Foto',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _guardarEvento();
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _guardarEvento() {}
}
