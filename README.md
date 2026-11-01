You can't download files from this chat, but here's the exact content to save as a file. Copy everything between the fences, paste it into a text editor, and save as `README.md`.

**Create the file on Kali:**

```bash
cd ~/Documents/scripts
nano README.md
# paste everything below, save with Ctrl+O, Enter, Ctrl+X
```

---

**File content (copy from here):**

```markdown
# Selective Deauth (Kali Linux)

A Bash script that continuously deauthenticates every client on a target Wi-Fi access point **except one MAC address you choose to keep connected**.

It discovers clients in real time and keeps sending deauth packets to each new device until it disconnects — automatically starting/stopping workers per client.

> WARNING: Only use this on networks you own or have explicit written permission to test. Unauthorized deauthentication is illegal in most countries.

---

## How it works

- You put your card into monitor mode manually first
- The script runs `airodump-ng` **in the background** on your target AP + channel
- Parses the STATION table every few seconds
- For each client (except your allowed MAC), starts a **persistent `aireplay-ng` worker** that keeps deauthing it
- When a client disappears, its worker is killed
- When a new client appears, a new worker starts
- `Ctrl+C` cleanly stops everything

---

## Requirements

- Kali Linux (or any Debian-based distro)
- A Wi-Fi adapter that supports **monitor mode** and **packet injection**
- `aircrack-ng` suite installed:

```bash
sudo apt update
sudo apt install aircrack-ng
```

---

## Setup

### 1. Put your card into monitor mode

```bash
sudo airmon-ng check kill
sudo airmon-ng start wlan1
```

Note the interface name it prints — it might be `wlan1mon` or `wlan1` (depends on driver).

Verify it's in monitor mode:

```bash
iwconfig
```

You must see `Mode:Monitor` on your interface.

### 2. Find the target details

```bash
sudo airodump-ng <monitor_interface>
```

Write down:

- **BSSID** of the target AP (e.g. `24:44:27:1D:A3:54`)
- **Channel** (e.g. `6`)
- **STATION MAC** of the device you want to **keep connected**

Press `Ctrl+C` to stop scanning.

---

## Usage

```bash
sudo ./selective_deauth_wifi.sh <monitor_iface> <AP_BSSID> <KEEP_MAC> <CHANNEL> [interval]
```

### Arguments

| # | Argument | Example | Description |
|---|----------|---------|-------------|
| 1 | `monitor_iface` | `wlan1` | Interface in monitor mode |
| 2 | `AP_BSSID` | `24:44:27:1D:A3:54` | Target access point MAC |
| 3 | `KEEP_MAC` | `72:CA:50:10:C9:DF` | Client to **keep connected** |
| 4 | `CHANNEL` | `6` | Channel of the AP |
| 5 | `interval` | `15` | Scan interval in seconds (optional, default 15) |

### Example

```bash
sudo ./selective_deauth_wifi.sh wlan1 24:44:27:1D:A3:54 72:CA:50:10:C9:DF 6 15
```

### Stop

Press **`Ctrl+C`** (NOT `Ctrl+Z` — that suspends the process).

### Restore networking

```bash
sudo airmon-ng stop <monitor_iface>
sudo systemctl start NetworkManager
```

---

## Example output

```
[*] Setting wlan1 to channel 6
[*] Interface channel now:
[*] Starting airodump-ng in background...
[*] CSV: /tmp/deauth6_4518-01.csv
[*] Press Ctrl+C (NOT Ctrl+Z) to stop.

[1] visible targets: 22:33:44:55:66:77
    [+] Worker started for 22:33:44:55:66:77 (PID 34567)
    active workers: 1

[2] visible targets: 22:33:44:55:66:77 33:44:55:66:77:88
    [+] Worker started for 33:44:55:66:77:88 (PID 34590)
    active workers: 2

[3] visible targets: 33:44:55:66:77:88
    [-] Worker stopped for 22:33:44:55:66:77 (client gone)
    active workers: 1
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `NOT in Monitor mode` | Run `airmon-ng start <iface>` first |
| No clients detected | Clients are idle — open a video or download on them. Also confirm you're on the correct channel |
| Deauth sent but client stays connected | AP is using WPA3 / 802.11w (PMF). Cannot be bypassed. Disable PMF on your own router |
| `invalid variable name` error | Apply the one-line fix in the "visible targets" echo |
| System crash during use | Usually a driver issue (e.g. `rtl8xxxu` on Realtek cards). Try another USB port or a different adapter |
| Script won't stop with `Ctrl+Z` | Use `Ctrl+C` instead. `Ctrl+Z` only suspends it |
| Stuck process | `sudo pkill -f selective_deauth; sudo pkill -f airodump-ng` |

---

## Limitations

- **WPA3 / 802.11w (PMF)** networks ignore deauth — cannot be bypassed
- Idle clients that send no frames won't appear until they generate traffic
- 2.4 GHz-only adapters cannot see 5 GHz clients
- Some adapters don't support injection — test with `aireplay-ng --test <iface>`

---

## Files

- `selective_deauth_wifi.sh` — main script

---

## Disclaimer

This tool is provided for **educational and authorized security testing** only. The author is not responsible for any misuse or damage. Always have written permission before testing on any network you do not own.

---

## License

