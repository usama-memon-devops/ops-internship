# Network Documentation

## Network Diagram

Laptop
  |
  | Host-Only Network
  | 192.168.56.1/24
  |
web01 (VM)
 
  
web01 (VM)
  |
  +-- enp0s3 → NAT → 10.0.2.15/24 → Internet
  |
  +-- enp0s8 → Host-Only → 192.168.56.10/24 → Laptop


## IP and Interface Mapping

| Interface | Type | IP Address | Purpose |
|---|---|---|---|
| lo | Loopback | 127.0.0.1/8 | Local-only communication |
| enp0s3 | NAT | 10.0.2.15/24 | Internet access |
| enp0s8 | Host-Only | 192.168.56.10/24 | Laptop to VM access |


## Why Two Network Adapters?

The NAT adapter (enp0s3) provides internet access to the VM for installing packages and updates.

The Host-Only adapter (enp0s8) provides private communication between the laptop and web01 at 192.168.56.10.


### What Breaks If an Adapter Is Removed?

If NAT is removed, web01 loses internet access. Package installation, updates, and other outbound internet connections may stop working.

If Host-Only is removed, the laptop can no longer directly access web01 at 192.168.56.10. The website would not be reachable from the laptop through the private network.

## Listening Ports

The `ss -tulpn` command shows the following listening services on web01:

- 127.0.0.1:8000 — Gunicorn; Flask application, accessible only locally.
- 0.0.0.0:2222 — SSH; remote administration, restricted by UFW to 192.168.56.0/24.
- 0.0.0.0:80 — Nginx HTTP; redirects HTTP requests to HTTPS.
- 0.0.0.0:443 — Nginx HTTPS; serves the website securely.


- 127.0.0.53:53 and 127.0.0.54:53 — systemd-resolved; local DNS resolution.
- 10.0.2.15:68 — systemd-networkd; DHCP client for the NAT interface.


## UFW Firewall Rules

Default incoming traffic: DENY — blocks unsolicited incoming connections by default.
Default outgoing traffic: ALLOW — allows the server to make outbound connections.

80/tcp ALLOW IN Anywhere — allows HTTP traffic so users can reach the web server.
443/tcp ALLOW IN Anywhere — allows HTTPS traffic for the website.
2222/tcp ALLOW IN 192.168.56.0/24 — allows SSH only from the private Host-Only network.
