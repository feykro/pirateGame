library my_prj.globals;

import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class Card {
  String type;
  String link;
  int? value;
  String? color;
  Card(this.type, this.link, [this.value, this.color]);
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

//cartes la liste des indice dans la hashmap des cartes dans l'ordre du premier a jouer au dernier
int getWinner(List<int> cartes) {
  int nbCarte = cartes.length;
  if (nbCarte == 0) {
    return -1;
  } else {
    int indiceHigherCarte = 0;
    for (int i = 1; i != nbCarte; i++) {
      indiceHigherCarte = carteCmp(cartes, indiceHigherCarte, i);
      print('Winner $indiceHigherCarte');
    }
    return indiceHigherCarte;
  }
}

int carteCmp(List<int> cartes, int carteA, int carteB) {
  int indiceCarteA = cartes[carteA];
  int indiceCarteB = cartes[carteB];

  //si meme couleur
  if (deck[indiceCarteA]!.type == 'classic' &&
      deck[indiceCarteB]!.type == 'classic' &&
      deck[indiceCarteA]!.color == deck[indiceCarteB]!.color) {
    if (indiceCarteA > indiceCarteB) {
      return carteA;
    } else {
      return carteB;
    }
  }

  //si A est un pirate
  if (deck[indiceCarteA]!.type == 'pirate' ||
      deck[indiceCarteA]!.type == 'scary-mary-pirate') {
    if (deck[indiceCarteB]!.type == 'skull-king') {
      return carteB;
    } else {
      return carteA;
    }
  }

  //si A est une mermaid
  if (deck[indiceCarteA]!.type == 'mermaid') {
    if (deck[indiceCarteB]!.type == 'pirate' ||
        deck[indiceCarteB]!.type == 'scary-mary-pirate') {
      return carteB;
    } else {
      return carteA;
    }
  }

  //si A est un skullking
  if (deck[indiceCarteA]!.type == 'skull-king') {
    if (deck[indiceCarteB]!.type == 'mermaid') {
      return carteB;
    } else {
      return carteA;
    }
  }

  //si A est une escape
  if (deck[indiceCarteA]!.type == 'escape' ||
      deck[indiceCarteA]!.type == 'scary-mary-escape') {
    if (deck[indiceCarteB]!.type == 'escape' ||
        deck[indiceCarteB]!.type == 'scary-mary-escape') {
      return carteA;
    } else {
      return carteB;
    }
  }

  //si pas la meme couleur
  if (deck[indiceCarteA]!.type == 'classic' &&
      deck[indiceCarteB]!.type == 'classic' &&
      deck[indiceCarteA]!.color != deck[indiceCarteB]!.color &&
      deck[indiceCarteB]!.color != 'black') {
    return carteA;
  }
  return carteB;
}

final Map<int, Card> deck = {
  //Red Cards 1-13
  0: Card('classic', 'images/red-1.png', 1, 'red'),
  1: Card('classic', 'images/red-2.png', 2, 'red'),
  2: Card('classic', 'images/red-3.png', 3, 'red'),
  3: Card('classic', 'images/red-4.png', 4, 'red'),
  4: Card('classic', 'images/red-5.png', 5, 'red'),
  5: Card('classic', 'images/red-6.png', 6, 'red'),
  6: Card('classic', 'images/red-7.png', 7, 'red'),
  7: Card('classic', 'images/red-8.png', 8, 'red'),
  8: Card('classic', 'images/red-9.png', 9, 'red'),
  9: Card('classic', 'images/red-10.png', 10, 'red'),
  10: Card('classic', 'images/red-11.png', 11, 'red'),
  11: Card('classic', 'images/red-12.png', 12, 'red'),
  12: Card('classic', 'images/red-13.png', 13, 'red'),

  //Blue Cards 1-13
  13: Card('classic', 'images/blue-1.png', 1, 'blue'),
  14: Card('classic', 'images/blue-2.png', 2, 'blue'),
  15: Card('classic', 'images/blue-3.png', 3, 'blue'),
  16: Card('classic', 'images/blue-4.png', 4, 'blue'),
  17: Card('classic', 'images/blue-5.png', 5, 'blue'),
  18: Card('classic', 'images/blue-6.png', 6, 'blue'),
  19: Card('classic', 'images/blue-7.png', 7, 'blue'),
  20: Card('classic', 'images/blue-8.png', 8, 'blue'),
  21: Card('classic', 'images/blue-9.png', 9, 'blue'),
  22: Card('classic', 'images/blue-10.png', 10, 'blue'),
  23: Card('classic', 'images/blue-11.png', 11, 'blue'),
  24: Card('classic', 'images/blue-12.png', 12, 'blue'),
  25: Card('classic', 'images/blue-13.png', 13, 'blue'),

  //Yellow Cards 1-13
  26: Card('classic', 'images/yellow-1.png', 1, 'yellow'),
  27: Card('classic', 'images/yellow-2.png', 2, 'yellow'),
  28: Card('classic', 'images/yellow-3.png', 3, 'yellow'),
  29: Card('classic', 'images/yellow-4.png', 4, 'yellow'),
  30: Card('classic', 'images/yellow-5.png', 5, 'yellow'),
  31: Card('classic', 'images/yellow-6.png', 6, 'yellow'),
  32: Card('classic', 'images/yellow-6.png', 7, 'yellow'),
  33: Card('classic', 'images/yellow-8.png', 8, 'yellow'),
  34: Card('classic', 'images/yellow-9.png', 9, 'yellow'),
  35: Card('classic', 'images/yellow-10.png', 10, 'yellow'),
  36: Card('classic', 'images/yellow-11.png', 11, 'yellow'),
  37: Card('classic', 'images/yellow-12.png', 12, 'yellow'),
  38: Card('classic', 'images/yellow-13.png', 13, 'yellow'),

  //Black Cards 1-13
  39: Card('classic', 'images/black-1.png', 1, 'black'),
  40: Card('classic', 'images/black-2.png', 2, 'black'),
  41: Card('classic', 'images/black-3.png', 3, 'black'),
  42: Card('classic', 'images/black-4.png', 4, 'black'),
  43: Card('classic', 'images/black-5.png', 5, 'black'),
  44: Card('classic', 'images/black-6.png', 6, 'black'),
  45: Card('classic', 'images/black-7.png', 7, 'black'),
  46: Card('classic', 'images/black-8.png', 8, 'black'),
  47: Card('classic', 'images/black-9.png', 9, 'black'),
  48: Card('classic', 'images/black-10.png', 10, 'black'),
  49: Card('classic', 'images/black-11.png', 11, 'black'),
  50: Card('classic', 'images/black-12.png', 12, 'black'),
  51: Card('classic', 'images/black-13.png', 13, 'black'),

  //Pirates 5
  52: Card('pirate', 'images/pirate-badeye-joe.png'),
  53: Card('pirate', 'images/pirate-betty-brave.png'),
  54: Card('pirate', 'images/pirate-cortuga-jack.png'),
  55: Card('pirate', 'images/pirate-evil-emmy.png'),
  56: Card('pirate', 'images/pirate-harry-the-giant.png'),

  //Escapes 5
  57: Card('escape', 'images/escape.png'),
  58: Card('escape', 'images/escape.png'),
  59: Card('escape', 'images/escape.png'),
  60: Card('escape', 'images/escape.png'),
  61: Card('escape', 'images/escape.png'),

  //Mermaids 2
  62: Card('mermaid', 'images/mermaid.png'),
  63: Card('mermaid', 'images/mermaid.png'),

  //Scary Mary 1
  64: Card('scary-mary', 'images/scary-mary.png'),

  //Skull King 1
  65: Card('skull-king', 'images/skull-king.png'),

  //Scary Mary pirate
  66: Card('scary-mary-pirate', 'images/scary-mary.png'),

  //Scary Mary escape
  67: Card('scary-mary-escape', 'images/scary-mary.png')
};
