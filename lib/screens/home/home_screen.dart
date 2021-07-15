import 'package:flutter/material.dart';
import 'package:flutter_firebase/common/loading.dart';
import 'package:flutter_firebase/models/user.dart';
import 'package:flutter_firebase/screens/home/user_list.dart';
import 'package:flutter_firebase/services/authentication.dart';
import 'package:flutter_firebase/services/database.dart';
import 'package:flutter_firebase/services/notification_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final AuthenticationService _auth = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    NotificationService.initialize();
    final user = Provider.of<AppUser?>(context);
    if (user == null) throw Exception("user not found");
    final database = DatabaseService(user.uid);
    return StreamProvider<List<AppUserData>>.value(
      initialData: [],
      value: database.users,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          elevation: 0.0,
          title: Text('Water Social'),
          actions: <Widget>[
            StreamBuilder<AppUserData>(
              stream: database.user,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  AppUserData? userData = snapshot.data;
                  if (userData == null) return Loading();
                  return TextButton.icon(
                    icon: Icon(
                      Icons.wine_bar,
                      color: Colors.white,
                    ),
                    label: Text('drink', style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      await database.saveUser(userData.name, userData.waterCounter + 1);
                    },
                  );
                } else {
                  return Loading();
                }
              },
            ),
            TextButton.icon(
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              label: Text('logout', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await _auth.signOut();
              },
            )
          ],
        ),
        body: UserList(),
      ),
    );
  }
}
