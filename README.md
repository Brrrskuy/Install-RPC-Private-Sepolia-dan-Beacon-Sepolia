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
# Akses Sepolia,Endpoint RPC HTTP & Beacon Sepolia
Sepolia RPC
```
http://IP_VPS:8545
```
Beacon Sepolia RPC
```
http://IP_VPS:5052
```
# Jika ingin Private RPC tidak untuk Public
Hapus port Public
```
sudo ufw delete allow 8545/tcp
sudo ufw delete allow 8546/tcp
sudo ufw delete allow 8551/tcp
sudo ufw delete allow 5052/tcp
sudo ufw delete allow 8545/tcp
sudo ufw delete allow 8546/tcp
sudo ufw delete allow 8551/tcp
sudo ufw delete allow 5052/tcp
```
# Buka Akses untuk IP Tertentu
```
# Geth HTTP RPC
sudo ufw allow from 64.227.xxx.xxx to any port 8545 proto tcp
sudo ufw allow from 143.198.xxx.xxx to any port 8545 proto tcp

# Geth WebSocket (optional)
sudo ufw allow from 64.227.xxx.xxx to any port 8546 proto tcp
sudo ufw allow from 143.198.xxx.xxx to any port 8546 proto tcp

# Lighthouse Beacon API
sudo ufw allow from 64.227.xxx.xxx to any port 5052 proto tcp
sudo ufw allow from 143.198.xxx.xxx to any port 5052 proto tcp
```
# Check ulang UFW 
```
sudo ufw status numbered
```
# Check lewat IP Waitlist
```
curl http://<IP>:8545
```
```
curl http://<IP>:5052
```
