# foundryvtt-linode

A simple script to install [Foundry Virtual Tabletop](https://foundryvtt.com) on a Debian/Ubuntu image. Also installs [PM2](https://pm2.keymetrics.io/) for easy daemon management, and optionally [Caddy](https://caddyserver.com/) for HTTPS proxying.

For the Foundry URL, this is available on your Purchased Licenses account page and is valid for five minutes.

Caddy requires a (sub-)domain you own, like `foundry.example.com`. Of course, you'll need to set up the DNS resolution yourself.

PM2 assumes the root user for its service creation. So be sure to use `sudo` to control it (i.e. `sudo pm2 restart foundry`, `sudo pm2 status foundry`).

## Compatible Images

- Debian 10
- Debian 11
- Ubuntu 20.04 LTS
- Ubuntu 22.04 LTS
