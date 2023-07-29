import 'package:app/widget/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _islogin = true;
  var _enteredEmail = '';
  var _enterdPassword = '';
  var _enterUserName = '';
  File? _selectedIamge;
  var _isAuthentication = false;
  void _submit() async {
    final isvalid = _formKey.currentState!.validate();
    if (!isvalid) {
      return;
    }
    if (!_islogin && _selectedIamge == null) {
      return;
    }
    if (isvalid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isAuthentication = true;
        });
        if (_islogin) {
          final userCredential = await _firebase.signInWithEmailAndPassword(
              email: _enteredEmail, password: _enterdPassword);
        } else {
          final userCredential = await _firebase.createUserWithEmailAndPassword(
              email: _enteredEmail, password: _enterdPassword);
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${userCredential.user!.uid}jpg');
          await storageRef.putFile(_selectedIamge!);
          final imageUrl = await storageRef.getDownloadURL();
          // print(imageUrl);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'username': _enterUserName,
            'email': _enteredEmail,
            'image_url': imageUrl
          });
        }
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {}
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Authentication failed')));
      }
      setState(() {
        _isAuthentication = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
          child: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            margin: EdgeInsets.only(
              top: 30,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            width: 200,
            child: Image.asset('assets/images/chat.png'),
          ),
          Card(
            margin: const EdgeInsets.all(20),
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_islogin)
                        UserImagePicker(
                          onPickedImage: (pickedImage) {
                            _selectedIamge = pickedImage;
                          },
                        ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email Address'),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredEmail = value!;
                        },
                      ),
                      if (!_islogin)
                        TextFormField(
                          decoration: InputDecoration(labelText: 'UserName'),
                          enableSuggestions: false,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 4) {
                              return 'Please  enter at least 4 character ';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enterUserName = value!;
                          },
                        ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Passord must be at least 6 character';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enterdPassword = value!;
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      if (_isAuthentication) const CircularProgressIndicator(),
                      if (!_isAuthentication)
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            onPressed: _submit,
                            child: Text(_islogin ? 'Login' : 'Singnup')),
                      if (!_isAuthentication)
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _islogin = !_islogin;
                              });
                            },
                            child: Text(_islogin
                                ? 'Create an account'
                                : 'I already have an account. login'))
                    ],
                  )),
            )),
          )
        ]),
      )),
    );
  }
}
