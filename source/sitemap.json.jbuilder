blog.articles.each{|a|
  url = a.url
  json.set! url, a.data.merge(url: url)
}
