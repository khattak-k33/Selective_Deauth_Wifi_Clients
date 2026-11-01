# Selective Wi-Fi Deauthentication

A Bash-based wireless security testing script for **authorized, controlled lab environments**. It monitors a selected access point (AP) and identifies connected client stations, while allowing one specified client MAC address to be excluded from the test.

> [!CAUTION]
> **Disruptive security-testing tool.** Deauthentication can interrupt wireless connectivity for other devices. Use this project only on equipment and networks you own or have explicit permission to test. Do not run it against public, campus, workplace, neighbour, or other third-party networks. Prefer an isolated lab with test devices.

## Overview

The script is designed to:

- Monitor a selected access point using a wireless adapter in monitor mode.
- Read the client station list for the selected access point.
- Exclude a user-specified client MAC address from the test.
- Track client stations as they appear and disappear.
- Start and stop per-client background workers according to the script's detection logic.
- Clean up its background processes when interrupted with `Ctrl+C`.

This project is intended for learning about wireless monitoring and authorized Wi-Fi security testing.

## How it works

1. The operator prepares a compatible wireless adapter in monitor mode.
2. The script monitors the selected AP and channel.
3. It reads the station information collected by the Aircrack-ng tools.
4. The configured exclusion MAC address is skipped.
5. The script manages its background workers as the detected station list changes.
6. Pressing `Ctrl+C` requests the script to stop and clean up its processes.

## Requirements

- Kali Linux or another compatible Debian-based Linux distribution.
- Bash.
- A wireless adapter and driver that support monitor mode and packet injection.
- The Aircrack-ng suite:
  - `airmon-ng` — wireless interface mode management.
  - `airodump-ng` — wireless traffic and station monitoring.
  - `aireplay-ng` — wireless frame injection.

### Install dependencies

```bash
sudo apt update
sudo apt install aircrack-ng
```

- `sudo` runs the command with administrator privileges.
- `apt` is the Debian package manager.
- `update` refreshes the package index.
- `install` installs the requested package.
- `aircrack-ng` is the wireless auditing tool suite used by this project.

## Repository contents

```text
.
├── README.md
└── selective_deauth_wifi.sh
```

| File | Description |
|---|---|
| `selective_deauth_wifi.sh` | Main Bash script. |
| `README.md` | Project documentation. |

## Preparation

Before testing, confirm that:

- You own or are explicitly authorized to test the access point and all affected client devices.
- The test is taking place in a controlled lab.
- Your adapter and driver support the required wireless features.
- You have recorded the correct AP BSSID, channel, and client MAC address to exclude.

The script expects the wireless interface to be prepared in monitor mode before it is run. Interface names vary by adapter and driver; do not assume that every system uses the same name.

## Command-line interface

The script accepts the following arguments:

| Position | Argument | Description |
|---:|---|---|
| 1 | `monitor_iface` | Wireless interface prepared in monitor mode. |
| 2 | `AP_BSSID` | Basic Service Set Identifier (BSSID) of the test access point. |
| 3 | `KEEP_MAC` | Media Access Control (MAC) address to exclude from the test. |
| 4 | `CHANNEL` | Wireless channel used by the test access point. |
| 5 | `interval` | Optional station-scan interval in seconds; defaults to `15` if omitted. |

Use only values from your own isolated lab. Check the script's built-in argument validation and help output, if available, before running it.

## Stopping and cleanup

- Use `Ctrl+C` to interrupt the script.
- Do not use `Ctrl+Z` as a normal stop method; it suspends the foreground process instead of requesting a normal shutdown.
- After the test, restore your wireless interface and restart your network manager if you stopped it during preparation.
- Confirm that no test-related background processes remain.

## Limitations and compatibility

- **Protected Management Frames (PMF):** Networks using IEEE 802.11w / PMF may reject unprotected deauthentication frames.
- **Client visibility:** Idle clients may not be visible until they transmit frames.
- **Band support:** A 2.4 GHz-only adapter cannot monitor 5 GHz traffic.
- **Driver support:** Monitor mode and injection support depend on the adapter chipset and Linux driver.
- **Network behaviour:** Results can vary with access-point configuration, client implementation, channel selection, and driver stability.

## Troubleshooting

| Issue | Things to check |
|---|---|
| Interface is not in monitor mode | Verify the interface name and confirm its current mode. |
| No stations appear | Confirm the AP BSSID and channel; check whether test clients are transmitting. |
| The adapter cannot use the required features | Check chipset and driver support for monitor mode and injection. |
| The test does not behave as expected | Check the AP's PMF configuration and review the script output and system logs. |
| Processes remain after interruption | Inspect running test processes and stop only processes that belong to your test. |
| Network connectivity is not restored | Return the adapter to managed mode and restart the network manager if necessary. |

## Responsible use

This repository is for education and authorized wireless security assessment only. Deauthentication is a disruptive technique and can deny service to wireless users. You are responsible for obtaining permission, limiting the test scope, and complying with applicable laws and policies.

Do not use this project to interfere with networks or devices belonging to other people or organizations.

## Contributing

Suggestions, bug reports, and improvements are welcome. When submitting an issue or pull request:

1. Describe the test environment and adapter/driver details.
2. Include relevant error messages, with private network details and MAC addresses redacted.
3. Keep changes focused on reliability, clarity, and safe lab use.

## License

No license is specified in this repository yet. Add a `LICENSE` file before describing the project as open source or granting reuse permissions.
