#!/bin/bash

# Ganti IP publik node kamu di sini
RPC_URL="http://64.227.104.171:8545"
BEACON_API="http://64.227.104.171:5052"

echo "🔍 Mengecek koneksi ke Geth (Execution Layer)..."
curl -s -X POST $RPC_URL \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' \
  | jq

echo -e "\n🔄 Mengecek status sinkronisasi (eth_syncing)..."
curl -s -X POST $RPC_URL \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  | jq

echo -e "\n📦 Mengecek block terakhir (eth_blockNumber)..."
BLOCK_HEX=$(curl -s -X POST $RPC_URL \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  | jq -r '.result')

BLOCK_DEC=$((BLOCK_HEX))
echo "Block saat ini: $BLOCK_HEX (Desimal: $BLOCK_DEC)"

echo -e "\n🧠 Mengecek status Lighthouse (Consensus Layer)..."
curl -s $BEACON_API/eth/v1/node/health | jq

echo -e "\n📶 Mengecek head block dari Beacon (Lighthouse)..."
curl -s $BEACON_API/eth/v1/beacon/headers/head | jq '.data.header.message.slot, .data.header.message.parent_root, .data.header.message.state_root'

echo -e "\n✅ Pengecekan selesai!"
