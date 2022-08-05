import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:animated_segment/segment_animation.dart';

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

    void joinRoom(Map rooms) {
      DatabaseReference playerRef = ref.child('${rooms['key']}/players').push();
      globals.userId = playerRef.key!;
      playerRef.set(
        {
          "name": globals.username,
          "isReady": false,
          "vote": -1
        },
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameRoomPage(roomName: rooms['name'], roomId: rooms['key']),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${globals.username}"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
          elevation: 10.0,
          label: const Text("Create room"),
          icon: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  lockedRoom = false;
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          builder: (BuildContext context, StateSetter stateSetter) {
                            return Column(
                              children: [
                                AnimatedSegment(
                                  segmentNames: const [
                                    "Public",
                                    "Private"
                                  ],
                                  onSegmentChanged: (index) {
                                    stateSetter(() => index == 0 ? lockedRoom = false : lockedRoom = true);
                                  },
                                  backgroundColor: Colors.blueGrey,
                                  segmentTextColor: Colors.white,
                                  rippleEffectColor: Colors.blue,
                                  selectedSegmentColor: Colors.blue,
                                ),
                                /*
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
                                */
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                        SizedBox(
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  GameRoom room = GameRoom(_roomNameController.text, globals.username, lockedRoom, _roomPasswordController.text);
                                  createRoom(room);
                                  setState(() {
                                    lockedRoom = false;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("Ok !")),
                          ),
                        )
                      ],
                    ),
                  );
                });
          }),
      body: Column(
        children: [
          //TextButton(onPressed: () {}, child: const Text("Ici searchbar")),
          Flexible(
            child: FirebaseAnimatedList(
                query: ref,
                itemBuilder: (BuildContext context, DataSnapshot snapshot_, Animation<double> animation, int index) {
                  Map rooms = snapshot_.value as Map;
                  rooms['key'] = snapshot_.key;
                  int nb_players = 0;
                  if (rooms['players'] != null) {
                    nb_players = (rooms['players'] as Map).length;
                  }
                  return FutureBuilder<DataSnapshot>(
                    builder: (BuildContext context, snapshot) {
                      return Card(
                          elevation: 0,
                          margin: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
                          color: Color(0xFFF1F4F8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
                            child: InkWell(
                              onTap: () {
                                if (nb_players < 6) {
                                  if (rooms['hasPassword'] as bool) {
                                    // display modal
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return buildModalScaffold(rooms, joinRoom);
                                        });
                                  } else {
                                    joinRoom(rooms);
                                  }
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF1F4F8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(8, 8, 12, 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        rooms['hasPassword'] ? Icons.lock_outline : Icons.lock_open_outlined,
                                        color: Colors.black,
                                        size: 50,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    rooms['name'],
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                      fontFamily: 'Outfit',
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text('$nb_players/6')
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Text(
                                                    'Created by ${rooms['owner']}',
                                                    style: TextStyle(
                                                      fontFamily: 'Outfit',
                                                      color: Color(0xFF57636C),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          /*
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(rooms['hasPassword'] ? Icons.lock : Icons.lock_open),
                              title: Text(rooms['name']),
                              subtitle: Text("owner : ${rooms['owner']}"),
                              trailing: Text('$nb_players/6'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
                                  child: TextButton(
                                    child: const Text('Join room', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                                    onPressed: () {
                                      if (nb_players < 6) {
                                        if (rooms['hasPassword'] as bool) {
                                          // display modal
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return buildModalScaffold(rooms, joinRoom);
                                              });
                                        } else {
                                          joinRoom(rooms);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),*/
                          );
                    },
                  );
                }),
          )
        ],
      ),
    );
  }

  Widget buildModalScaffold(Map rooms, Function joinRoom) {
    var _textEditingController = TextEditingController();

    var isPasswordOk = false;
    return Scaffold(
      appBar: AppBar(
          title: const Text("Please enter password"),
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
              obscureText: true,
              controller: _textEditingController,
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
          ),
          // Bouton pour valider modal et naviguer vers la salle en question
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ElevatedButton(
                onPressed: () {
                  if (rooms["password"] as String == _textEditingController.text) {
                    Navigator.of(context).pop();
                    joinRoom(rooms);
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Erreur"),
                            content: Text("Le mot de passe est incorrect."),
                            actions: [
                              TextButton(
                                child: const Text("ok"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  }
                },
                child: const Text("Rejoindre")),
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

  Object? toJson() {
    return {
      "name": name,
      "owner": owner,
      "hasPassword": hasPassword,
      if (hasPassword) "password": password,
      "VoteCount": 0
    };
  }
}

class RoomCard extends StatelessWidget {
  String roomName;
  String ownerName;
  bool hasPassword;
  String? password;

  RoomCard(this.roomName, this.ownerName, this.hasPassword, this.password, {Key? key}) : super(key: key);

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
                        builder: (context) => GameRoomPage(roomName: roomName, roomId: ''),
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
