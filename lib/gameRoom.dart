import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:pirate_app/gameBoard.dart';
import 'dart:async';

import 'globals.dart' as globals;
import 'gamesUtils.dart' as gameUtils;

class GameRoomPage extends StatefulWidget {
  const GameRoomPage({Key? key, required this.roomName, required this.roomId}) : super(key: key);

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

  late StreamSubscription<DatabaseEvent> _subscription;

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref('rooms/${widget.roomId}/players');
    postListRef = FirebaseDatabase.instance.ref("rooms/${widget.roomId}/deck");

    _subscription = postListRef.parent!.onChildAdded.listen((event) async {
      final key = event.snapshot.key;
      if (key == 'deck') {
        _subscription.pause();
        Future.delayed(Duration(seconds: 1), (() async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameBoardPage(roomId: widget.roomId),
            ),
          );
          _subscription.resume();
        }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F4F8),
        automaticallyImplyLeading: false,
        leading: IconButton(
          splashRadius: 30,
          iconSize: 60,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () async {
            deletePlayerFromRoom();
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.roomName,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF14181B),
            fontSize: 28,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF1F4F8),
      floatingActionButton: FloatingActionButton.extended(
        label: isReady ? const Text("Attendez !") : const Text("Je suis pret !"),
        icon: isReady ? const Icon(Icons.cancel_outlined) : const Icon(Icons.check),
        onPressed: () {
          setState(() {
            isReady = !isReady;
            final postData = {
              'name': globals.username,
              'isReady': isReady
            };
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
            ref = FirebaseDatabase.instance.ref('rooms/${widget.roomId}/players');
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
                itemBuilder: (BuildContext context, DataSnapshot snapshot_, Animation<double> animation, int index) {
                  Map players = snapshot_.value as Map;
                  players['key'] = snapshot_.key;
                  return FutureBuilder<DataSnapshot>(
                    builder: (BuildContext context, snapshot) {
                      return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 5,
                                  color: Color(0x1F000000),
                                  offset: Offset(0, 2),
                                )
                              ],
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                          players['name'],
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            color: Color(0xFF14181B),
                                            fontSize: 28,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        Icon(
                                          players['isReady'] ? Icons.check : Icons.close,
                                          color: Colors.black,
                                          size: 24,
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          players['isReady'] ? 'is ready' : 'is not ready yet',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            color: Color(0xFF57636C),
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ));
                      /*
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(players['isReady'] ? Icons.check_circle : Icons.person_outline),
                            title: Text(players['name']),
                            subtitle: Text(players['isReady'] ? 'is ready' : 'is not ready yet'),
                          ),
                        ],
                      );
                      */
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
