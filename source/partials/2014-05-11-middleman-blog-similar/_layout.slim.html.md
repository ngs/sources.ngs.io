```rb
h2 Similar Entries
ul
  - similar_articles.first(5).each do|article|
    li= link_to article.title, article.url
```
