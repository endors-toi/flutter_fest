import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_fest/models/evento.dart';
import 'package:flutter_fest/pages/nuevo_evento_page.dart';
import 'package:flutter_fest/providers/authentication_provider.dart';
import 'package:flutter_fest/services/firestore_service.dart';
import 'package:flutter_fest/widgets/evento_card.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

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
    _user = Provider.of<AuthenticationProvider>(context, listen: false).user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      drawer: _drawer(context),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirestoreService.obtenerEventos(),
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

  Drawer _drawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: _user != null
                      ? NetworkImage(_user!.photoURL!)
                      : Image.asset('assets/images/flutter_fest.png').image,
                  radius: 50,
                ),
                Divider(color: Colors.transparent, height: 10),
                Text(_user != null
                    ? _user!.displayName!
                    : '¡Bienvenido/a a Flutter Fest!'),
              ],
            ),
          ),
          Spacer(),
          _user != null
              ? ListTile(
                  leading: Icon(FeatherIcons.logOut),
                  title: Text("Cerrar sesión"),
                  onTap: () {
                    if (_user != null) {
                      Provider.of<AuthenticationProvider>(context,
                              listen: false)
                          .signOut()
                          .then((_) {
                        setState(() {
                          _user = null;
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                )
              : SignInButton(
                  Buttons.google,
                  onPressed: () async {
                    await Provider.of<AuthenticationProvider>(context,
                            listen: false)
                        .signInWithGoogle();
                    setState(() {
                      _user = Provider.of<AuthenticationProvider>(context,
                              listen: false)
                          .user;
                    });
                  },
                ),
        ],
      ),
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
}
