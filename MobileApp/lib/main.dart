import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wine_esp/AfterLoginPage.dart';

import 'Sockets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Sockets socket = Sockets();
    socket.connectSocket();

    return MaterialApp(
      title: 'WinEsp',
      theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xfffaeab1),
            secondary: Color(0xff108963),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xfffaeab1),
            selectedItemColor: Colors.black,
            unselectedItemColor: Color(0xff108963),
          )),
      home: MainPage(
        title: 'WinEsp',
        socket: socket,
        quit: false,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage(
      {super.key, required title, required this.socket, required this.quit});

  final String title = 'WinEsp';
  final Sockets socket;
  final bool quit;

  @override
  State<MainPage> createState() => _MainState();
}

class _MainState extends State<MainPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool signingUp = false;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    if (!widget.quit) _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null && userId != 'NoId') {
      setState(() {
        _handleStart(userId);
      });
    }
  }

  bool validate(String name, String password) {
    if (name.length > 2 && password.length > 4) {
      return true;
    } else {
      // show a bottom message
      if (name.length < 3) {
        _showMessage('Username must be at least 3 characters long');
      }
      if (password.length < 5) {
        _showMessage('Password must be at least 5 characters long');
      }
      return false;
    }
  }

  void _showMessage(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  _handleStart(userid) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => AfterLoginPage(
          socket: widget.socket,
          userId: userid.toString(),
        ),
      ),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', userid.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'WinEsp',
                style: TextStyle(
                  color: Color(0xff108963),
                  fontWeight: FontWeight.w500,
                  fontSize: 30,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Text(
                signingUp ? 'Sign up' : 'Log in',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Name',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color(0xff60A26D),
                  ),
                ),
                child: Text(signingUp ? 'Sign up' : 'Log in'),
                onPressed: () {
                  if (validate(nameController.text, passwordController.text)) {
                    if (signingUp) {
                      widget.socket
                          .signUp(nameController.text, passwordController.text);
                      widget.socket.receiveSignUp((data) {
                        if (data[0] == "Username already taken") {
                          _showMessage(data[0]);
                        } else {
                          _handleStart(data[1]);
                        }
                      });
                    } else {
                      widget.socket
                          .logIn(nameController.text, passwordController.text);
                      widget.socket.receiveLogIn((data) {
                        if (data[0] == "Username doesn't exist") {
                          _showMessage(data[0]);
                        } else if (data[0] == "Wrong password") {
                          _showMessage(data[0]);
                        } else {
                          _handleStart(data[1]);
                        }
                      });
                    }
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(signingUp
                    ? 'Already have account?'
                    : 'Does not have account?'),
                TextButton(
                  child: Text(
                    signingUp ? 'Log in' : 'Sign up',
                    style:
                        const TextStyle(fontSize: 20, color: Color(0xff108963)),
                  ),
                  onPressed: () {
                    setState(() {
                      signingUp = !signingUp;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
