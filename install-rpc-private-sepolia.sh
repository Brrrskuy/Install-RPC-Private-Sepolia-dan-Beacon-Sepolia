#!/bin/bash
# === Sepolia RPC Node Auto Installer ===
# Geth + Lighthouse | Docker Compose | Public Access | Final Version 2025

set -euo pipefail

echo "🔧 Menyiapkan Sepolia RPC Node (Geth + Lighthouse)..."

# 1. Install Docker & dependencies
echo "📦 Menginstal Docker dan dependensi..."
sudo apt update && sudo apt install -y \
    curl ca-certificates gnupg lsb-release apt-transport-https software-properties-common ufw

if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  sudo usermod -aG docker "$USER"
  echo "🚨 Silakan logout & login ulang agar grup 'docker' aktif."
fi

# 2. Cek Docker Compose modern (v2)
if ! docker compose version &>/dev/null; then
  echo "❌ Docker Compose (v2) tidak ditemukan. Periksa instalasi Docker Anda."
  exit 1
fi

# 3. Buat direktori kerja
echo "📁 Membuat direktori kerja dan file JWT..."
mkdir -p ~/sepolia-rpc/{geth-data,lighthouse-data,.jwt}
cd ~/sepolia-rpc

# 4. Buat JWT Secret
if [[ ! -f .jwt/jwtsecret ]]; then
  openssl rand -hex 32 | tr -d "\n" > .jwt/jwtsecret
  chmod 644 .jwt/jwtsecret
  echo "✅ JWT dibuat dengan panjang $(cat .jwt/jwtsecret | wc -c) karakter."
fi

# 5. Buat docker-compose.yml
echo "📝 Menulis docker-compose.yml..."
cat <<EOF > docker-compose.yml
version: "3.8"

services:
  geth:
    image: ethereum/client-go:stable
    command:
      - --sepolia
      - --http
      - --http.addr=0.0.0.0
      - --http.port=8545
      - --http.api=eth,net,web3,debug,admin,engine
      - --http.corsdomain=*
      - --http.vhosts=*
      - --ws
      - --ws.addr=0.0.0.0
      - --ws.port=8546
      - --ws.api=eth,net,web3,engine
      - --authrpc.addr=0.0.0.0
      - --authrpc.port=8551
      - --authrpc.vhosts=*
      - --authrpc.jwtsecret=/jwt/jwtsecret
      - --datadir=/data
      - --syncmode=snap
      - --state.scheme=hash
    ports:
      - 8545:8545  # HTTP RPC
      - 8546:8546  # WebSocket
      - 8551:8551  # Auth RPC
      - 30303:30303/tcp  # P2P
      - 30303:30303/udp
    volumes:
      - ./geth-data:/data
      - ./.jwt:/jwt
    restart: unless-stopped

  lighthouse:
    image: sigp/lighthouse:latest
    command:
      - lighthouse
      - bn
      - --network=sepolia
      - --execution-endpoint=http://geth:8551
      - --execution-jwt=/jwt/jwtsecret
      - --checkpoint-sync-url=https://sepolia.checkpoint-sync.ethpandaops.io
      - --http
      - --http-address=0.0.0.0
      - --http-port=5052
      - --metrics
      - --metrics-address=0.0.0.0
      - --metrics-port=5054
      - --disable-enr-auto-update
    depends_on:
      - geth
    ports:
      - 5052:5052  # Beacon HTTP API
      - 5054:5054  # Metrics
      - 9000:9000/tcp  # P2P
      - 9000:9000/udp
    volumes:
      - ./lighthouse-data:/root/.lighthouse
      - ./.jwt:/jwt
    restart: unless-stopped

EOF

# 6. Konfigurasi Firewall UFW
echo "🛡️  Mengatur firewall (UFW)..."
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 8545/tcp # HTTP RPC
sudo ufw allow 8546/tcp # WebSocket
sudo ufw allow 8551/tcp # Auth RPC
sudo ufw allow 5052/tcp # Beacon API
sudo ufw allow 30303/tcp # Geth P2P
sudo ufw allow 30303/udp
sudo ufw allow 9000/tcp  # Lighthouse P2P
sudo ufw allow 9000/udp
sudo ufw --force enable

# 7. Jalankan node
echo "🚀 Menjalankan docker compose..."
docker compose up -d

# 8. Tunggu dan cek koneksi
echo "⏳ Menunggu 15 detik agar node siap..."
sleep 15

echo "🔍 Cek koneksi Geth:"
curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' \
  http://localhost:8545 || echo "⚠️  Geth belum merespons."

echo "🔍 Cek koneksi Lighthouse:"
curl -s http://localhost:5052/eth/v1/node/health || echo "⚠️  Lighthouse belum merespons."

# 9. Info akhir
IP=$(curl -s ifconfig.me)
echo -e "\n✅ Sepolia RPC node AKTIF dan TERBUKA untuk publik!"
echo "🔗 RPC Endpoints:"
echo "  - HTTP      : http://$IP:8545"
echo "  - WebSocket : ws://$IP:8546"
echo "  - Beacon API: http://$IP:5052"
echo ""
echo "📦 Logs:"
echo "  docker compose logs -f geth"
echo "  docker compose logs -f lighthouse"
