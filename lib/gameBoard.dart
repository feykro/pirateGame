import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pirate_app/scorePage.dart';
import 'dart:async';

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
  String colorForTurn = '';
  bool isPauseTime = false;
  bool haveSuit = false;

  List<int> cards = [];

  Map<String, Map> players = {};
  List<String> playersListInPlayOrder = [];

  List<int> playedCards = [];

  void initState() {
    super.initState();

    _activateDeckListener();
    _activateCardPlayedListener();

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
                  SchedulerBinding.instance!.addPostFrameCallback((_) {
                    showInformationDialog(context);
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
          int cardKey = value as int;
          gameUtils.Card card = gameUtils.deck[cardKey]!;
          playedCards.add(cardKey);
          if (card.type == 'classic' && colorForTurn == '') {
            colorForTurn = card.color as String;
          }
          if (playedCards.length == players.length) {
            // Check qui win le tour, lui donner le point et le désigner en startPlayerIndex
            int winnerIndex = gameUtils.getWinner(playedCards);
            startPlayerIndex =
                (startPlayerIndex + winnerIndex) % players.length;
            players[playersListInPlayOrder[
                (startPlayerIndex + playedCards.length) %
                    playersListInPlayOrder.length]]!['win'] += 1;
            colorForTurn = '';
            isPauseTime = true;
            turn += 1;
            Future.delayed(const Duration(seconds: 3), () {
              setState(() {
                playedCards = [];
                isPauseTime = false;
              });
            });
            if (turn - 1 == round) {
              round += 1;
              Future.delayed(const Duration(seconds: 3), () {
                countPointForAllPlayers();
                newTurn();
                isPauseTime = false;
              });
            }
          }
        });
      }
    });
  }

  countPointForAllPlayers() {
    players.forEach((key, value) {
      if (value['win'] == value['vote']) {
        if (value['vote'] == 0) {
          value['points'] += round * 10;
        } else {
          value['points'] += value['win'] * 20;
        }
      } else {
        if (value['vote'] == 0) {
          value['points'] -= round * 10;
        } else {
          value['points'] -= (value['vote'] - value['win']).abs() * 10;
        }
      }
    });
  }

  asyncInit() async {
    // Recup les joueurs
    players = await gameUtils.getPlayers(playersRef) as Map<String, Map>;
    players.forEach((key, value) {
      value['points'] = 0;
      value['win'] = 0;
      value['bonus'] = 0;
    });
    List<String> playersListKeys = players.keys.toList();
    playersListInPlayOrder =
        playersListKeys.sublist(playersListKeys.indexOf(globals.userId)) +
            playersListKeys.sublist(0, playersListKeys.indexOf(globals.userId));
    startPlayerIndex = playersListInPlayOrder.indexOf(playersListKeys[0]);

    newTurn();
  }

  @override
  Widget build(BuildContext context) {
    String my_score = '';
    if (players[globals.userId] != null &&
        players[globals.userId]!['points'] != null) {
      my_score = players[globals.userId]!['points'].toString() + ' Points';
    }
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
                            if (player['vote'] != -1 && player['win'] != null) {
                              ScoreText = 'Win: ' +
                                  player['win'].toString() +
                                  '/' +
                                  player['vote'].toString();
                            }
                            String pointText = '';
                            if (player['points'] != null) {
                              pointText =
                                  player['points'].toString() + ' Points';
                            }
                            return Container(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Text(player['name']),
                                    Container(
                                        margin: const EdgeInsets.all(15.0),
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.greenAccent,
                                        ),
                                        child: const Text('')),
                                    Text(ScoreText),
                                    Text(pointText)
                                  ],
                                ),
                                decoration: _player ==
                                        playersListInPlayOrder[
                                            (startPlayerIndex +
                                                    playedCards.length) %
                                                playersListInPlayOrder.length]
                                    ? BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10))
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
                                image: DecorationImage(
                                  image: AssetImage(gameUtils.deck[card]!.link),
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
                        haveSuit = haveSuitColor(cards);
                        if (haveSuit &&
                            gameUtils.deck[card]!.type == 'classic' &&
                            gameUtils.deck[card]!.color != colorForTurn) {
                          return InkWell(
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 50),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          gameUtils.deck[card]!.link),
                                      fit: BoxFit.cover,
                                      colorFilter: const ColorFilter.mode(
                                          Colors.grey, BlendMode.saturation),
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          padding: const EdgeInsets.all(15),
                                          height: 300,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 60,
                                                      vertical: 100),
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                            gameUtils
                                                                .deck[card]!
                                                                .link),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: const SizedBox()),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                          );
                        } else {
                          return InkWell(
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 50),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          gameUtils.deck[card]!.link),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const SizedBox()),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    int selected = -1;
                                    if (gameUtils.deck[card]!.type !=
                                        'scary-mary') {
                                      return Center(
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                            ),
                                            padding: const EdgeInsets.all(15),
                                            height: 300,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 60,
                                                        vertical: 100),
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                              gameUtils
                                                                  .deck[card]!
                                                                  .link),
                                                          fit: BoxFit.cover,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: const SizedBox()),
                                                if (isPauseTime == false &&
                                                    playersListInPlayOrder[
                                                            (startPlayerIndex +
                                                                    playedCards
                                                                        .length) %
                                                                playersListInPlayOrder
                                                                    .length] ==
                                                        globals.userId) ...[
                                                  const SizedBox(
                                                    height: 25,
                                                  ),
                                                  TextButton(
                                                    child: const Text(
                                                      'PLAY THIS CARD',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    style: ButtonStyle(
                                                      foregroundColor:
                                                          MaterialStateProperty
                                                              .all(Colors
                                                                  .lightBlueAccent),
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Colors.white),
                                                      shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
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
                                    } else {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return Center(
                                            child: Material(
                                              type: MaterialType.transparency,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.white,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(15),
                                                height: 300,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                selected = 0;
                                                              });
                                                            },
                                                            child: Container(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        60,
                                                                    vertical:
                                                                        100),
                                                                decoration:
                                                                    BoxDecoration(
                                                                        image:
                                                                            DecorationImage(
                                                                          image: AssetImage(gameUtils
                                                                              .deck[card]!
                                                                              .link),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10),
                                                                        border: selected ==
                                                                                0
                                                                            ? Border.all(
                                                                                width: 5,
                                                                                color: Colors.red)
                                                                            : null),
                                                                child: const SizedBox())),
                                                        InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                selected = 1;
                                                              });
                                                            },
                                                            child: Container(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        60,
                                                                    vertical:
                                                                        100),
                                                                decoration:
                                                                    BoxDecoration(
                                                                        image:
                                                                            DecorationImage(
                                                                          image: AssetImage(gameUtils
                                                                              .deck[card]!
                                                                              .link),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10),
                                                                        border: selected ==
                                                                                1
                                                                            ? Border.all(
                                                                                width: 5,
                                                                                color: Colors.red)
                                                                            : null),
                                                                child: const SizedBox())),
                                                      ],
                                                    ),
                                                    if (playersListInPlayOrder[
                                                            (startPlayerIndex +
                                                                    playedCards
                                                                        .length) %
                                                                playersListInPlayOrder
                                                                    .length] ==
                                                        globals.userId) ...[
                                                      const SizedBox(
                                                        height: 25,
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                          'PLAY THIS CARD',
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        style: ButtonStyle(
                                                          foregroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .lightBlueAccent),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .white),
                                                          shape: MaterialStateProperty.all<
                                                                  RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  side: const BorderSide(
                                                                      color: Colors
                                                                          .lightBlueAccent))),
                                                        ),
                                                        onPressed: () {
                                                          if (selected == 0) {
                                                            playCard(66);
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                          if (selected == 1) {
                                                            playCard(67);
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                      )
                                                    ]
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  });
                            },
                          );
                        }
                      }).toList(),
                    ),
                  ],
                ))),
        bottomSheet: Container(
            alignment: Alignment.center,
            height: 45,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(my_score),
                Text(players[globals.userId] != null &&
                        players[globals.userId]!["vote"] != null &&
                        players[globals.userId]!["win"] != null &&
                        players[globals.userId]!["vote"] != -1
                    ? (players[globals.userId]!["win"].toString() +
                        "/" +
                        players[globals.userId]!["vote"].toString() +
                        " win")
                    : "")
              ],
            )));
  }

  bool haveSuitColor(List cards) {
    bool haveCardColorOfSuit = false;
    cards.forEach((card) {
      if (gameUtils.deck[card]!.color == colorForTurn) {
        haveCardColorOfSuit = true;
      }
    });
    return haveCardColorOfSuit;
  }

  void playCard(int card) {
    setState(() {
      if (card == 66 || card == 67) {
        cards.remove(64);
      } else {
        cards.remove(card);
      }
      gameUtils.playCard(card, playCardRef);
    });
  }

  Future<void> newTurn() async {
    if (round == 11) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScorePage(players: players),
        ),
      );
      Navigator.pop(context);
    } else {
      String nextRoundFirstPlayer =
          players.keys.toList()[(round - 1) % players.length];
      startPlayerIndex = playersListInPlayOrder.indexOf(nextRoundFirstPlayer);
      if (globals.userId == nextRoundFirstPlayer && round != 1) {
        gameUtils.createDeckForRound(players.length, round, postListRef);
      }
      players.forEach((key, value) {
        value['vote'] = -1;
        value['win'] = 0;
        value['bonus'] = 0;
      });
    }
  }

  void updatePlayersVote() async {
    Map<String, Map> players_ =
        await gameUtils.getPlayers(playersRef) as Map<String, Map>;
    players_.forEach((key, value) {
      setState(() {
        players[key]!['vote'] = value['vote'];
      });
    });
  }

  Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          int _currentValue = 0;
          double _progress = 0;
          int voteCount = 0;
          late StreamSubscription<DatabaseEvent> _subscription;

          return StatefulBuilder(builder: (context, setState) {
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
                                  image: DecorationImage(
                                    image:
                                        AssetImage(gameUtils.deck[card]!.link),
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
                          // Recup la carte jouée
                          _subscription = voteCountRef.onValue.listen((event) {
                            final value = event.snapshot.value;
                            if (event.snapshot.exists) {
                              setState(() {
                                voteCount = value as int;
                                _progress = (voteCount) / players.length;
                                EasyLoading.showProgress(_progress,
                                    maskType: EasyLoadingMaskType.black,
                                    status: (voteCount).toString() +
                                        '/' +
                                        players.length.toString());
                                if (_progress >= 1) {
                                  _subscription.cancel();
                                  EasyLoading.dismiss();
                                  updatePlayersVote();
                                  Navigator.pop(context);
                                }
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}
