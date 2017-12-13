#!/bin/bash

prev_branch="$(git rev-parse --abbrev-ref HEAD)"
prev_git_id="$(git rev-parse HEAD)"
mydate="$(date -u +'%a, %d %b %Y  %T %z')"
buildid="${prev_branch}-${prev_git_id}-$(echo "$mydate" | tr -d ' ',',','+',':')"
git checkout --orphan "${buildid}"

hugo
rm config.toml README.md .gitignore LICENSE
rm -rf content layouts themes static .gitmodules
mv public/* ./
rm -rf public
echo "*.sw[nop]" > .gitignore
echo "spartan-pl.org" > CNAME
rm deploy.sh

git add . --all

git commit -m "Build ID ${buildid}"

if [ `git branch --list gh-pages` ] ; then
  git checkout gh-pages
else
  git checkout upstream/gh-pages # User needs to check out gh-pages
  git checkout -b gh-pages
  git branch --set-upstream-to=upstream/gh-pages
fi

rm -rf *
git checkout "${buildid}" -- . # Checkout all files
git add . --all
git branch -D "${buildid}"
