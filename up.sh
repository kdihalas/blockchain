#!/usr/bin/env bash

echo ":: Creating data/boot"
mkdir -p data/boot

echo ":: Creating boot.key"
bootnode --genkey=data/boot/boot.key
echo ":: Starting bootnode"
bootnode --nodekey=data/boot/boot.key -verbosity 9 > data/boot/bootnode.log 2>&1 &

echo $! > .pids

echo ":: Wait 5s for bootnode to start"
sleep 5

BOOT_NODE_URL=$(cat data/boot/bootnode.log | awk '{print $6}' | sed 's/self=//g' | sed 's/\[::\]/127.0.0.1/g')
PASSWORD=$(env LC_CTYPE=C tr -dc "a-zA-Z0-9-_\$\?" < /dev/urandom | head -c 10)

function startNode {
  echo ":: Creating ${1}"
  mkdir -p data/$1
  echo $PASSWORD > data/$1/pass.txt

  echo ":: Initializing ${1} with genesis.json"
  geth --datadir data/$1 init genesis.json > data/$1/init.log 2>&1
  echo ":: Create a base account for  ${1}"
  geth --datadir data/$1 account new --password data/$1/pass.txt > data/$1/acount.log 2>&1
    echo ":: Starting ${1}"
  geth --datadir data/$1 --bootnodes="${BOOT_NODE_URL}" --mine --miner.threads 1 --syncmode "full" --port $2 > data/$1/miner.log 2>&1 &
  echo $! >> .pids
}

startNode "node1" "3001"
startNode "node2" "3002"
startNode "node3" "3003"
