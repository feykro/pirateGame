import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({Key? key, required this.players}) : super(key: key);

  final Map players;

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  List<List> players_ranking = [];

  @override
  void initState() {
    super.initState();
    widget.players.forEach((key, value) {
      players_ranking.add([
        value['name'],
        value['points']
      ]);
    });
    print('AVANT RANKING: $players_ranking');
    players_ranking.sort(
      (a, b) {
        return b[1].compareTo(a[1]);
      },
    );
    print('APRES RANKING: $players_ranking');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 14),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(24, 0, 0, 0),
                      child: Text(
                        'Scores',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: Color(0xFF0F1113),
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Go back to the lobby',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [],
          elevation: 0,
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  direction: Axis.horizontal,
                  runAlignment: WrapAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_1,
                              color: Color(0xFF0F1113),
                              size: 44,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                              child: widget.players.length >= 1
                                  ? Text(
                                      players_ranking[0][0].toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF0F1113),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Text(''),
                            ),
                            widget.players.length >= 1
                                ? Text(
                                    players_ranking[0][1].toString() + ' Points',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF57636C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Text(''),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_2,
                              color: Color(0xFF0F1113),
                              size: 32,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                              child: widget.players.length >= 2
                                  ? Text(
                                      players_ranking[1][0].toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF0F1113),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Text(''),
                            ),
                            widget.players.length >= 2
                                ? Text(
                                    players_ranking[1][1].toString() + ' Points',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF57636C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Text(''),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_3,
                              color: Color(0xFF0F1113),
                              size: 32,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                              child: widget.players.length >= 3
                                  ? Text(
                                      players_ranking[2][0].toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF0F1113),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Text(''),
                            ),
                            widget.players.length >= 3
                                ? Text(
                                    players_ranking[2][1].toString() + ' Points',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF57636C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Text(''),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 17, 20, 0),
                  child: widget.players.length > 3
                      ? Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: players_ranking.sublist(3).map((player) {
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  player[1].toString(),
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Color(0xFF0F1113),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                                  child: Container(
                                    width: 36,
                                    height: (player[1] as int) / 2,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF39D2C0),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                Text(
                                  (players_ranking.indexOf(player) + 1).toString() + 'e',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Color(0xFF0F1113),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  player[0],
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Color(0xFF0F1113),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  direction: Axis.horizontal,
                  runAlignment: WrapAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Color(0xFF39D2C0),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_1,
                              color: Color(0xFF0F1113),
                              size: 44,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                              child: widget.players.length >= 1
                                  ? Text(
                                      players_ranking[0][0].toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF0F1113),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Text(''),
                            ),
                            widget.players.length >= 1
                                ? Text(
                                    players_ranking[0][1].toString() + ' Points',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF57636C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Text(''),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_2,
                              color: Color(0xFF0F1113),
                              size: 32,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                              child: widget.players.length >= 2
                                  ? Text(
                                      players_ranking[1][0].toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF0F1113),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Text(''),
                            ),
                            widget.players.length >= 2
                                ? Text(
                                    players_ranking[1][1].toString() + ' Points',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF57636C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Text(''),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_3,
                              color: Color(0xFF0F1113),
                              size: 32,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                              child: widget.players.length >= 3
                                  ? Text(
                                      players_ranking[2][0].toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF0F1113),
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Text(''),
                            ),
                            widget.players.length >= 3
                                ? Text(
                                    players_ranking[2][1].toString() + ' Points',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF57636C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Text(''),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 17, 20, 0),
                  child: widget.players.length > 3
                      ? Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: players_ranking.sublist(3).map((player) {
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  player[1].toString(),
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Color(0xFF0F1113),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                                  child: Container(
                                    width: 36,
                                    height: (player[1] as int) / 2,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF39D2C0),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                Text(
                                  (players_ranking.indexOf(player) + 1).toString() + 'e',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Color(0xFF0F1113),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  player[0],
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Color(0xFF0F1113),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        )
                      : SizedBox(),
                ),
              
*/
