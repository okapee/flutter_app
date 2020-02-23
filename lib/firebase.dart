import 'package:flutter/material.dart';

final emailInputController = new TextEditingController();
final passwordInputController = new TextEditingController();

Widget _layoutBody() {
  return new Center(
    child: new Form(
      child: new SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 24.0),
            new TextFormField(
              controller: emailInputController,
              decoration: const InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 24.0),
            new TextFormField(
              controller: passwordInputController,
              decoration: new InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            new Center(
              child: new RaisedButton(
                child: const Text('Login'),
                onPressed: () {
                  var email = emailInputController.text;
                  var password = passwordInputController.text;
                  // ここにログイン処理を書く
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
