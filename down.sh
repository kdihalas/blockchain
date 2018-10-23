#!/usr/bin/env bash

PIDS=$(cat .pids)

for pid in ${PIDS}; do
  kill $pid;
done

rm -rf data
