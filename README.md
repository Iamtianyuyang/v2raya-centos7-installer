# Install v2rayA on CentOS 7

> Requires root or sudo. Needs `curl` and `unzip`.

## Quick Start

```bash
sudo bash install.sh
```

The script automatically fetches the latest versions of [v2ray-core](https://github.com/v2fly/v2ray-core) and [v2rayA](https://github.com/v2rayA/v2rayA), installs them, and starts the service.

## What the script does

1. Queries GitHub API for the latest `v2fly/v2ray-core` release and downloads `v2ray-linux-64.zip`
   - Installs `v2ray` → `/usr/local/bin/v2ray`
   - Installs `geoip.dat` / `geosite.dat` → `/usr/local/share/v2ray/`
2. Queries GitHub API for the latest `v2rayA/v2rayA` release and installs the RPM via `yum`
3. Enables and starts `v2raya.service`

## Usage

Open the web UI at `http://localhost:2017` after installation.

```bash
# Check service status
systemctl status v2raya.service

# Restart service
systemctl restart v2raya.service

# Reset forgotten password
v2raya --reset-password
```
