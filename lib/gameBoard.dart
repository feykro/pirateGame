import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'globals.dart' as globals;
import 'gamesUtils.dart' as gameUtils;

class GameBoardPage extends StatefulWidget {
  const GameBoardPage({Key? key, required this.roomId}) : super(key: key);

  final String roomId;

  @override
  State<GameBoardPage> createState() => _GameBoardPageState();
}

class _GameBoardPageState extends State<GameBoardPage> {
  late DatabaseReference ref;

  final List<String> cards = [
    "Card1",
    "Card2",
    "Card3",
    "Card4",
    "Card5",
    "Card6",
    "Card7",
    "Card8",
    "Card9",
    "Card10",
  ];

  @override
  Widget build(BuildContext context) {
    ref = FirebaseDatabase.instance.ref('rooms/${widget.roomId}/players');
    return Scaffold(
      body: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                        alignment: Alignment.center,
                        height: 100,
                        child: FirebaseAnimatedList(
                            query: ref,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context,
                                DataSnapshot snapshot_,
                                Animation<double> animation,
                                int index) {
                              Map players = snapshot_.value as Map;
                              players['key'] = snapshot_.key;
                              return FutureBuilder<DataSnapshot>(
                                builder: (BuildContext context, snapshot) {
                                  if (players['key'] == globals.userId) {
                                    return SizedBox.shrink();
                                  }
                                  return Column(
                                    children: [
                                      Text(players['name']),
                                      Container(
                                          margin: const EdgeInsets.all(15.0),
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blueAccent)),
                                          child: const Text('5')),
                                      const Text('200 Points')
                                    ],
                                  );
                                },
                              );
                            })),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: -30.0,
                    runSpacing: -50.0,
                    children: cards.map((card) {
                      return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 50.0),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              border: Border.all(color: Colors.blueAccent)),
                          child: Text(card));
                    }).toList(),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: -30.0,
                    runSpacing: -50.0,
                    children: cards.map((card) {
                      return InkWell(
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 50.0),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                border: Border.all(color: Colors.blueAccent)),
                            child: Text(card)),
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0, vertical: 80.0),
                                        margin: EdgeInsets.only(bottom: 40),
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            border: Border.all(
                                                color: Colors.blueAccent)),
                                        child: Text(card)),
                                    TextButton(
                                      autofocus: true,
                                      onPressed: () {
                                        print("Press");
                                      },
                                      style: TextButton.styleFrom(
                                          primary: Colors.white,
                                          backgroundColor:
                                              Colors.teal.withOpacity(0.7),
                                          onSurface: Colors.grey,
                                          shadowColor: Colors.grey,
                                          elevation: 5,
                                          side: const BorderSide(
                                              color: Colors.white, width: 2),
                                          shape: const BeveledRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5))),
                                          textStyle: const TextStyle(
                                            color: Colors.lightBlueAccent,
                                            fontSize: 30,
                                            fontStyle: FontStyle.italic,
                                          )),
                                      child: const Text("Play this card"),
                                    ),
                                  ],
                                );
                              });
                        },
                      );
                    }).toList(),
                  )
                ],
              ))),
      bottomSheet: Container(
          alignment: Alignment.center,
          height: 50,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.blue,
            ],
          )),
          child: const Text('200 Points')),
    );
  }
}
