import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forensodont/pages/home.dart';
import 'package:local_auth/local_auth.dart';

import '../landingpage.dart';

class AuthGate extends StatefulWidget {
  static const String id = 'auth_gate';
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;
  bool _isAuthenticated = false;
  String _authError = '';
  bool _showPinPad = false;
  String _enteredPin = '';
  final String _correctPin = '123456';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  bool isUserLoggedIn() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null;
  }

  Future<void> _checkBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (canAuthenticate) {
        _authenticate();
      } else {
        setState(() {
          _authError = 'Biometric authentication not available';
          _showPinPad = true;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _authError = e.message ?? 'Unknown error';
        _showPinPad = true;
      });
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _authError = '';
    });

    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Forensodont',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      setState(() {
        _isAuthenticating = false;
        _isAuthenticated = didAuthenticate;
      });

      if (_isAuthenticated) {
        if (!mounted) return;
        if(isUserLoggedIn()) {
          Navigator.pushNamed(context, HomePage.id);
        } else {
          Navigator.pushNamed(context, LandingPage.id);
        }
      } else {
        // Authentication was cancelled - show PIN pad
        setState(() {
          _showPinPad = true;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authError = e.message ?? 'Unknown error';
        _showPinPad = true;
      });
    }
  }

  void _onPinEntered(String digit) {
    setState(() {
      if (digit == 'delete') {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      } else {
        _enteredPin += digit;
        if (_enteredPin.length == 6) {
          _verifyPin();
        }
      }
    });
  }

  void _verifyPin() {
    if (_enteredPin == _correctPin) {
      setState(() {
        _isAuthenticated = true;
        _authError = '';
      });
      Navigator.pushReplacementNamed(context, LandingPage.id);
    } else {
      setState(() {
        _authError = 'Incorrect PIN';
        _enteredPin = '';
      });
    }
  }

  void _switchToPinAuth() {
    setState(() {
      _showPinPad = true;
      _isAuthenticating = false;
    });
  }

  void _switchToBiometricAuth() {
    setState(() {
      _showPinPad = false;
      _enteredPin = '';
      _authError = '';
    });
    _authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7D3DE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              _showPinPad ? 'Enter your PIN' : 'Authenticate',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            if (_isAuthenticating)
              const Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Waiting for authentication...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            else if (_showPinPad)
              _buildPinPad()
            else if (_authError.isNotEmpty)
                Column(
                  children: [
                    Text(
                      _authError,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _authenticate,
                      child: const Text(
                        'Try Biometric Again',
                        style: TextStyle(color: Color(0xFFA7D3DE)),
                      ),
                    ),
                    TextButton(
                      onPressed: _switchToPinAuth,
                      child: const Text(
                        'Use PIN Instead',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _authenticate,
                      child: const Text(
                        'Start Biometric Authentication',
                        style: TextStyle(color: Color(0xFFA7D3DE)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _switchToPinAuth,
                      child: const Text(
                        'Use PIN Instead',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _enteredPin.length
                      ? Colors.white
                      : Colors.white.withAlpha(85),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 30),
        if (_authError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              _authError,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        SizedBox(
          width: 300,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (int i = 1; i <= 9; i++) _buildPinButton(i.toString()),
              _buildPinButton('', enabled: false),
              _buildPinButton('0'),
              _buildPinButton('delete', icon: Icons.backspace),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _switchToBiometricAuth,
          child: const Text(
            'Use Biometric Authentication Instead',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPinButton(String text, {IconData? icon, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: enabled ? () => _onPinEntered(text) : null,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(25),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: Colors.white)
                  : Text(
                      text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
