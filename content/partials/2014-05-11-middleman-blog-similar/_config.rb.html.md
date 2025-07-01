# Levenshtein distance function:
activate :similar # , :algorithm => :levenshtein by default.
# Damerau–Levenshtein distance function:
activate :similar, :algorithm => :damerau_levenshtein
# Term Frequency-Inverse Document Frequency function:
activate :similar, :algorithm => :tf_idf
# Okapi BM25 ranking function:
activate :similar, :algorithm => :bm25
