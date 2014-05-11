```ruby
# Levenshtein distance function:
activate :similar # , :engine => :levenshtein by default.

# Damerau–Levenshtein distance function:
activate :similar, :engine => :damerau_levenshtein

# Term Frequency-Inverse Document Frequency function:
activate :similar, :engine => :tf_idf

# Okapi BM25 ranking function:
activate :similar, :engine => :bm25
```
