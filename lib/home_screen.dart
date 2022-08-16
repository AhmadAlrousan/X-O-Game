import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xo_game/game_logic.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  String activePlaer = 'X';
  bool gameOver = false;
  int turn = 0;
  String result = '';
  Game game = Game();
  bool isSwitched = false;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: MediaQuery.of(context).orientation == Orientation.portrait
            ? Column(
                children: [
                  ...firstBlock(),
                  _buildExpanded(context),
                  ...lastBlock()
                ],
              )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...firstBlock(),
                        SizedBox(height: 20,),
                        ...lastBlock()],
                    ),
                  ),
                  _buildExpanded(context),
                ],
              ),
      ),
    );
  }

  List<Widget> firstBlock() {
    return [
      SizedBox(height: 20,),
      SwitchListTile.adaptive(
          title: const Text(
            "Turn on / oof tow player",
            style: TextStyle(color: Colors.white, fontSize: 28),
            textAlign: TextAlign.center,
          ),
          value: isSwitched,
          onChanged: (bool newValue) {
            setState(() {
              isSwitched = newValue;
            });
          }),
      SizedBox(height: 30,),
      Text(
        "It's $activePlaer turn".toUpperCase(),
        style: const TextStyle(color: Colors.red, fontSize: 40),
        textAlign: TextAlign.center,
      ),
    ];
  }

  List<Widget> lastBlock() {
    return [
      Text(
        result,
        style: const TextStyle(color: Colors.tealAccent, fontSize: 30),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 30,),
      OutlinedButton.icon(
        onPressed: () {
          setState(() {
            Player.playerX = [];
            Player.playerO = [];
            activePlaer = 'X';
            gameOver = false;
            turn = 0;
            result = '';
          });
        },
        icon: const Icon(Icons.replay),
        label: const Text("Restart the game"),
      ),
      SizedBox(height: 30,)
    ];
  }

  Expanded _buildExpanded(BuildContext context) {
    return Expanded(
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 1.0,
        children: List.generate(
            9,
            (index) => InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: gameOver ? null : () => _onTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                          Player.playerX.contains(index)
                              ? 'X'
                              : Player.playerO.contains(index)
                                  ? 'O'
                                  : '',
                          style: Player.playerX.contains(index)
                              ? TextStyle(color: Colors.red, fontSize: 50)
                              : TextStyle(color: Colors.blue, fontSize: 50)),
                    ),
                  ),
                )),
      ),
    );
  }

  _onTap(int index) async {
    if ((!Player.playerX.contains(index) || Player.playerX.isEmpty) &&
        (!Player.playerO.contains(index) || Player.playerO.isEmpty)) {
      game.playGame(index, activePlaer);

      updateState();

      if (!isSwitched && !gameOver && turn != 9) {
        await game.autoPlay(activePlaer);
        updateState();
      }
    }
  }

  void updateState() {
    setState(() {
      activePlaer = activePlaer == 'X' ? 'O' : 'X';
      turn++;

      String winerPlayer = game.checkWinneer();
      if (winerPlayer != '') {
        gameOver = true;
        result = '$winerPlayer is the winner';
      } else if (!gameOver && turn == 9) {
        result = "Drow !!";
      }
    });
  }
}
