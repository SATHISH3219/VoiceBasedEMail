import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice-Based Email',
      debugShowCheckedModeBanner: false,
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
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text1 = 'Recipient Deatils';
  String _text2 = 'Press the button and speak';
  String _emailStatus = '';
  String email1 = '';
  SmtpServer? smtpServer;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 465,
      username: 'sathishsaravanan321@gmail.com',
      password: 'akxs jrad ucwy omhh',
      ssl: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 145, 215, 247),
      appBar: AppBar(
        title: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Voice-Based Email',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        backgroundColor: Colors.blue,
        bottomOpacity: 20,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Center(
                  child: Text(
                "Voice Based Email for Visually challenged people ",
                style: TextStyle(fontSize: 20),
              )),
            ),
            const Text(
              "Click below for add Recipient Details",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: _listens,
              icon: const Icon(
                Icons.mic,
                color: Colors.black,
              ),
              label: const Text(
                "Add Recipient Details",
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              "To : " + _text1,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(
              'Say something:',
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              "Message : " + _text2,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              height: 40,
            ),
            Text(
              _emailStatus,
              style: const TextStyle(color: Colors.green),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: _listen,
              icon: const Icon(
                Icons.send,
                color: Colors.black,
              ),
              label: const Text("Add Message to send",
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            ),
          ],
        ),
      ),
    );
  }

  void _listens() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() {
            _text1 = result.recognizedWords;
            if (result.recognizedWords == 'Sathish') {
              email1 = "2116164@saec.ac.in";
            } else if (result.recognizedWords == 'SK') {
              email1 = "2116164@saec.ac.in";
            }
          }),
        );
      } else {
        print('Speech recognition not available');
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() {
            _text2 = result.recognizedWords;
          }),
        );
      } else {
        print('Speech recognition not available');
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();

      var emailText = _text2.trim();
      if (emailText.isNotEmpty) {
        String subject = 'Voice-Based Email';
        await _sendEmail(emailText, email1, subject);
      }
    }
  }

  Future<void> _sendEmail(
      String body, String recipientEmail, String subject) async {
    if (smtpServer == null) {
      throw Exception('SMTP server not initialized');
    }

    final message = Message()
      ..from = const Address('sathishsaravanan321@gmail.com', 'Sathish')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = body;

    try {
      print('Sending email...');
      await send(message, smtpServer!);
      print('Email sent');
      setState(() {
        _emailStatus = 'Email sent!';
      });
    } catch (error) {
      print('Failed to send email: $error');
      setState(() {
        _emailStatus = 'Failed to send email: $error';
      });
    }
  }
}
