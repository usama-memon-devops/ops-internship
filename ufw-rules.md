# UFW Firewall Rules

## Overview

UFW (Uncomplicated Firewall) is used on `web01` to control incoming and
outgoing network traffic.

The firewall uses a deny-by-default approach for incoming traffic.
Only the services required by the web server are allowed.

---

## Default Firewall Policies

| Traffic Direction | Policy | Reason |
|---|---|---|
| Incoming | DENY | Blocks unwanted incoming connections by default |
| Outgoing | ALLOW | Allows the server to access required external services |
| Routed | DISABLED | The server is not being used as a router |

---

## Allowed Incoming Rules

| Port | Protocol | Source | Purpose |
|---|---|---|---|
| 80 | TCP | Anywhere | HTTP traffic to Nginx |
| 443 | TCP | Anywhere | HTTPS traffic to Nginx |
| 2222 | TCP | 192.168.56.0/24 | SSH administration from the Host-Only network |

---

## Rule Explanation

### Port 80 - HTTP

Allows clients to connect to Nginx using HTTP.

HTTP requests are redirected to HTTPS for secure access.

### Port 443 - HTTPS

Allows clients to access the website securely using HTTPS.

### Port 2222 - SSH

Allows SSH administration only from the private
`192.168.56.0/24` Host-Only network.

This restricts SSH access to the private network.

### Port 8000 - Gunicorn

Port 8000 is not allowed through UFW.

Gunicorn listens only on:

`127.0.0.1:8000`

Therefore, the Flask application cannot be accessed directly from
the network. Clients must access the application through Nginx.

---

## IPv6 Rules

The following IPv6 rules are enabled for the web ports:

```text
80/tcp (v6)   ALLOW IN   Anywhere (v6)
443/tcp (v6)  ALLOW IN   Anywhere (v6)


## Current Firewall Status

The firewall is currently active:

```text
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)

To                         Action      From
--                         ------      ----
80/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
2222/tcp                   ALLOW IN    192.168.56.0/24
80/tcp (v6)                ALLOW IN    Anywhere (v6)
443/tcp (v6)               ALLOW IN    Anywhere (v6)
