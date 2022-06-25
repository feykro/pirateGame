import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  late DatabaseReference playersRef =
      FirebaseDatabase.instance.ref('rooms/${widget.roomId}/players');
  late DatabaseReference playCardRef =
      FirebaseDatabase.instance.ref('rooms/${widget.roomId}/playedCard');
  late DatabaseReference postListRef =
      FirebaseDatabase.instance.ref('rooms/${widget.roomId}/deck');
  late DatabaseReference voteCountRef =
      FirebaseDatabase.instance.ref('rooms/${widget.roomId}/VoteCount');

  int startPlayerIndex = 0;
  int round = 1;
  int turn = 1;

  int _currentValue = 0;

  int voteCount = 0;

  List<int> cards = [];

  Map<String, Map> players = {};
  List<String> playersListInPlayOrder = [];

  List<int> playedCards = [];

  get playersCopy => null;

  void initState() {
    super.initState();

    _activateDeckListener();
    _activateCardPlayedListener();
    _activateVoteCountListener();

    asyncInit();
  }

  void _activateDeckListener() {
    // Recup ses cartes à chaque round
    postListRef.parent?.onChildAdded.listen((event) {
      final key = event.snapshot.key;
      if (key == 'deck') {
        gameUtils
            .getCardFromDeck(round, postListRef)
            .then((cardForTurn) => setState(() {
                  turn = 1;
                  cardForTurn?.forEach((card) {
                    cards.add(card);
                  });
                  playedCards = [];
                  SchedulerBinding.instance!.addPostFrameCallback((_) {
                    _currentValue = 0;
                    showVoteDialog();
                  });
                }));
      }
    });
  }

  void _activateCardPlayedListener() {
    // Recup la carte jouée
    playCardRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (event.snapshot.exists) {
        setState(() {
          playedCards.add(value as int);
        });
      }
    });
  }

  void _activateVoteCountListener() {
    // Recup la carte jouée
    voteCountRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (event.snapshot.exists) {
        setState(() {
          voteCount = value as int;
        });
      }
    });
  }

  asyncInit() async {
    // Recup les joueurs
    players = await gameUtils.getPlayers(playersRef) as Map<String, Map>;
    List<String> playersListKeys = players.keys.toList();
    playersListInPlayOrder =
        playersListKeys.sublist(playersListKeys.indexOf(globals.userId)) +
            playersListKeys.sublist(0, playersListKeys.indexOf(globals.userId));
    startPlayerIndex = playersListInPlayOrder.indexOf(playersListKeys[0]);

    newTurn();
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
                    children: playersListInPlayOrder
                        .map((_player) {
                          Map player = players[_player] as Map;
                          if (_player == globals.userId) {
                            return Container(color: Colors.black);
                          }
                          String ScoreText = '';
                          if (voteCount == players.length) {
                            ScoreText = 'Win: ' +
                                player['vote'].toString() +
                                '/' +
                                round.toString();
                          }
                          return Container(
                              child: Column(
                                children: [
                                  Text(player['name']),
                                  Container(
                                      margin: const EdgeInsets.all(15.0),
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blueAccent)),
                                      child: const Text('5')),
                                  Text(ScoreText),
                                  const Text('200 Points')
                                ],
                              ),
                              decoration: _player ==
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
                    children: playedCards.map((card) {
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
        if (turn - 1 == round) {
          if (round == 10) {
            Navigator.pop(context);
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
      gameUtils.createDeckForRound(players.length, round, postListRef);
    }
  }

  void showVoteDialog() {
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
                        gameUtils.vote(
                            globals.userId, _currentValue, playersRef);
                        double _progress = 0;
                        EasyLoading.showProgress(_progress,
                            maskType: EasyLoadingMaskType.black,
                            status: (voteCount + 1).toString() +
                                '/' +
                                players.length.toString());
                        _progress = (voteCount + 1) / players.length;
                        if (_progress >= 1) {
                          EasyLoading.dismiss();
                          Navigator.pop(context);
                        }
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