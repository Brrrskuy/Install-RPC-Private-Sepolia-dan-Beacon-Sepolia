# Install RPC Private Sepolia dan Beacon Sepolia
---------------------------------------------
# One Click Command
```
chmod +x install-rpc-private-sepolia.sh && sed -i 's/\r$//' install-rpc-private-sepolia.sh && ./install-rpc-private-sepolia.sh
```
# Check Status Command
```
chmod +x check-node-status.sh && sed -i 's/\r$//' check-node-status.sh && ./check-node-status.sh
```

# Cara Cek Sinkronisasi & Status
Cek versi client
```
curl -X POST http://<IP-ANDA>:8545 \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}'
```
Cek sync status
```
curl -X POST http://<IP-ANDA>:8545 \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'
```
Cek Lighthouse status
```
curl http://<IP-ANDA>:5052/eth/v1/node/health
```
# Check Logs 
```
docker compose logs -f geth
```
```
docker compose logs -f lighthouse
```
# Maintenance dan Update
```
docker compose pull
```
```
docker compose down
```
```
docker compose up -d
```
