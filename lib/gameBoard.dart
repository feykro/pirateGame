import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:numberpicker/numberpicker.dart';
import 'dart:io';

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
  late DatabaseReference playCardRef;
  late DatabaseReference postListRef;

  int startPlayerIndex = 0;
  int round = 1;
  int turn = 1;

  int _currentValue = 0;

  List<int> cards = [];

  Map<String, Map> players = {};
  List<String> playersListInPlayOrder = [];

  Map<int, int> playedCards = {};

  get playersCopy => null;

  void initState() {
    super.initState();
    asyncInit();
  }

  asyncInit() async {
    postListRef = FirebaseDatabase.instance.ref('rooms/${widget.roomId}/deck');
    playCardRef =
        FirebaseDatabase.instance.ref('rooms/${widget.roomId}/playedCard');

    // Recup les joueurs
    players = await gameUtils.getPlayers(
            FirebaseDatabase.instance.ref('rooms/${widget.roomId}/players'))
        as Map<String, Map>;
    List<String> playersListKeys = players.keys.toList();
    playersListInPlayOrder =
        playersListKeys.sublist(playersListKeys.indexOf(globals.userId)) +
            playersListKeys.sublist(0, playersListKeys.indexOf(globals.userId));
    startPlayerIndex = playersListInPlayOrder.indexOf(playersListKeys[0]);
    print('players : ' + players.toString());
    print('Start index ' + startPlayerIndex.toString());

    newTurn();

    // Recup la carte jouée
    playCardRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (event.snapshot.exists) {
        print(value);
        playedCards[(startPlayerIndex + playedCards.length) % players.length] =
            value as int;
        print('Carte played');
        print(playedCards);
      }
    });

    // Recup ses cartes à chaque round
    postListRef.parent?.onChildAdded.listen((event) {
      final key = event.snapshot.key;
      if (key == 'deck') {
        gameUtils
            .getCardFromDeck(round,
                FirebaseDatabase.instance.ref('rooms/${widget.roomId}/deck'))
            .then((cardForTurn) => setState(() {
                  turn = 1;
                  print('cardForTurn ' + cardForTurn.toString());
                  cardForTurn?.forEach((card) {
                    cards.add(card);
                  });
                  playedCards = {};
                  SchedulerBinding.instance!.addPostFrameCallback((_) {
                    showVoteDialog();
                  });
                }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: players.entries
                        .map((player) {
                          Map playerAttirbutes = player.value as Map;
                          if (player.key == globals.userId) {
                            return Container(color: Colors.black);
                          }
                          return Container(
                              child: Column(
                                children: [
                                  Text(playerAttirbutes['name']),
                                  Container(
                                      margin: const EdgeInsets.all(15.0),
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blueAccent)),
                                      child: const Text('5')),
                                  const Text('Win: 2/2'),
                                  const Text('200 Points')
                                ],
                              ),
                              decoration: player.key ==
                                      playersListInPlayOrder[(startPlayerIndex +
                                              playedCards.length) %
                                          playersListInPlayOrder.length]
                                  ? BoxDecoration(
                                      border:
                                          Border.all(color: Colors.blueAccent))
                                  : null);
                        })
                        .where((element) => element.color != Colors.black)
                        .toList(),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: -30.0,
                    runSpacing: -50.0,
                    children: playedCards.entries.map((card) {
                      return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 50),
                          decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage("images/skullking.jpg"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10)),
                          child: const SizedBox());
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
                                horizontal: 30, vertical: 50),
                            decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage("images/skullking.jpg"),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10)),
                            child: const SizedBox()),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Center(
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(15),
                                      height: 300,
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 60,
                                                      vertical: 100),
                                              decoration: BoxDecoration(
                                                  image: const DecorationImage(
                                                    image: AssetImage(
                                                        "images/skullking.jpg"),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: const SizedBox()),
                                          const SizedBox(
                                            height: 25,
                                          ),
                                          if (playersListInPlayOrder[
                                                  (startPlayerIndex +
                                                          playedCards.length) %
                                                      playersListInPlayOrder
                                                          .length] ==
                                              globals.userId) ...[
                                            TextButton(
                                              child: const Text(
                                                'PLAY THIS CARD',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              style: ButtonStyle(
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.lightBlueAccent),
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.white),
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        side: const BorderSide(
                                                            color: Colors
                                                                .lightBlueAccent))),
                                              ),
                                              onPressed: () {
                                                playCard(card);
                                                Navigator.pop(context);
                                              },
                                            )
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                      );
                    }).toList(),
                  ),
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

  void playCard(int card) {
    setState(() {
      cards.remove(card);
      gameUtils.playCard(card, playCardRef);
      if ((startPlayerIndex + playedCards.length) % players.length ==
          startPlayerIndex) {
        // Check qui win le tour, lui donner le point et le désigner en startPlayerIndex
        turn += 1;
        playedCards = {};
        if (turn - 1 == round) {
          if (round == 10) {
          } else {
            round += 1;
            Future.delayed(const Duration(seconds: 3), () {
              newTurn();
            });
          }
        }
      }
    });
  }

  Future<void> newTurn() async {
    String nextRoundFirstPlayer =
        players.keys.toList()[(round - 1) % players.length];
    startPlayerIndex = playersListInPlayOrder.indexOf(nextRoundFirstPlayer);
    if (globals.userId == nextRoundFirstPlayer && round != 1) {
      print(globals.userId);
      print(nextRoundFirstPlayer);
      print(players);
      gameUtils.createDeckForRound(players.length, round, postListRef);
    }
  }

  void showVoteDialog() {
    _currentValue = 0;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(15),
                height: 350,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: -25.0,
                      runSpacing: -50.0,
                      children: cards.map((card) {
                        return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 50),
                            decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage("images/skullking.jpg"),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10)),
                            child: const SizedBox());
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    NumberPicker(
                      value: _currentValue,
                      minValue: 0,
                      maxValue: round,
                      itemHeight: 70,
                      axis: Axis.horizontal,
                      onChanged: (value) =>
                          setState(() => _currentValue = value),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black26),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextButton(
                      child: const Text(
                        'OK',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.lightBlueAccent),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                        color: Colors.lightBlueAccent))),
                      ),
                      onPressed: () {
                        // Vote
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
