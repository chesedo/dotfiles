#!/bin/sh

for f in *.Dockerfile
do
  tag=$(echo $f | cut -d "." -f 1)
  image="chesedo/ide:$tag"

  echo "Building $image"

  docker build -t $image -f $f .
  docker push $image
done
