// Update your test_firebase.dart with this version:
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'firebase_options.dart';

class FirebaseTestPage extends StatefulWidget {
  @override
  _FirebaseTestPageState createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  final _phoneController = TextEditingController(text: '+9647800175770');
  final _codeController = TextEditingController();
  String _status = 'Initializing...';
  String? _verificationId;
  ConfirmationResult? _confirmationResult;
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _initializeAndTest();
  }

  void _log(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: $message');
      _status = message;
    });
    print(message);

    // Also log to browser console
    js.context.callMethod('console.log', ['Flutter: $message']);
  }

  void _initializeAndTest() async {
    try {
      // Log current environment
      _log('Current URL: ${html.window.location.href}');
      _log('Origin: ${html.window.location.origin}');
      _log('Hostname: ${html.window.location.hostname}');
      _log('Port: ${html.window.location.port}');
      _log('Protocol: ${html.window.location.protocol}');

      // Check if Firebase is already initialized
      try {
        Firebase.app();
        _log('Firebase already initialized');
      } catch (e) {
        _log('Initializing Firebase...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _log('Firebase initialized successfully');
      }

      // Log Firebase configuration
      final app = Firebase.app();
      _log('Project ID: ${app.options.projectId}');
      _log('Auth Domain: ${app.options.authDomain}');
      _log('API Key: ${app.options.apiKey?.substring(0, 10)}...');
      _log('App ID: ${app.options.appId}');

      // Check Auth instance
      final auth = FirebaseAuth.instance;
      _log('Auth instance created: ${auth != null}');
      _log('Current user: ${auth.currentUser?.uid ?? "None"}');

      // Check auth settings
      await auth.setSettings(
        appVerificationDisabledForTesting: false, // Make sure this is false for production
      );
      _log('Auth settings applied');

      // Test auth state
      auth.authStateChanges().listen((User? user) {
        _log('Auth state changed: ${user?.uid ?? "signed out"}');
      });

    } catch (e, stackTrace) {
      _log('Initialization error: $e');
      _log('Stack trace: $stackTrace');
    }
  }

  void _testDirectJavaScript() {
    _log('Testing direct JavaScript Firebase auth...');

    // Execute JavaScript directly to test Firebase
    js.context.callMethod('eval', ['''
      (async function() {
        try {
          console.log('Direct JS: Firebase object exists:', typeof firebase !== 'undefined');
          if (typeof firebase === 'undefined') {
            console.error('Direct JS: Firebase is not defined!');
            return;
          }
          
          console.log('Direct JS: Firebase auth exists:', typeof firebase.auth !== 'undefined');
          console.log('Direct JS: Current domain:', window.location.origin);
          
          const auth = firebase.auth();
          console.log('Direct JS: Auth instance created');
          
          // Try to sign in with phone
          const phoneNumber = '${_phoneController.text}';
          console.log('Direct JS: Attempting to sign in with:', phoneNumber);
          
          // Create a visible recaptcha container
          const recaptchaContainer = document.createElement('div');
          recaptchaContainer.id = 'recaptcha-container-test';
          document.body.appendChild(recaptchaContainer);
          
          const recaptchaVerifier = new firebase.auth.RecaptchaVerifier('recaptcha-container-test', {
            'size': 'normal',
            'callback': (response) => {
              console.log('Direct JS: reCAPTCHA solved');
            }
          });
          
          const confirmationResult = await auth.signInWithPhoneNumber(phoneNumber, recaptchaVerifier);
          console.log('Direct JS: Code sent successfully!');
          window.flutterConfirmationResult = confirmationResult;
          
        } catch (error) {
          console.error('Direct JS Error:', error);
          console.error('Direct JS Error Code:', error.code);
          console.error('Direct JS Error Message:', error.message);
        }
      })();
    ''']);
  }

  void _sendCode() async {
    _log('Attempting to send code to ${_phoneController.text}...');

    try {
      // Try Flutter SDK method
      _confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(
        _phoneController.text,
      );

      _log('Code sent successfully!');
    } catch (e) {
      _log('Flutter SDK Error: $e');

      // Get more error details
      if (e is FirebaseAuthException) {
        _log('Error code: ${e.code}');
        _log('Error message: ${e.message}');
        _log('Error details: ${e.toString()}');
      }

      // Try JavaScript method
      _testDirectJavaScript();
    }
  }

  void _verifyCode() async {
    if (_confirmationResult == null) {
      // Try to get from JavaScript
      final jsResult = js.context['flutterConfirmationResult'];
      if (jsResult != null) {
        _log('Using JavaScript confirmation result');
        try {
          final code = _codeController.text;
          js.context.callMethod('eval', ['''
            window.flutterConfirmationResult.confirm('$code').then((result) => {
              console.log('Verification successful:', result.user.uid);
            }).catch((error) => {
              console.error('Verification error:', error);
            });
          ''']);
        } catch (e) {
          _log('JS verification error: $e');
        }
        return;
      }

      _log('No verification in progress');
      return;
    }

    _log('Verifying code...');

    try {
      final credential = await _confirmationResult!.confirm(_codeController.text);
      _log('Success! User: ${credential.user?.uid}');
    } catch (e) {
      _log('Verify error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Auth Debug'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _initializeAndTest,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Environment info
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.yellow[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check browser console (F12) for detailed logs'),
                  SizedBox(height: 5),
                  SelectableText('Current URL: ${Uri.base.toString()}'),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Status
            Container(
              padding: EdgeInsets.all(10),
              color: _status.contains('Error') ? Colors.red[100] : Colors.green[100],
              child: SelectableText(
                'Status: $_status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),

            // Controls
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendCode,
                  child: Text('Send Code'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: 'Verification Code',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _verifyCode,
                  child: Text('Verify'),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Test buttons
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: _testDirectJavaScript,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text('Test Direct JS'),
                ),
                ElevatedButton(
                  onPressed: () {
                    js.context.callMethod('eval', ['location.reload()']);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Reload Page'),
                ),
              ],
            ),

            // Logs
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return SelectableText(
                      _logs[index],
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}