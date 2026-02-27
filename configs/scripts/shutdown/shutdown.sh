#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

VARIANTS_DIR="$(dirname "$(realpath "$0")")/variants"

# ── helpers ────────────────────────────────────────────────────────────────────

log()  { echo "[INFO]  $*"; }
warn() { echo "[WARN]  $*" >&2; }
die()  { echo "[ERROR] $*" >&2; exit 1; }

run_variant() {
    local script="$VARIANTS_DIR/$1.sh"
    if [[ -f "$script" ]]; then
        log "Matched variant: $1  →  $script"
        bash "$script"
        exit $?
    fi
}

# ── main ───────────────────────────────────────────────────────────────────────

HOSTNAME="${1:-$(hostname)}"          # accept an optional override as $1
HOSTNAME_LOWER="${HOSTNAME,,}"        # lowercase for case-insensitive matching

log "Hostname : $HOSTNAME"
log "Variants : $VARIANTS_DIR"
echo

[[ -d "$VARIANTS_DIR" ]] || die "Variants directory not found: $VARIANTS_DIR"

IFS='-' read -ra segments <<< "$HOSTNAME_LOWER"

num_segments=${#segments[@]}


candidates=()

# --- prefix candidates (longest first) ----------------------------------------
for (( end=num_segments; end>=1; end-- )); do
    prefix_parts=( "${segments[@]:0:$end}" )
    candidate=$(IFS='-'; echo "${prefix_parts[*]}")

    # Skip if this candidate is only digits (e.g. "01")
    [[ "$candidate" =~ ^[0-9]+$ ]] && continue

    candidates+=( "$candidate" )
done

# --- individual segment candidates (non-numeric) ------------------------------
for seg in "${segments[@]}"; do
    [[ "$seg" =~ ^[0-9]+$ ]] && continue
    # Avoid duplicating single-segment entries already added above
    already=0
    for c in "${candidates[@]}"; do
        [[ "$c" == "$seg" ]] && already=1 && break
    done
    (( already )) || candidates+=( "$seg" )
done

# --- try each candidate in order ----------------------------------------------
log "Trying candidates (most → least specific):"
for c in "${candidates[@]}"; do
    echo "        $c"
done
echo

for candidate in "${candidates[@]}"; do
    run_variant "$candidate"   # exits on first match
done

die "No matching variant script found for hostname '$HOSTNAME'."
