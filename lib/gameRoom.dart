import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:pirate_app/gameBoard.dart';

import 'globals.dart' as globals;
import 'gamesUtils.dart' as gameUtils;

class GameRoomPage extends StatefulWidget {
  const GameRoomPage({Key? key, required this.roomName, required this.roomId})
      : super(key: key);

  final String roomName;
  final String roomId;

  @override
  State<GameRoomPage> createState() => _GameRoomPageState();
}

//  Todo: ajouter la connexion de compte et modifier le comportement de la page

class _GameRoomPageState extends State<GameRoomPage> {
  bool isReady = false;
  late DatabaseReference ref;
  late DatabaseReference postListRef;

  @override
  Widget build(BuildContext context) {
    ref = FirebaseDatabase.instance.ref('rooms/${widget.roomId}/players');
    postListRef = FirebaseDatabase.instance.ref("rooms/${widget.roomId}/deck");

    postListRef.parent?.onChildAdded.listen((event) {
      final key = event.snapshot.key;
      if (key == 'deck') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameBoardPage(roomId: widget.roomId),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.roomName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              deletePlayerFromRoom();
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
            final postData = {'name': globals.username, 'isReady': isReady};
            final Map<String, Map> updates = {};
            updates[globals.userId] = postData;
            ref.update(updates);
          });
        },
      ),
      bottomNavigationBar: Material(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(15),
        ),
        color: Colors.blueAccent,
        child: InkWell(
          onTap: () async {
            ref =
                FirebaseDatabase.instance.ref('rooms/${widget.roomId}/players');
            final snapshot = await ref.get();
            if (snapshot.exists) {
              Map players = snapshot.value as Map;
              gameUtils.createDeckForRound(players.length, 1, postListRef);
            } else {
              print('No data available.');
            }
          },
          child: const SizedBox(
            height: kToolbarHeight,
            width: double.infinity,
            child: Center(
              child: Text(
                'Start Game',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Flexible(
            child: FirebaseAnimatedList(
                query: ref,
                itemBuilder: (BuildContext context, DataSnapshot snapshot_,
                    Animation<double> animation, int index) {
                  Map players = snapshot_.value as Map;
                  players['key'] = snapshot_.key;
                  return FutureBuilder<DataSnapshot>(
                    builder: (BuildContext context, snapshot) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(players['isReady']
                                ? Icons.check_circle
                                : Icons.person_outline),
                            title: Text(players['name']),
                            subtitle: Text(players['isReady']
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

  void deletePlayerFromRoom() {
    ref.child(globals.userId).remove();
  }
}

class PlayerEntity {
  String name;
  bool isReady;

  PlayerEntity(this.name, this.isReady);
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
