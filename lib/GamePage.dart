import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Game !"),
          // todo: enlever le retour arrière pour éviter les quite
        ),
        body: ListView(
          children: new List.generate(10, (index) => new ListTile()),
        ));
  }
}
