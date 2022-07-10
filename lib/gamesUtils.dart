library my_prj.globals;

import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class Card {
  String type;
  int? value;
  String? color;
  Card(this.type, [this.value, this.color]);
}

Future<Map?> getPlayers(DatabaseReference playersRef) async {
  final snapshot = await playersRef.get();
  if (snapshot.exists) {
    Map<String, Map> players = (snapshot.value as Map).cast<String, Map>();
    return players;
  } else {
    print('No data available.');
    return null;
  }
}

void createDeckForRound(
    int nbPlayers, int round, DatabaseReference postListRef) {
  var rng = Random();
  List<int> deck = Iterable<int>.generate(66).toList();
  deck.shuffle();
  deck = deck.sublist(0, nbPlayers * round);
  postListRef.set(deck);
  Map<String, Object?> updates = {};
  updates["VoteCount"] = 0;
  postListRef.parent!.update(updates);
}

Future<List<int>?> getCardFromDeck(
    int round, DatabaseReference postListRef) async {
  List<int> cards = [];
  TransactionResult result = await postListRef.runTransaction((Object? post) {
    if (post == null) {
      return Transaction.abort();
    }
    List<int> deck = (post as List<dynamic>).cast<int>();
    cards = deck.sublist(0, round);
    deck = deck.sublist(round);
    return Transaction.success(deck);
  });
  return cards;
}

void vote(String userId, int vote, DatabaseReference playeref) {
  playeref.child(userId + '/vote').set(vote);
  Map<String, Object?> updates = {};
  updates["VoteCount"] = ServerValue.increment(1);
  playeref.parent!.update(updates);
}

void playCard(int cardId, DatabaseReference playCardRef) {
  playCardRef.set(cardId);
}

final Map<int, Card> deck = {
  //Red Cards 1-13
  0: Card('classic', 1, 'red'),
  1: Card('classic', 2, 'red'),
  2: Card('classic', 3, 'red'),
  3: Card('classic', 4, 'red'),
  4: Card('classic', 5, 'red'),
  5: Card('classic', 6, 'red'),
  6: Card('classic', 7, 'red'),
  7: Card('classic', 8, 'red'),
  8: Card('classic', 9, 'red'),
  9: Card('classic', 10, 'red'),
  10: Card('classic', 11, 'red'),
  11: Card('classic', 12, 'red'),
  12: Card('classic', 13, 'red'),

  //Blue Cards 1-13
  13: Card('classic', 1, 'blue'),
  14: Card('classic', 2, 'blue'),
  15: Card('classic', 3, 'blue'),
  16: Card('classic', 4, 'blue'),
  17: Card('classic', 5, 'blue'),
  18: Card('classic', 6, 'blue'),
  19: Card('classic', 7, 'blue'),
  20: Card('classic', 8, 'blue'),
  21: Card('classic', 9, 'blue'),
  22: Card('classic', 10, 'blue'),
  23: Card('classic', 11, 'blue'),
  24: Card('classic', 12, 'blue'),
  25: Card('classic', 13, 'blue'),

  //Yellow Cards 1-13
  26: Card('classic', 1, 'yellow'),
  27: Card('classic', 2, 'yellow'),
  28: Card('classic', 3, 'yellow'),
  29: Card('classic', 4, 'yellow'),
  30: Card('classic', 5, 'yellow'),
  31: Card('classic', 6, 'yellow'),
  32: Card('classic', 7, 'yellow'),
  33: Card('classic', 8, 'yellow'),
  34: Card('classic', 9, 'yellow'),
  35: Card('classic', 10, 'yellow'),
  36: Card('classic', 11, 'yellow'),
  37: Card('classic', 12, 'yellow'),
  38: Card('classic', 13, 'yellow'),

  //Black Cards 1-13
  39: Card('classic', 1, 'black'),
  40: Card('classic', 2, 'black'),
  41: Card('classic', 3, 'black'),
  42: Card('classic', 4, 'black'),
  43: Card('classic', 5, 'black'),
  44: Card('classic', 6, 'black'),
  45: Card('classic', 7, 'black'),
  46: Card('classic', 8, 'black'),
  47: Card('classic', 9, 'black'),
  48: Card('classic', 10, 'black'),
  49: Card('classic', 11, 'black'),
  50: Card('classic', 12, 'black'),
  51: Card('classic', 13, 'black'),

  //Pirates 5
  52: Card('pirate'),
  53: Card('pirate'),
  54: Card('pirate'),
  55: Card('pirate'),
  56: Card('pirate'),

  //Escapes 5
  57: Card('escape'),
  58: Card('escape'),
  59: Card('escape'),
  60: Card('escape'),
  61: Card('escape'),

  //Mermaids 2
  62: Card('mermaid'),
  63: Card('mermaid'),

  //Scary Mary 1
  64: Card('scary-mary'),

  //Skull King 1
  65: Card('skull-king'),

  //Scary Mary pirate
  66: Card('scary-mary-pirate'),

  //Scary Mary escape
  67: Card('scary-mary-escape')
};

//cartes la liste des indice dans la hashmap des cartes dans l'ordre du premier a jouer au dernier
int getWinner(List<int> indiceMapCarte) {
  int nbCarte = indiceMapCarte.length;
  if (nbCarte == 0) {
    return -1;
  } else {
    int indiceHigherCarte = 0;
    for (int i = 1; i != nbCarte; i++) {
      indiceHigherCarte = carteCmp(indiceMapCarte, indiceHigherCarte, i);
    }
    return indiceHigherCarte;
  }
}

int carteCmp(List<int> cartes, int carteA, int carteB) {
  int indiceCarteA = cartes[carteA];
  int indiceCarteB = cartes[carteB];

  if (indiceCarteA < 13 && indiceCarteB < 13) {
    if (indiceCarteA > indiceCarteB) {
      return carteA;
    } else {
      return carteB;
    }
  }
  if (indiceCarteA < 26 && indiceCarteB < 26) {
    if (indiceCarteA > indiceCarteB) {
      return carteA;
    } else {
      return carteB;
    }
  }
  if (indiceCarteA < 39 && indiceCarteB < 39) {
    if (indiceCarteA > indiceCarteB) {
      return carteA;
    } else {
      return carteB;
    }
  }
  if (indiceCarteA < 52 && indiceCarteB < 52) {
    if (indiceCarteA > indiceCarteB) {
      return carteA;
    } else {
      return carteB;
    }
  }

  //si A est un pirate
  if ((indiceCarteA > 51 && indiceCarteA < 57) || indiceCarteA == 66) {
    if (indiceCarteB == 65) {
      return carteB;
    } else {
      return carteA;
    }
  }

  //si A est une mermaid
  if ((indiceCarteA == 62 || indiceCarteA == 63)) {
    if ((indiceCarteB > 51 && indiceCarteB < 57) || indiceCarteB == 66) {
      return carteB;
    } else {
      return carteA;
    }
  }

  //si A est un skullking
  if (indiceCarteA == 65) {
    if ((indiceCarteB == 62 || indiceCarteB == 63)) {
      return carteB;
    } else {
      return carteA;
    }
  }

  //si A est une escape
  if ((indiceCarteA > 56 && indiceCarteA < 61) || indiceCarteA == 67) {
    if ((indiceCarteA > 56 && indiceCarteA < 61) || indiceCarteA == 67) {
      return carteA;
    } else {
      return carteB;
    }
  }

  //si pas la meme couleur
  if (deck[indiceCarteA]!.color != deck[indiceCarteB]!.color &&
      deck[indiceCarteB]!.color != 'black') {
    return carteA;
  }

  return carteB;
}
