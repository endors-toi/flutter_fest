import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_fest/pages/eventos_page.dart';
import 'package:flutter_fest/pages/global_chat_page.dart';
import 'package:flutter_fest/providers/authentication_provider.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class UserDrawer extends StatefulWidget {
  final Function onRefresh;

  UserDrawer({required this.onRefresh});

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  User? _user;

  @override
  void initState() {
    _user = Provider.of<AuthenticationProvider>(context, listen: false).user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          ListTile(
            leading: Icon(FeatherIcons.calendar),
            title: Text("Eventos"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventosPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(FeatherIcons.messageCircle),
            title: Text("Chat global"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GlobalChatPage(),
                ),
              );
            },
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
                        widget.onRefresh();
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
                    widget.onRefresh();
                  },
                ),
        ],
      ),
    );
  }
}
