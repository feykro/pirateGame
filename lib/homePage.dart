import 'package:flutter/material.dart';

import 'globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    //  Todo: get les rooms depuis le réseau
    //  Todo: ajouter la search bar
    List<GameRoom> roomList = [
      GameRoom("Room test 1", "Etienne", false),
      GameRoom("Private Room 1", "Tom", true, "password")
    ];
    final _inputController = TextEditingController();
    bool isRoomProtected = false;

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
                        title: Text("Create a room"),
                        leading: IconButton(
                          icon: Icon(Icons.cancel_outlined),
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
                            controller: _inputController,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              labelText: 'Room name',
                            ),
                          ),
                        ),
                        SwitchListTile(
                          title: const Text("Make room private"),
                          secondary: const Icon(Icons.lock),
                          value: isRoomProtected,
                          onChanged: (bool value) => setState(() {
                            print("Salut");
                            isRoomProtected = value;
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: ElevatedButton(
                              onPressed: () {
                                //TODO: create the room
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

class PrivateRoomToggle extends StatefulWidget {
  const PrivateRoomToggle({Key? key}) : super(key: key);

  @override
  State<PrivateRoomToggle> createState() => _PrivateRoomToggleState();
}

class _PrivateRoomToggleState extends State<PrivateRoomToggle> {
  @override
  Widget build(BuildContext context) {
    bool isSwitched = false;
    return SwitchListTile(
        title: const Text("Make room private"),
        secondary: const Icon(Icons.lock),
        value: isSwitched,
        onChanged: (bool value) {
          setState(() {
            isSwitched = value;
          });
        });
  }
}

class GameRoom {
  String name;
  String owner;
  String? password;
  bool hasPassword;

  GameRoom(this.name, this.owner, this.hasPassword, [this.password]);
}
