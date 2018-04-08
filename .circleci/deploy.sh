#!/bin/bash

set -eu

PROJ_DIR=$(cd $(dirname $0)/.. && pwd)
cd $PROJ_DIR

if [ ! -e deploy ]; then
  git clone --depth 1 -b gh-pages git@github.com:ngs/$CNAME.git deploy
fi

cd deploy
git reset --hard origin/gh-pages
rm -rf *
mv ../$BUILD_DIR/* .
echo $CNAME > CNAME
git add -A
git commit --messsage "Build artifacts of $CIRCLE_SHA1\n\n$CIRCLE_BUILD_URL"

