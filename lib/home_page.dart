import 'package:flutter/material.dart';
import 'package:lab33_qnais/pallete.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lab33_qnais/feature_box.dart';
import 'package:lab33_qnais/openai_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:lab33_qnais/gemini.dart';
import 'package:lab33_qnais/dall.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

Future<void> initSpeechToText() async {
    await flutterTts.setSharedInstance(true);
    await speechToText.initialize(
      onStatus: (status) {
        print('Speech recognition status: $status');
      },
      onError: (error) {
        print('Speech recognition error: $error');
      },
    );
    setState(() {});
  }

  Future<void> startListening() async {
    if (await speechToText.hasPermission && speechToText.isNotListening) {
      await speechToText.listen(onResult: onSpeechResult);
      setState(() {});
    } else if (speechToText.isListening && !isSpeaking) {
        await speechToText.listen(onResult: onSpeechResult);
      generatedContent = lastWords;
      final speech = await openAIService.isArtPromptAPI(lastWords);
      if (speech.contains('https')) {
        generatedImageUrl = speech;
        generatedContent = null;
        setState(() {});
      } else {
        generatedImageUrl = null;
        generatedContent = speech;
        setState(() {});
        await systemSpeak(speech);
      }
      await stopListening();
    } else if (speechToText.isListening && isSpeaking) {
      await stopSpeaking();
      isSpeaking = false;
    } else {
      initSpeechToText();
    }
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    if (isSpeaking) {
      await stopSpeaking();
    }

    await flutterTts.speak(content);
    isSpeaking = true;
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop();
    isSpeaking = false;
  }

  Future<void> startSpeaking() async {
    if (isSpeaking) {
      await stopSpeaking();
    }

    await flutterTts.speak(lastWords);
    isSpeaking = true;
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text('Allen'),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        centerTitle: true,
      ),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // virtual assistant picture
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/virtualAssistant.png',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent == null
                          ? 'Good Morning, what task can I do for you?'
                          : generatedContent!,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // features list
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descriptionText:
                          'A smarter way to stay organized and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () async {
                // Appuyez sur ce bouton pour arrêter la synthèse vocale
                await stopSpeaking();
              },
              child: Icon(Icons.stop),
            ),
            SizedBox(width: 16),
            FloatingActionButton(
              backgroundColor: Pallete.firstSuggestionBoxColor,
              onPressed: () async {
                if (isSpeaking) {
                  // Appuyez sur ce bouton pour reprendre la synthèse vocale
                  await startSpeaking();
                } else {
                  // Appuyez sur ce bouton pour commencer à écouter
                  await startListening();
                }
              },
              child: Icon(
                isSpeaking ? Icons.play_arrow : Icons.mic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Row(
                children: [
                  Image.asset('assets/images/chatgpt.png', width: 40, height: 40),
                  SizedBox(width: 10),
                  Text('ChatGPT'),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                print('Option sélectionnée : ChatGPT');
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Image.asset('assets/images/dall.png', width: 40, height: 40),
                  SizedBox(width: 10),
                  Text('Dall_E'),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                print('Option sélectionnée : Dall');
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => Dall()), // Navigue vers la page 
                 );
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Image.asset('assets/images/gemini.png', width: 40, height: 40),
                  SizedBox(width: 10),
                  Text('Gemini'),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                print('Option sélectionnée : Gemini');
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => Gemini()), // Navigue vers la page 
                 );
              },
            ),
          ],
        ),
      ),
    );
  }
}
