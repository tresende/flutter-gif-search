import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String TRENDING_URL =
    'https://api.giphy.com/v1/gifs/trending?api_key=_KEY&limit=20&rating=G';

const String SEARCH_URL =
    'https://api.giphy.com/v1/gifs/search?api_key=_KEY&q=_QUERY_TEXT&limit=_LIMIT&offset=_OFFSET&rating=G&lang=en';

const String LOGO_URL =
    'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map env = DotEnv().env;
  Future<Map> _getGifs() async {
    String search;
    String url;
    http.Response response;
    if (search == null) {
      url = TRENDING_URL;
      url = SEARCH_URL.replaceFirst('_KEY', env['GIPHY_KEY']);
      response = await http.get(url);
    } else {
      url = SEARCH_URL;
      url = SEARCH_URL.replaceFirst('_KEY', env['GIPHY_KEY']);
      url = SEARCH_URL.replaceFirst('_QUERY_TEXT', 'Teste');
      url = SEARCH_URL.replaceFirst('_LIMIT', '25');
      url = SEARCH_URL.replaceFirst('_OFFSET', '0');
      response = await http.get(url);
    }
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(LOGO_URL),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Pesquise aqui',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            padding: EdgeInsets.all(12),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError) return Container();
                    return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: snapshot.data["data"].length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: Image.network(
            snapshot.data["data"][index]["images"]["fixed_height"]["url"],
            height: 300,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getGifs();
  }
}
