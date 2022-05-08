import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'gameRoom.dart';
import 'globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool lockedRoom = false;
  DatabaseReference ref = FirebaseDatabase.instance.ref('rooms');

  createRoom(GameRoom room) {
    ref.push().set(room.toJson());
  }

  @override
  Widget build(BuildContext context) {
    //  Todo: get les rooms depuis le réseau
    //  Todo: ajouter la search bar
    //  Todo optionnel: ajouter un will pop scope en cas de retour arrière pour faire une déconnexion

    final _roomNameController = TextEditingController();
    final _roomPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${globals.username}"),
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: const Text("Create room"),
          icon: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                        title: const Text("Create a room"),
                        leading: IconButton(
                          icon: const Icon(Icons.cancel_outlined),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )),
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextField(
                            controller: _roomNameController,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              labelText: 'Room name',
                            ),
                          ),
                        ),
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter stateSetter) {
                            return Column(
                              children: [
                                SwitchListTile(
                                  title: const Text("Lock room with password"),
                                  value: lockedRoom,
                                  onChanged: (val) {
                                    stateSetter(() => lockedRoom = val);
                                  },
                                  secondary: Icon(lockedRoom
                                      ? Icons.lock
                                      : Icons.lock_open),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Visibility(
                                    visible: lockedRoom,
                                    child: TextField(
                                      controller: _roomPasswordController,
                                      maxLines: 1,
                                      decoration: const InputDecoration(
                                        labelText: 'Room password',
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: !lockedRoom,
                                  child: Container(
                                    height: 52,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        // Bouton pour valider modal et naviguer vers la salle en question
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: ElevatedButton(
                              onPressed: () {
                                //TODO: create the room and go in it
                                print(
                                    "Salle ${_roomNameController.text} créée. Is locked = ${lockedRoom}");
                                if (lockedRoom) {
                                  print(
                                      "Mot de passe : ${_roomPasswordController.text}");
                                }
                                GameRoom room = GameRoom(
                                    _roomNameController.text,
                                    globals.username,
                                    lockedRoom,
                                    _roomPasswordController.text);
                                createRoom(room);
                                setState(() {
                                  lockedRoom = false;
                                });
                                Navigator.pop(context);
                              },
                              child: const Text("Ok !")),
                        ),
                      ],
                    ),
                  );
                });
          }),
      body: Column(
        children: [
          TextButton(onPressed: () {}, child: const Text("Ici searchbar")),
          Flexible(
            child: FirebaseAnimatedList(
                query: ref,
                itemBuilder: (BuildContext context, DataSnapshot snapshot_,
                    Animation<double> animation, int index) {
                  Map rooms = snapshot_.value as Map;
                  rooms['key'] = snapshot_.key;
                  return FutureBuilder<DataSnapshot>(
                    builder: (BuildContext context, snapshot) {
                      return Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(rooms['hasPassword']
                                  ? Icons.lock
                                  : Icons.lock_open),
                              title: Text(rooms['name']),
                              subtitle: Text("owner : ${rooms['owner']}"),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10.0, right: 10.0),
                                  child: TextButton(
                                    child: const Text('Join room'),
                                    onPressed: () {
                                      ref
                                          .child('${snapshot_.key}/players')
                                          .push()
                                          .set({"name": globals.username});
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => GameRoomPage(
                                              roomName: rooms['name'],
                                              roomId: rooms['key']),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
          )
        ],
      ),
    );
  }
}

/*
                      builder: (context, snapshot) => RoomCard(
                          roomList[index].name,
                          roomList[index].owner,
                          roomList[index].hasPassword,
                          roomList[index].password));
*/

class GameRoom {
  String name;
  String owner;
  String? password;
  bool hasPassword;

  GameRoom(this.name, this.owner, this.hasPassword, [this.password]);

  Object? toJson() {
    return {
      "name": name,
      "owner": owner,
      "hasPassword": hasPassword,
      if (hasPassword) "password": password
    };
  }
}

class RoomCard extends StatelessWidget {
  String roomName;
  String ownerName;
  bool hasPassword;
  String? password;

  RoomCard(this.roomName, this.ownerName, this.hasPassword, this.password,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(hasPassword ? Icons.lock : Icons.lock_open),
            title: Text(roomName),
            subtitle: Text("owner : ${ownerName}"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
                child: TextButton(
                  child: const Text('Join room'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GameRoomPage(roomName: roomName, roomId: null),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
