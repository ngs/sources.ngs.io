#!/bin/bash

set -eu

git config --global user.email "a+circleci@ngs.io"
git config --global user.name "Circle CI"

mkdir -p ~/.ssh
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