MIT License — do whatever you want, just don't blame the author.
```

---

### Alternative: create it with a single command (no editor)

If you'd rather skip `nano`, run this on Kali — it writes the file directly:

```bash
cat > ~/Documents/scripts/README.md << 'EOF'
# Selective Deauth (Kali Linux)

A Bash script that continuously deauthenticates every client on a target Wi-Fi access point **except one MAC address you choose to keep connected**.

It discovers clients in real time and keeps sending deauth packets to each new device until it disconnects — automatically starting/stopping workers per client.

> WARNING: Only use this on networks you own or have explicit written permission to test. Unauthorized deauthentication is illegal in most countries.

---

## How it works

- You put your card into monitor mode manually first
- The script runs `airodump-ng` **in the background** on your target AP + channel
- Parses the STATION table every few seconds
- For each client (except your allowed MAC), starts a **persistent `aireplay-ng` worker** that keeps deauthing it
- When a client disappears, its worker is killed
- When a new client appears, a new worker starts
- `Ctrl+C` cleanly stops everything

---

## Requirements

- Kali Linux (or any Debian-based distro)
- A Wi-Fi adapter that supports **monitor mode** and **packet injection**
- `aircrack-ng` suite installed:

```bash
sudo apt update
sudo apt install aircrack-ng
```

---

## Setup

### 1. Put your card into monitor mode

```bash
sudo airmon-ng check kill
sudo airmon-ng start wlan1
```

Note the interface name it prints — it might be `wlan1mon` or `wlan1` (depends on driver).

Verify it's in monitor mode:

```bash
iwconfig
```

You must see `Mode:Monitor` on your interface.

### 2. Find the target details

```bash
sudo airodump-ng <monitor_interface>
```

Write down:

- **BSSID** of the target AP (e.g. `24:44:27:1D:A3:54`)
- **Channel** (e.g. `6`)
- **STATION MAC** of the device you want to **keep connected**

Press `Ctrl+C` to stop scanning.

---

## Usage

```bash
sudo ./selective_deauth_wifi.sh <monitor_iface> <AP_BSSID> <KEEP_MAC> <CHANNEL> [interval]
```

### Arguments

| # | Argument | Example | Description |
|---|----------|---------|-------------|
| 1 | `monitor_iface` | `wlan1` | Interface in monitor mode |
| 2 | `AP_BSSID` | `24:44:27:1D:A3:54` | Target access point MAC |
| 3 | `KEEP_MAC` | `72:CA:50:10:C9:DF` | Client to **keep connected** |
| 4 | `CHANNEL` | `6` | Channel of the AP |
| 5 | `interval` | `15` | Scan interval in seconds (optional, default 15) |

### Example

```bash
sudo ./selective_deauth_wifi.sh wlan1 24:44:27:1D:A3:54 72:CA:50:10:C9:DF 6 15
```

### Stop

Press **`Ctrl+C`** (NOT `Ctrl+Z` — that suspends the process).

### Restore networking

```bash
sudo airmon-ng stop <monitor_iface>
sudo systemctl start NetworkManager
```

---

## Example output

```
[*] Setting wlan1 to channel 6
[*] Interface channel now:
[*] Starting airodump-ng in background...
[*] CSV: /tmp/deauth6_4518-01.csv
[*] Press Ctrl+C (NOT Ctrl+Z) to stop.

[1] visible targets: 22:33:44:55:66:77
    [+] Worker started for 22:33:44:55:66:77 (PID 34567)
    active workers: 1

[2] visible targets: 22:33:44:55:66:77 33:44:55:66:77:88
    [+] Worker started for 33:44:55:66:77:88 (PID 34590)
    active workers: 2

[3] visible targets: 33:44:55:66:77:88
    [-] Worker stopped for 22:33:44:55:66:77 (client gone)
    active workers: 1
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `NOT in Monitor mode` | Run `airmon-ng start <iface>` first |
| No clients detected | Clients are idle — open a video or download on them. Also confirm you're on the correct channel |
| Deauth sent but client stays connected | AP is using WPA3 / 802.11w (PMF). Cannot be bypassed. Disable PMF on your own router |
| `invalid variable name` error | Apply the one-line fix in the "visible targets" echo |
| System crash during use | Usually a driver issue (e.g. `rtl8xxxu` on Realtek cards). Try another USB port or a different adapter |
| Script won't stop with `Ctrl+Z` | Use `Ctrl+C` instead. `Ctrl+Z` only suspends it |
| Stuck process | `sudo pkill -f selective_deauth; sudo pkill -f airodump-ng` |

---

## Limitations

- **WPA3 / 802.11w (PMF)** networks ignore deauth — cannot be bypassed
- Idle clients that send no frames won't appear until they generate traffic
- 2.4 GHz-only adapters cannot see 5 GHz clients
- Some adapters don't support injection — test with `aireplay-ng --test <iface>`

---

## Files

- `selective_deauth_wifi.sh` — main script

---

## Disclaimer

This tool is provided for **educational and authorized security testing** only. The author is not responsible for any misuse or damage. Always have written permission before testing on any network you do not own.

---

## License

MIT License — do whatever you want, just don't blame the author.
EOF
```

Then verify:

```bash
ls -la ~/Documents/scripts/README.md
head -5 ~/Documents/scripts/README.md
```

Then push to GitHub:

```bash
cd ~/Documents/scripts
git add README.md selective_deauth_wifi.sh
git commit -m "Add script and README"
git push
```

That's the complete file — nothing truncated, nothing omitted.
