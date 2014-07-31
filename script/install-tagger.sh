if [ ! -d $TAGGER_DIR ]; then
  mkdir -p $TAGGER_DIR
  curl --progress-bar -o $TAGGER_DIR/tree-tagger-linux-3.2.tar.gz http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tree-tagger-linux-3.2.tar.gz
  curl --progress-bar -o $TAGGER_DIR/tagger-scripts.tar.gz http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tagger-scripts.tar.gz
  curl --progress-bar -o $TAGGER_DIR/install-tagger.sh http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/install-tagger.sh
  curl --progress-bar -o $TAGGER_DIR/english-par-linux-3.2.bin.gz http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/english-par-linux-3.2.bin.gz
  cd $TAGGER_DIR && sh install-tagger.sh && cd -
fi

