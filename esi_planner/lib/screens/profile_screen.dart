import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<AuthProvider>(context).username ?? 'Usuario';
    
    return  Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Text(
            'Aquí está tu perfil, $username.',
            style: const TextStyle(fontSize: 18),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications_sharp),
              title: Text('Notification 1'),
              subtitle: Text('This is a notification'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications_sharp),
              title: Text('aqui puedes ver una notificacion'),
              subtitle: Text('Aqui sus detalles'),
            ),
          ),
        ],
      ),
    );
  }
}
