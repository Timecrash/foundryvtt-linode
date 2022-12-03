# foundryvtt-linode

A simple script to install Foundry Virtual Tabletop on a Debian/Ubuntu image. Also installs PM2 for easy daemon management, and optionally caddy for HTTPS proxying.

For the Foundry URL, this is available on your Purchased Licenses account page and is valid for five minutes.

For Caddy, you will need to input a hostname you own, like foundry.example.com. Of course, you will need to set up the DNS resolution yourself.

PM2 assumes the root user for its service creation. So be sure to use sudo to control it (sudo pm2 restart foundry, sudo pm2 status foundry).

## Compatible Images

- Debian 10
- Debian 11
- Ubuntu 20.04 LTS
- Ubuntu 22.04 LTS
