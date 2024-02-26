import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeu du pendu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Word list (replace with your own words)
  final List<String> mots = ["Bonjour", "ordinateur", "fleuve", "maison"];

  // Hidden word
  late String motCache;

  // Number of chances
  int chances = 5;

  // Guessed letters
  List<String> lettresSaisies = [];

  // Generate a random hidden word on state initialization
  @override
  void initState() {
    super.initState();
    _genererMotCache();
  }

  // Generate a random word from the list
  void _genererMotCache() {
    final random = Random();
    motCache = mots[random.nextInt(mots.length)];
  }

  // Check if a letter is in the hidden word
  bool _estDansLeMot(String lettre) {
    return motCache.toUpperCase().contains(lettre.toUpperCase()); // Convert to uppercase for case-insensitive matching
  }

  // Update the game state based on the guessed letter
  void _onLettreSaisie(String lettre) {
    setState(() {
      lettresSaisies.add(lettre.toUpperCase()); // Store uppercase letters
      if (_estDansLeMot(lettre)) {
        // Update displayed word if the letter is correct
        _updateDisplayedWord();
      } else {
        // Decrement chances if the letter is incorrect
        chances--;
      }
    });

    // Check for win or lose conditions
    _checkWinOrLose();
  }

  // Update the displayed word with correctly guessed letters
  void _updateDisplayedWord() {
    final displayedWord = List.filled(motCache.length, '_');
    for (int i = 0; i < motCache.length; i++) {
      if (lettresSaisies.contains(motCache[i].toUpperCase())) {
        displayedWord[i] = motCache[i];
      }
    }
    setState(() {
     motCache = displayedWord.join();

    });
  }

  // Check for win or lose and navigate to the result screen
  void _checkWinOrLose() {
    if (motCache.toUpperCase() == motCache.split('').map((e) => e.toUpperCase()).join()) {
      // Win
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultatScreen(gagne: true)),
      );
    } else if (chances == 0) {
      // Lose
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultatScreen(gagne: false)),
      );
    }
  }

  // Build the game screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jeu du pendu'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Display the hidden word with underscores
            Text(
              motCache.replaceAllMapped(
                RegExp(r'[^\w]'),
                (_) => '_',
              ),
              style: TextStyle(fontSize: 32.0),
            ),
            SizedBox(height: 20.0),
            // Display the number of remaining chances
            Text(
              'Chances restantes: $chances',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            // Build the virtual keyboard (GridView)
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 10,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0, // Added missing property
              children: List.generate(26, (index) {
                // Generate virtual keyboard with letters A to Z
                return InkWell(
                  onTap: () {
                    if (!lettresSaisies.contains(String.fromCharCode(index + 65)) &&
                        !lettresSaisies.contains(String.fromCharCode(index + 97))) {
                      _onLettreSaisie(String.fromCharCode(index + 65));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(index + 65),
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultatScreen extends StatelessWidget {
  final bool gagne;

  const ResultatScreen({Key? key, required this.gagne}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gagne ? 'Vous avez gagné !' : 'Vous avez perdu !'),
      ),
      body: Center(
        child: gagne ? Icon(Icons.sentiment_satisfied) : Icon(Icons.sentiment_very_dissatisfied),
      ),
    );
  }
}
