import 'package:shared_preferences/shared_preferences.dart';
import 'package:wine_esp/Sockets.dart';

import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final Sockets socket;
  final String userId;
  final Function() quit;

  const ProfilePage({
    required Key key,
    required this.socket,
    required this.userId,
    required this.quit,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  bool _showpassword = false;

  @override
  void initState() {
    super.initState();
    widget.socket.sendProfilePage(widget.userId);
    widget.socket.receiveProfilePage((data) {
      _userNameController.text = data[0];
      _userPasswordController.text = data[1];
    });
  }

  Future<void> _removeUserIdFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', 'NoId');
  }

  Future<void> _logout() async {
    await _removeUserIdFromCache().then((value) {
      Navigator.pop(context);
      widget.quit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title:
            const Text(style: TextStyle(color: Color(0xff222222)), 'Profile'),
        backgroundColor: const Color(0xfffaeab1),
        iconTheme: const IconThemeData(color: Color(0xff222222)),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'User Name',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                hintText: 'Enter user name',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            // make a show password button with an eye icon
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userPasswordController,
                    obscureText: !_showpassword,
                    decoration: const InputDecoration(
                      hintText: 'Enter password',
                    ),
                  ),
                ),
                IconButton(
                  icon: !_showpassword
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showpassword = !_showpassword;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Collect data and send to server
                final String userName = _userNameController.text;
                final String userPassword = _userPasswordController.text;
                widget.socket.modifyUser(widget.userId, userName, userPassword);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xffffffff),
                backgroundColor: const Color(0xff108963),
              ),
              child: const Text('Confirm'),
            ),
            const SizedBox(height: 40.0),
            const Spacer(),
            // make a button with an exit icon to disconnect
            ElevatedButton(
              onPressed: () {
                _logout();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xff222222),
                backgroundColor: const Color(0xffe7E7E7),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.exit_to_app, size: 30),
                  SizedBox(
                    width: 10,
                    height: 50,
                  ),
                  Text('Sign off', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
