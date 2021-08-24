import 'package:flutter/material.dart';  
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart'; 
import 'Article.dart'; 

//flutter run --no-sound-null-safety

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget { 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData( 
        primaryColor: Colors.white,
      ),
      home: ArticleListView(),
    );
  }
} 

List<Article> parseArticles(String responseBody) { 
    final parsed = json.decode(responseBody)["articles"].cast<Map<String, dynamic>>();  
    return parsed.map<Article>((json) =>Article.fromJson(json)).toList(); 
} 
Future<List<Article>> fetchArticles() async {  
  final response = await http.get('https://newsapi.org/v2/top-headlines?apiKey=6069225c835e4bfe800d3de6eb0b36fd&country=in'); 
  if (response.statusCode == 200) {   
      return parseArticles(response.body); 
  } else { 
      print("api call error");
      throw Exception('Unable to fetch Articles from the REST API');
  } 
}

Future<List<Article>>  fetchCategoryArticles(String cat) async{
    final response = await http.get('https://newsapi.org/v2/top-headlines?apiKey=6069225c835e4bfe800d3de6eb0b36fd&category='+cat); 
  if (response.statusCode == 200) {   
      return parseArticles(response.body); 
  } else { 
      print("api call error");
      throw Exception('Unable to fetch Articles from the REST API');
  } 
 }

class ArticleListView extends StatefulWidget {
  @override
  _ArticleListViewState createState() => _ArticleListViewState();
}

class _ArticleListViewState extends State<ArticleListView> {  
  final _biggerFont = const TextStyle(fontSize:  16.0,color: Colors.black87,);  
  String _currentCategory = "in";
  late Future<List<Article>> futureArticle;
  GlobalKey<ScaffoldState> _drawerKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState(); 
    futureArticle = fetchArticles();
  } 
  
  void fetchCategory(String cat){
    if(_currentCategory==cat)
      return ;
    _currentCategory= cat;
      setState((){futureArticle = fetchCategoryArticles(cat); _drawerKey.currentState?.openEndDrawer();});
  }
  void fetchCountry(String cat){
    if(_currentCategory==cat)
      return ;
    _currentCategory= cat;
      setState((){futureArticle = fetchArticles(); _drawerKey.currentState?.openEndDrawer();});
  }
  Widget _buildSuggestions(List<Article> articleList) {   
    return ListView.builder(
        itemCount: articleList.length*2,
        padding: const EdgeInsets.symmetric(vertical :10.0,horizontal: 5.0),
        itemBuilder:  (context, i) {
          if (i.isOdd) return const Divider();   
          return _buildRow(articleList[i~/2]);
        });
  }

  Widget _buildRow(Article art) {     
    return ListTile(     
      leading: art.urlToImage!=null?FadeInImage.assetNetwork( 
              placeholder: "assets/images/tile_placeholder.png",
              image: art.urlToImage,
              width:100,height:200, 
              fit: BoxFit.cover, 
              ): Image.asset("assets/images/tile_placeholder.png"),
      title: Text(
        art.title,
        style: _biggerFont, 
      ),
      
      onTap: () {      
        _pushSaved(art.url);
      }, 
    );
  } 

  void _pushSaved(String url) { 
    Navigator.of(context).push(
      MaterialPageRoute<void>( 

        builder: (BuildContext context) {
          /*final tiles = _saved.map(
            (Article art) {
              return ListTile(
                title: Text(
                  art.title,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(context: context, tiles: tiles).toList()
              : <Widget>[];*/

          return Scaffold(
            appBar: AppBar(
              title: Text(' '),
            ),
           body : WebView(
              initialUrl:url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {  },
            ),
          );
        }, 
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) { 
   
  final drawerHeader =  DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Drawer Header',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        );
  final drawerItems = ListView(
      children: [
        drawerHeader,
        ListTile(
          leading: Icon(Icons.business),
          title: Text('India'),
          onTap: (){ fetchCountry("in"); },
        ),
        ListTile(
          leading: Icon(Icons.business),
          title: Text('Business'),
          onTap: (){ fetchCategory("business"); },
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Entertainment'),
           onTap: (){ fetchCategory("entertainment"); },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('General'),
          onTap: (){ fetchCategory("general"); },
        )
        , ListTile(
          leading: Icon(Icons.health_and_safety),
          title: Text('Health'),
          onTap: (){ fetchCategory("health"); },
        ),
        ListTile(
          leading: Icon(Icons.science),
          title: Text('Science'),
          onTap: (){ fetchCategory("science"); },
        ),
        ListTile(
          leading: Icon(Icons.sports),
          title: Text('Sports'),
          onTap: (){ fetchCategory("sports"); }, 
        ) ,ListTile(
          leading: Icon(Icons.settings),
          title: Text('Technology'),
          onTap: (){ fetchCategory("technology"); },
        )
      ],
    );
 
    return Scaffold(
      key: _drawerKey,
      appBar: AppBar(
        title: Text('News'),
        actions: [
         // IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      drawer: Drawer(
        child:drawerItems,
      ),
      body: Center(
        child: FutureBuilder<List<Article>>(
            future: futureArticle,
             builder: (context, snapshot) { 
              if (snapshot.hasData) {
                return _buildSuggestions(snapshot.data!.toList());
              }
              return CircularProgressIndicator();
             }),
      ),
    );
  }
}
 