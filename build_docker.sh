#!/usr/bin/env bash
image="yolo3-20.12-py3"
backend="."

#docker build --add-host="archive.ubuntu.com:160.26.2.187" -t "$image" $backend
docker build -t "$image" $backend

