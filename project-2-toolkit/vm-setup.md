# VM Setup — web01

## VM Configuration

The `web01` VM was created in VirtualBox using Ubuntu Server.

### VM Details

* VM Name: `web01`
* Operating System: Ubuntu Server
* Hostname: `web01`
* User: `usama`

### VirtualBox Network Configuration

The VM was configured with two network adapters:

* **Adapter 1: NAT** — used for internet/network access.
* **Adapter 2: Host-Only Adapter** — used for communication between the VM and the host.

## Network Configuration

The VM has two network interfaces:

* `enp0s3` — configured with DHCP.
* `enp0s8` — configured with a static IP for the Host-Only network.

The static IP address is:

```text
192.168.56.10/24
```

The network interfaces were verified using:

```bash
ip addr
```

## Netplan Configuration

Netplan was used to configure the network.

The configuration file is:

```text
/etc/netplan/01-netcfg.yaml
```

The Netplan configuration is:

```yaml
network:
  version: 2
  ethernets:
   enp0s3:
      dhcp4: true
   enp0s8:
     dhcp4: no
     addresses: [192.168.56.10/24]
```

The configuration was applied using Netplan.

The final network configuration was verified with:

```bash
ip addr
```

The `enp0s8` interface was configured with:

```text
192.168.56.10/24
```

## Final Configuration

* Hostname: `web01`
* Host-Only Interface: `enp0s8`
* Host-Only IP: `192.168.56.10/24`
* DHCP Interface: `enp0s3`
