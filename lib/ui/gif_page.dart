import 'package:flutter/material.dart';
import 'package:share/share.dart';
  
class GifPage extends StatelessWidget {
  final Map _gifData;

  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    String imageUrl = this._gifData['images']['fixed_height']['url'];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("teste"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(imageUrl);
            },
          )
        ],
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
