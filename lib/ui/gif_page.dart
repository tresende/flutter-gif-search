import 'package:flutter/material.dart';

class GifPage extends StatelessWidget {
  final Map _gifData;

  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("teste"),
      ),
      body: Center(
        child: Image.network(this._gifData['images']['fixed_height']['url']),
      ),
    );
  }
}
