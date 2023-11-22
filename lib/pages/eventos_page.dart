import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_fest/models/evento.dart';
import 'package:flutter_fest/pages/nuevo_evento_page.dart';
import 'package:flutter_fest/providers/authentication_provider.dart';
import 'package:flutter_fest/services/evento_service.dart';
import 'package:flutter_fest/widgets/evento_card.dart';
import 'package:flutter_fest/widgets/user_drawer.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  User? _user;
  bool _filtroFinalizados = false;
  bool _filtroEnCurso = false;

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      drawer: UserDrawer(
        onRefresh: () => _getUser(),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: EventoService.obtenerEventos(),
          builder: _streamBuilder,
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text('Flutter Fest'),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      actions: [
        IconButton(
          icon: Icon(FeatherIcons.filter),
          onPressed: () => mostrarFiltros(),
        ),
        _user != null
            ? ElevatedButton(
                child: Row(
                  children: [
                    Text("Nuevo"),
                    Icon(LineIcons.plus),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(100),
                          bottomLeft: Radius.circular(100))),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NuevoEventoPage()));
                },
              )
            : Container(),
      ],
    );
  }

  Widget _streamBuilder(context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData ||
        snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else {
      return LiquidPullToRefresh(
        onRefresh: () async {
          setState(() {});
        },
        showChildOpacityTransition: false,
        child: ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            Evento evento = Evento.fromSnapshot(snapshot.data!.docs[index]);
            if (!_filtroEnCurso && !_filtroFinalizados) {
              return EventoCard(evento: evento);
            }
            DateTime fechaEvento = evento.timestampToDate();
            DateTime fechaActual = DateTime.now();
            if (_filtroEnCurso && fechaEvento.isAfter(fechaActual)) {
              return EventoCard(evento: evento);
            }
            if (_filtroFinalizados && fechaEvento.isBefore(fechaActual)) {
              print(fechaEvento.toString() + fechaActual.toString());
              return EventoCard(evento: evento);
            }
            return SizedBox(height: 0);
          },
        ),
      );
    }
  }

  mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Wrap(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Filtrar Eventos",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              _filtroFinalizados
                  ? SizedBox(height: 0)
                  : ListTile(
                      leading: Icon(LineIcons.clockAlt),
                      title: Text('Mostrar eventos finalizados'),
                      onTap: () {
                        setState(() {
                          _filtroFinalizados = true;
                          _filtroEnCurso = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
              _filtroEnCurso
                  ? SizedBox(height: 0)
                  : ListTile(
                      leading: Icon(LineIcons.calendarCheck),
                      title: Text('Mostrar eventos activos'),
                      onTap: () {
                        setState(() {
                          _filtroEnCurso = true;
                          _filtroFinalizados = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
              _filtroEnCurso || _filtroFinalizados
                  ? ListTile(
                      leading: Icon(LineIcons.times),
                      title: Text('Limpiar filtros'),
                      onTap: () {
                        setState(() {
                          _filtroEnCurso = false;
                          _filtroFinalizados = false;
                        });
                        Navigator.pop(context);
                      },
                    )
                  : SizedBox(height: 0),
              SizedBox(height: 80)
            ],
          ),
        );
      },
    );
  }

  void _getUser() {
    setState(() {
      _user = Provider.of<AuthenticationProvider>(context, listen: false).user;
    });
  }
}
