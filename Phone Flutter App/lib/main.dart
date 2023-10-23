import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'chatb.dart';
import 'doctor.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    Home(),
  );
}



class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Analytics Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

String dat = "";

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String tex = "";
  FirebaseDatabase database = FirebaseDatabase.instance;

  Future<void> _testSetUserId() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('/').get();
    if (snapshot.exists) {
      print(snapshot.value);
      setState(() {
        tex = snapshot.value.toString();
      });
    } else {
      print('No data available.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://i.pinimg.com/1200x/a1/b4/df/a1b4dfecc2bd41ece7b2a9b47f85e033.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            height: MediaQuery.of(context).size.height /3,
          ),

          // Content
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 60), // Adjust the height as needed
                Padding(
                  padding: EdgeInsets.only(top:16, right: 16,left: 16),
                  child: Column(
                    children: const [
                      SizedBox(height: 20,),
                      Text(
                        'MED-SYNC',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        'Unified Patient Treatment Platform - App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: [
                    SquareTileButton(
                      text: 'Doctor',
                      imageAsset: 'assets/doctor.png',
                      onPressed: () {Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DoctorPage(),
                      ));
                      },
                    ),
                    SquareTileButton(
                      text: 'Patient',
                      imageAsset: 'assets/patient_info.png',
                      onPressed: () {Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatPage(),
                      ));
                      },
                    ),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SquareTileButton extends StatelessWidget {
  final String text;
  final String imageAsset;
  final VoidCallback onPressed;

  SquareTileButton({required this.text, required this.imageAsset, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Column(
          children: <Widget>[
            SizedBox(height: 5,),
            Image.asset(
              imageAsset,
              height: 100,
            ),
            SizedBox(height: 15,),
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Text(
                text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
