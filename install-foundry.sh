#!/usr/bin/env bash

#<UDF name="FOUNDRY_URL" label="FoundryVTT download URL">
#<UDF name="FOUNDRY_HOSTNAME" label="Your desired hostname for Foundry" example="foundry.example.com" default="">
#<UDF name="FOUNDRY_APP_DIR" label="Location to save FoundryVTT app" default="/opt/foundryvtt">
#<UDF name="FOUNDRY_DATA_DIR" label="Location to save FoundryVTT assets/modules/systems" default="/opt/foundrydata">

# Per the docs, nodejs setup differs between Debian and Ubuntu
if [ "$(lsb_release -si)" = 'Debian' ]; then
  curl -fsSL https://deb.nodesource.com/setup_17.x | bash -
else
  curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -
fi

# Install prerequisites
apt install -y libssl-dev unzip nodejs

# Create system user to manage Foundry
useradd -r foundry

# Install Foundry
mkdir -p "$FOUNDRY_APP_DIR" "$FOUNDRY_DATA_DIR"
wget -O "$FOUNDRY_APP_DIR/foundryvtt.zip" "$FOUNDRY_URL"
unzip "$FOUNDRY_APP_DIR/foundryvtt.zip" -d "$FOUNDRY_APP_DIR"
chown -R foundry:foundry "$FOUNDRY_APP_DIR" "$FOUNDRY_DATA_DIR"

# Install PM2 for daemon management
npm install pm2@latest -g
pm2 start "$FOUNDRY_APP_DIR/resources/app/main.js" --name foundry --user foundry -- --dataPath="$FOUNDRY_DATA_DIR"

# Allow PM2 to start at boot
pm2 startup
pm2 save

# Set up Caddy if required
if [ -n "$FOUNDRY_HOSTNAME" ]; then
  # Install Foundry
  echo 'deb [trusted=yes] https://apt.fury.io/caddy/ /' >> /etc/apt/sources.list.d/caddy-fury.list
  apt update
  apt install -y caddy

  # Configure Caddy for HTTPS proxying
  cat > /etc/caddy/Caddyfile <<EOF
${FOUNDRY_HOSTNAME} {
  @http {
    protocol http
  }
  redir @http https://${FOUNDRY_HOSTNAME}

  reverse_proxy localhost:30000
}
EOF

  # Configure Foundry for HTTPS proxying
  cat > "$FOUNDRY_DATA_DIR/Config/options.json" <<EOF
{
  "port": 30000,
  "upnp": true,
  "fullscreen": false,
  "hostname": "${FOUNDRY_HOSTNAME}",
  "routePrefix": null,
  "sslCert": null,
  "sslKey": null,
  "awsConfig": null,
  "dataPath": "${FOUNDRY_DATA_DIR}",
  "proxySSL": true,
  "proxyPort": 443,
  "minifyStaticFiles": true,
  "updateChannel": "release",
  "language": "en.core",
  "world": null
}
EOF

  # Restart Foundry to take proxying into account
  pm2 restart foundry

  # Start Caddy
  systemctl enable caddy
  systemctl start caddy

  echo "FoundryVTT setup complete! Please access your instance here: https://$FOUNDRY_HOSTNAME"
else
  echo "FoundryVTT setup complete! Please access your instance here: http://$(hostname -I | cut -f1 -d' '):30000"
fi
