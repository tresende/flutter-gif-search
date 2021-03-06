import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gif_search/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:transparent_image/transparent_image.dart';

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
  String search;
  int offset = 0;
  int limit = 19;

  Map env = DotEnv().env;
  Future<Map> _getGifs() async {
    String url;
    http.Response response;
    if (search == null) {
      url = TRENDING_URL;
      url = SEARCH_URL.replaceFirst('_KEY', env['GIPHY_KEY']);
      response = await http.get(url);
    } else {
      url = SEARCH_URL;
      url = url.replaceFirst('_KEY', env['GIPHY_KEY']);
      url = url.replaceFirst('_QUERY_TEXT', search);
      url = url.replaceFirst('_LIMIT', limit.toString());
      url = url.replaceFirst('_OFFSET', offset.toString());
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
              onSubmitted: (text) {
                setState(() {
                  this.search = text;
                  this.offset = 0;
                });
              },
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

  int _getCount(List data) {
    if (search == null) return data.length;
    return data.length + 1;
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    var itens = snapshot.data["data"];
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _getCount(itens),
      itemBuilder: (context, index) {
        if (search == null || index < itens.length) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          GifPage(itens[index])));
            },
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: itens[index]["images"]["fixed_height"]["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return Container(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  offset += 15;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70),
                  Text(
                    "Carregar Mais",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getGifs();
  }
}
