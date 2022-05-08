import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GameRoomPage extends StatefulWidget {
  const GameRoomPage({Key? key, required this.roomName, required this.roomId})
      : super(key: key);

  final String roomName;
  final String? roomId;

  @override
  State<GameRoomPage> createState() => _GameRoomPageState();
}

//  Todo: ajouter la connexion de compte et modifier le comportement de la page

class _GameRoomPageState extends State<GameRoomPage> {
  bool isReady = false;
  DatabaseReference ref =
      FirebaseDatabase.instance.ref('rooms/$roomId/players');

  List<PlayerEntity> playerList = [];
  static get roomId => null;

  @override
  Widget build(BuildContext context) {
    ref.onChildAdded.listen((event) {
      playerList.add(PlayerEntity.fromJson(event.snapshot.value));
    });

    ref.onChildRemoved.listen((event) {
      playerList.remove(PlayerEntity.fromJson(event.snapshot.value));
    });

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.roomName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              //deletePlayerFromRoom();
              Navigator.pop(context);
            },
          )),
      floatingActionButton: FloatingActionButton.extended(
        label:
            isReady ? const Text("Attendez !") : const Text("Je suis pret !"),
        icon: isReady
            ? const Icon(Icons.cancel_outlined)
            : const Icon(Icons.check),
        onPressed: () {
          setState(() {
            isReady = !isReady;
          });
        },
      ),
      body: Column(
        children: [
          Flexible(
            child: FirebaseAnimatedList(
                query: ref,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  return FutureBuilder<DataSnapshot>(
                    builder: (BuildContext context, snapshot) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(playerList[index].isReady
                                ? Icons.check_circle
                                : Icons.person_outline),
                            title: Text(playerList[index].name),
                            subtitle: Text(playerList[index].isReady
                                ? 'is ready'
                                : 'is not ready yet'),
                          ),
                        ],
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

class PlayerEntity {
  String name;
  bool isReady;

  PlayerEntity(this.name, this.isReady);

  static PlayerEntity fromJson(Object? value) {
    Map<String, Object?> map = value as Map<String, Object?>;
    return PlayerEntity(map["name"] as String, map["isReady"] as bool);
  }
}

class GameRoomCard extends StatelessWidget {
  String playerName;
  bool isReady;

  GameRoomCard(this.playerName, this.isReady, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(isReady ? Icons.check_circle : Icons.person_outline),
          title: Text(playerName),
          subtitle: Text("${isReady ? 'is ready' : 'is not ready yet'}"),
        ),
      ],
    );
  }
}
