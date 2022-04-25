import 'package:flutter/material.dart';

import 'globals.dart' as globals;

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //  Todo: get les rooms depuis le réseau
    //  Todo: passer en stateful et ajouter la search bar
    List<GameRoom> roomList = [
      GameRoom("Room test 1", "Etienne", false),
      GameRoom("Private Room 1", "Tom", true, "password")
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${globals.username}"),
      ),
      body: Column(
        children: [
          TextButton(onPressed: () {}, child: Text("Ici searchbar")),
          Column(
            children: [
              for (GameRoom room in roomList)
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(room.hasPassword ? Icons.lock : Icons.lock_open),
                        title: Text(room.name),
                        subtitle: Text("owner : ${room.owner}"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
                            child: TextButton(
                              child: const Text('Join room'),
                              onPressed: () {/* ... */},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }
}

class GameRoom {
  String name;
  String owner;
  String? password;
  bool hasPassword;

  GameRoom(this.name, this.owner, this.hasPassword, [this.password]);
}
