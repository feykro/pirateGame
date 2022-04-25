import 'package:flutter/material.dart';

class GameRoomPage extends StatefulWidget {
  const GameRoomPage({Key? key}) : super(key: key);

  @override
  State<GameRoomPage> createState() => _GameRoomPageState();
}

//  Todo: ajouter la connexion de compte et modifier le comportement de la page

class _GameRoomPageState extends State<GameRoomPage> {
  bool isReady = false;
  @override
  Widget build(BuildContext context) {
    String roomName = "room test 1";
    List<PlayerEntity> playerList = [
      PlayerEntity("Etienne", true),
      PlayerEntity("Tom", true),
      PlayerEntity("Dorian", false)
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: isReady ? Text("Attendez !") : Text("Je suis pret !"),
        icon: isReady ? Icon(Icons.cancel_outlined) : Icon(Icons.check),
        onPressed: () {
          setState(() {
            isReady = !isReady;
          });
        },
      ),
      body: Column(
        children: [
          for (PlayerEntity player in playerList) GameRoomCard(player.name, player.isReady),
          GameRoomCard("Me", isReady)
        ],
      ),
    );
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
