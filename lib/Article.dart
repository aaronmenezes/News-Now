   
  class Article{
    final String author;
    final String title;
    final String description;
    final String url;
    final String urlToImage;
    final String publishedAt;
    final String content;
  
    Article(this.author,  this.title, this.description, this.url, this.urlToImage, this.publishedAt, this.content);

    factory Article.fromJson(Map<String, dynamic> json){
      var url =json["urlToImage"];
           
      if(!url.contains("https:",0) && url!=null )
         print(url);
      //   url="https:"+url;
      return Article(json["author"],
                    json["title"],json["description"],
                    json["url"],url,json["publishedAt"],json["content"]);
    }
  }