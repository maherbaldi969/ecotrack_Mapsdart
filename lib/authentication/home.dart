import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggingOut = false;
  String? _errorMessage;

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
      _errorMessage = null;
    });

    final url = Uri.parse('http://192.168.112.51:3000/auth/logout');
    final response = await http.post(url);

    setState(() { 
      _isLoggingOut = false;
    });

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      setState(() {
        _errorMessage = 'Logout failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
        title: Text('Home'),
        actions: [
          _isLoggingOut
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: _logout,
                ),
        ],
      ),
      body: Center(
        child: _errorMessage != null
            ? Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              )
            : Text('Welcome! You are logged in.'),
      ),
    );
  }
}
